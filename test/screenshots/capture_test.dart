import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/trip.dart';
import 'package:aed_map/screens/map/map_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tool/screenshots/scenario.dart';
import 'fakes.dart';

void main() {
  final routes = jsonDecode(File(Scenario.routesPath).readAsStringSync()) as Map<String, dynamic>;
  final only = Platform.environment['SCREENSHOT_ONLY'];

  setUpAll(() async {
    await ScreenshotFonts.load();
    analytics.enabled = false;
    PackageInfo.setMockInitialValues(
        appName: 'Mapa AED',
        packageName: 'pl.enteam.aed_map',
        version: '1.0.85',
        buildNumber: '85',
        buildSignature: '');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel('hemanthraj/flutter_compass'),
            MockStreamHandler.inline(onListen: (arguments, events) {}));
  });

  for (final locale in Scenario.locales) {
    for (final device in ScreenshotDevice.values) {
      for (final scene in device.scenes) {
        final name = Scenario.testName(locale, scene, device);
        testWidgets(name, skip: only != null && !name.contains(only), (tester) async {
          await ScreenshotCapture(tester, locale, device, scene, routes[locale.code]).capture();
        });
      }
    }
  }
}

class ScreenshotCapture {
  ScreenshotCapture(this.tester, this.locale, this.device, this.scene, this.route);

  final WidgetTester tester;
  final ScreenshotLocale locale;
  final ScreenshotDevice device;
  final ScreenshotScene scene;
  final Map<String, dynamic> route;
  final GlobalKey boundaryKey = GlobalKey();

  LatLng get position => LatLng(locale.latitude, locale.longitude);

  Future<void> capture() async {
    configureView();
    debugDefaultTargetPlatformOverride = device.apple ? TargetPlatform.iOS : TargetPlatform.android;
    debugDisableShadows = false;
    try {
      await pumpApp();
      await waitUntil(() => pointsState is PointsLoadSuccess && find.byType(MapScreen).evaluate().isNotEmpty);
      await settle(const Duration(seconds: 1));
      await applyScene();
      await settle(const Duration(seconds: 2));
      await save();
      await tester.pumpWidget(const SizedBox());
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugDisableShadows = true;
    }
  }

  PointsState? get pointsState {
    final elements = find.byType(MapScreen).evaluate();
    return elements.isEmpty ? null : elements.first.read<PointsCubit>().state;
  }

  BuildContext get mapContext => find.byType(MapScreen).evaluate().first;

  void configureView() {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'firstEnter': true});
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(position);
    tester.view.physicalSize = Size(device.width.toDouble(), device.height.toDouble());
    tester.view.devicePixelRatio = device.pixelRatio;
    tester.view.padding = FakeViewPadding(
        top: device.topPadding * device.pixelRatio, bottom: device.bottomPadding * device.pixelRatio);
    tester.platformDispatcher.platformBrightnessTestValue =
        scene == ScreenshotScene.dark ? Brightness.dark : Brightness.light;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  }

  Future<void> pumpApp() async {
    final trip = Trip(route['shape'] as String, (route['time'] as num).toDouble(), (route['length'] as num).toDouble());
    await tester.runAsync(() => tester.pumpWidget(RepaintBoundary(
          key: boundaryKey,
          child: App(
            skipOnboarding: true,
            locale: Locale(locale.code),
            tileProvider: FixtureTileProvider(Directory(Scenario.tilesDirectory)),
            geolocationRepository: FakeGeolocationRepository(position),
            pointsRepository: FakePointsRepository(File(Scenario.datasetPath)),
            routingRepository: FakeRoutingRepository(trip),
            networkStatusCubit: NetworkStatusCubit(monitor: false),
          ),
        )));
  }

  Future<void> waitUntil(bool Function() condition) async {
    for (var attempt = 0; attempt < 600 && !condition(); attempt++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(condition(), isTrue, reason: 'Map screen did not load');
  }

  Future<void> settle(Duration duration) async {
    for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 100)) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> applyScene() async {
    switch (scene) {
      case ScreenshotScene.map:
      case ScreenshotScene.dark:
        mapContext.read<PanelCubit>().cancel();
      case ScreenshotScene.details:
        break;
      case ScreenshotScene.route:
        final state = pointsState as PointsLoadSuccess;
        await tester.runAsync(() => mapContext.read<RoutingCubit>().navigate(position, state.selected));
      case ScreenshotScene.add:
        await tester.runAsync(() => mapContext.read<EditCubit>().enter());
    }
  }

  Future<void> save() async {
    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: device.pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(Scenario.rawPath(locale, scene, device));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }
}
