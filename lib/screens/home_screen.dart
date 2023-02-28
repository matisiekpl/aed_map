import 'dart:async';
import 'dart:io';

import 'package:aed_map/constants.dart';
import 'package:aed_map/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aed_map/cached_network_tile_provider.dart';
import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hue_rotation/hue_rotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/aed.dart';
import '../store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<AED> aeds = [];
  List<Marker> markers = [];
  AED? selectedAED;
  final PanelController panel = PanelController();
  final MapController mapController = MapController();
  final SuperclusterImmutableController markersController =
      SuperclusterImmutableController();

  Brightness? _brightness;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  _initAsync() async {
    List<AED> items = [];
    if (kDebugMode) {
      items = await Store.instance
          .loadAEDs(LatLng(warsaw.latitude, warsaw.longitude));
    } else {
      var position = await Store.instance.determinePosition();
      items = await Store.instance
          .loadAEDs(LatLng(position.latitude, position.longitude));
    }
    setState(() {
      aeds = items;
      selectedAED = aeds.first;
    });
    _getMarkers();
    setState(() {
      loaded = true;
    });
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkNetwork();
    });
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance.window.platformBrightness;
      });
    }
    super.didChangePlatformBrightness();
  }

  List<Marker> _getMarkers() {
    markers = aeds
        .map((aed) {
          if (aed.access == 'yes') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => SvgPicture.asset('assets/green_aed.svg'),
            );
          }
          if (aed.access == 'customers') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => SvgPicture.asset('assets/yellow_aed.svg'),
            );
          }
          if (aed.access == 'private' || aed.access == 'permissive') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => SvgPicture.asset('assets/blue_aed.svg'),
            );
          }
          if (aed.access == 'no') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => SvgPicture.asset('assets/red_aed.svg'),
            );
          }
          if (aed.access == 'unknown') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => SvgPicture.asset('assets/grey_aed.svg'),
            );
          }
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => SvgPicture.asset('assets/green_aed.svg'),
          );
        })
        .cast<Marker>()
        .toList();
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: !loaded
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SlidingUpPanel(
                      controller: panel,
                      maxHeight: 500,
                      borderRadius: radius,
                      parallaxEnabled: true,
                      parallaxOffset: 0.5,
                      panel: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            color: _brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                          duration: const Duration(milliseconds: 300),
                          child: _buildBottomPanel()),
                      body: SafeArea(top: false, child: _buildMap())),
                  SafeArea(child: _buildHeader())
                ],
              ));
  }

  Widget _buildBottomPanel() {
    var aed = selectedAED!;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 24.0),
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (aeds.first == selectedAED)
                  Text('⚠️ ' + AppLocalizations.of(context)!.closestAED,
                      style: const TextStyle(
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                          fontSize: 18)),
                if (aeds.first != selectedAED)
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _selectAED(aeds.first);
                      },
                      child: Text(
                          '⚠️ ' +
                              AppLocalizations.of(context)!.closerAEDAvailable,
                          style: const TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                              fontSize: 18))),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: aed.getColor(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SvgPicture.asset(
                                  'assets/' + aed.getIconFilename(),
                                  width: 32)),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.defibrillator,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: aed.getColor() == Colors.yellow
                                      ? Colors.black
                                      : Colors.white))
                        ],
                      ),
                      const SizedBox(height: 8),
                      CrossFade<String>(
                          duration: const Duration(milliseconds: 200),
                          value: aed.getAccessComment(context) ??
                              AppLocalizations.of(context)!.noData,
                          builder: (context, v) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.access + ": ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: aed.getColor() == Colors.yellow
                                            ? Colors.black
                                            : Colors.white)),
                                Text(v,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: aed.getColor() == Colors.yellow
                                            ? Colors.black
                                            : Colors.white)),
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.description ?? AppLocalizations.of(context)!.noData,
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.location,
                          style: const TextStyle(fontSize: 16)),
                      Text(v,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            const SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.operator ?? AppLocalizations.of(context)!.noData,
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.operator,
                          style: const TextStyle(fontSize: 16)),
                      Text(v,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            const SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: formatOpeningHours(aed.openingHours) ??
                    AppLocalizations.of(context)!.noData,
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.openingHours,
                          style: const TextStyle(fontSize: 16)),
                      Text(v,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            const SizedBox(height: 4),
            CrossFade<bool>(
                duration: const Duration(milliseconds: 200),
                value: aed.indoor,
                builder: (context, v) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.insideBuilding + ': ',
                          style: const TextStyle(fontSize: 16)),
                      Text(
                          v
                              ? AppLocalizations.of(context)!.yes
                              : AppLocalizations.of(context)!.no,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            const SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.phone ?? AppLocalizations.of(context)!.noData,
                builder: (context, v) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      launchUrl(Uri.parse(
                          'tel:${aed.phone.toString().replaceAll(' ', '')}'));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.contact + ': ',
                            style: const TextStyle(fontSize: 16)),
                        Text(v,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                      child: Text(AppLocalizations.of(context)!.navigate),
                      onPressed: () {
                        _openMap(aed.location.latitude, aed.location.longitude);
                      })),
            ),
            const SizedBox(height: 12),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: _translateMeters(selectedAED!.distance!),
                builder: (context, v) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(v, style: const TextStyle(color: Colors.orange)),
                    ],
                  );
                })
          ],
        ),
      )
    ]);
  }

  ColorFilter colorFilter = const ColorFilter.matrix(<double>[
    -1,
    0,
    0,
    0,
    255,
    0,
    -1,
    0,
    0,
    255,
    0,
    0,
    -1,
    0,
    255,
    0,
    0,
    0,
    1,
    0,
  ]);

  ColorFilter invert = const ColorFilter.matrix(<double>[
    -1,
    0,
    0,
    0,
    255,
    0,
    -1,
    0,
    0,
    255,
    0,
    0,
    -1,
    0,
    255,
    0,
    0,
    0,
    1,
    0,
  ]);

  bool _isConnected = true;

  void _checkNetwork() async {
    try {
      await http.get(Uri.parse(
          'https://aed.openstreetmap.org.pl/aed_poland.geojson_test'));
      setState(() {
        _isConnected = true;
      });
      return;
    } catch (_) {
      setState(() {
        _isConnected = false;
      });
      return;
    }
  }

  Widget _buildMap() {
    bool isDarkMode = _brightness == Brightness.dark;
    return FutureBuilder<LatLng>(
        future: Store.instance.determinePosition(),
        builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
          if (snapshot.hasData || snapshot.hasError) {
            return Column(
              children: [
                Flexible(
                    child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: aeds.first.location,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        zoom: 14,
                        maxZoom: 18,
                        minZoom: 8,
                      ),
                      children: [
                        TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'pl.enteam.aed_map',
                            tileProvider: CachedNetworkTileProvider(),
                            tileBuilder: (BuildContext context,
                                Widget tileWidget, Tile tile) {
                              return isDarkMode
                                  ? HueRotation(
                                      degrees: 180,
                                      child: ColorFiltered(
                                          colorFilter: invert,
                                          child: tileWidget),
                                    )
                                  : tileWidget;
                            }),
                        CurrentLocationLayer(),
                        SuperclusterLayer.immutable(
                          initialMarkers: markers,
                          loadingOverlayBuilder: (context) => Container(),
                          controller: markersController,
                          minimumClusterSize: 3,
                          onMarkerTap: (Marker marker) {
                            _selectAED(aeds[int.parse(marker.key
                                .toString()
                                .replaceAll('[<\'', '')
                                .replaceAll('\'>]', ''))]);
                          },
                          clusterWidgetSize: const Size(40, 40),
                          anchor: AnchorPos.align(AnchorAlign.center),
                          clusterZoomAnimation: const AnimationOptions.animate(
                            curve: Curves.linear,
                            velocity: 1,
                          ),
                          calculateAggregatedClusterData: true,
                          builder: (context, position, markerCount,
                              extraClusterData) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.brown),
                              child: Center(
                                child: Text(
                                  markerCount.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildHeader() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.heading,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 32)),
              Text(AppLocalizations.of(context)!.subheading(aeds.length),
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              if (!_isConnected)
                Text(AppLocalizations.of(context)!.noNetwork,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold))
            ],
          ),
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showAboutDialog();
                },
                child: Card(
                  color: _brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.gear,
                        color: _brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Store.instance.authenticate();
                },
                child: Card(
                  color: _brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.wand_rays,
                        color: _brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }

  _selectAED(AED aed) async {
    setState(() {
      selectedAED = aed;
    });
    panel.open();
    _animatedMapMove(selectedAED!.location, 16);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationIcon:
          const Image(image: AssetImage('assets/icon.png'), width: 64),
      applicationName: AppLocalizations.of(context)!.heading,
      applicationVersion: 'v1.0.2',
      applicationLegalese: 'By Mateusz Woźniak',
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(AppLocalizations.of(context)!.about)),
      ],
    );
  }

  String _translateMeters(int distance) {
    if (distance > 10000) {
      return AppLocalizations.of(context)!.distance((distance / 1000).floor());
    }
    return AppLocalizations.of(context)!
        .runDistance((distance / 200).ceil(), distance);
  }

  _openMap(double latitude, double longitude) async {
    if (Platform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.chooseMapApp),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              onPressed: () {
                MapsLauncher.launchCoordinates(latitude, longitude);
              },
              child: const Text('Apple Maps'),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                String googleUrl =
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                // ignore: deprecated_member_use
                if (await canLaunch(googleUrl)) {
                  // ignore: deprecated_member_use
                  await launch(googleUrl);
                } else {
                  throw 'Could not open the map.';
                }
              },
              child: const Text('Google Maps'),
            ),
          ],
        ),
      );
    } else {
      MapsLauncher.launchCoordinates(latitude, longitude);
    }
  }
}
