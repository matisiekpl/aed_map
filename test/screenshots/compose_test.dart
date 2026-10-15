@Tags(['screenshots'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/screenshots/scenario.dart';
import 'compositions.dart';
import 'fakes.dart';

void main() {
  final captions = jsonDecode(File(Scenario.captionsPath).readAsStringSync()) as Map<String, dynamic>;
  final only = Platform.environment['SCREENSHOT_ONLY'];

  setUpAll(() async {
    await ScreenshotFonts.load();
    final loader = FontLoader('Manrope')
      ..addFont(Future.value(ByteData.sublistView(File(Scenario.captionFontPath).readAsBytesSync())));
    await loader.load();
  });

  for (final locale in Scenario.locales) {
    final name = Scenario.featureGraphicTestName(locale);
    testWidgets(name, skip: only != null && !name.contains(only), (tester) async {
      final translations = jsonDecode(File('lib/l10n/app_${locale.code}.arb').readAsStringSync());
      final widget = FeatureGraphic(
        appName: translations['heading'] as String,
        sentence: captions[locale.code]['banner'] as String,
        icon: File('assets/icon.png').readAsBytesSync(),
        screen: File(Scenario.rawPath(locale, ScreenshotScene.map, ScreenshotDevice.android)).readAsBytesSync(),
      );
      await CompositionRenderer(tester).render(
          widget, Scenario.featureGraphicWidth, Scenario.featureGraphicHeight, Scenario.featureGraphicPath(locale));
    });
    for (final scene in Scenario.landingScenes) {
      final name = Scenario.landingTestName(locale, scene);
      testWidgets(name, skip: only != null && !name.contains(only), (tester) async {
        const width = Scenario.landingMockupWidth;
        final frame = DeviceFrame(
          width: width * 0.86,
          device: ScreenshotDevice.iphone,
          screen: File(Scenario.rawPath(locale, scene, ScreenshotDevice.iphone)).readAsBytesSync(),
          dark: false,
        );
        await CompositionRenderer(tester).render(
            Center(child: frame), width, (frame.height + width * 0.14).round(), Scenario.landingMockupPath(locale, scene));
      });
    }
    for (final target in ComposeTarget.values) {
      for (final scene in target.device.scenes) {
        final name = Scenario.composeTestName(locale, scene, target);
        testWidgets(name, skip: only != null && !name.contains(only), (tester) async {
          final widget = StoreScreenshot(
            caption: captions[locale.code][scene.name] as String,
            screen: File(Scenario.rawPath(locale, scene, target.device)).readAsBytesSync(),
            device: target.device,
            dark: scene == ScreenshotScene.dark,
          );
          await CompositionRenderer(tester).render(
              widget, target.width, target.height, Scenario.composedPath(locale, scene, target));
        });
      }
    }
  }
}

class CompositionRenderer {
  CompositionRenderer(this.tester);

  final WidgetTester tester;

  Future<void> render(Widget widget, int width, int height, String path) async {
    tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
    tester.view.devicePixelRatio = 1;
    debugDisableShadows = false;
    try {
      addTearDown(tester.view.reset);
      final boundaryKey = GlobalKey();
      await tester.runAsync(() async {
        await tester.pumpWidget(RepaintBoundary(
          key: boundaryKey,
          child: Directionality(textDirection: TextDirection.ltr, child: widget),
        ));
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pump();
      await tester.runAsync(() async {
        final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(path);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
      });
    } finally {
      debugDisableShadows = true;
    }
  }
}
