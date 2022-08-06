import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../constants.dart';
import '../models/aed.dart';
import '../store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<AED> aeds = [];
  AED? selectedAED;
  final PanelController panel = PanelController();
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  _initAsync() async {
    var position = await Store.instance.determinePosition();
    var _aeds = await Store.instance.loadAEDs(LatLng(position.latitude, position.longitude));
    setState(() {
      aeds = _aeds;
      selectedAED = aeds.first;
    });
  }

  List<DragMarker> _getMarkers() {
    return aeds
        .map((aed) => DragMarker(
              point: aed.location,
              onTap: (pos) {
                _selectAED(aed);
              },
              builder: (ctx) {
                return aed.id == selectedAED!.id ? Icon(Icons.pin_drop, color: Colors.orange, size: 38) : Icon(Icons.pin_drop, color: Colors.red, size: 38);
                // ? Container(child: SvgPicture.asset(key: const ValueKey('assets/map-pin-orange.svg'), 'assets/map-pin-orange.svg', color: Colors.red, semanticsLabel: 'A red up arrow'))
                // : SvgPicture.asset('assets/map-pin.svg', color: Colors.red, semanticsLabel: 'A red up arrow');
              },
            ))
        .cast<DragMarker>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: aeds.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SlidingUpPanel(
                controller: panel,
                maxHeight: 500,
                borderRadius: radius,
                panel: Container(decoration: BoxDecoration(borderRadius: radius), child: _buildBottomPanel()),
                body: SafeArea(child: _buildMap(), top: false)));
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
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (aeds.first == selectedAED) Text('⚠️ Najbliższy AED', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 18)),
                if (aeds.first != selectedAED)
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _selectAED(aeds.first);
                      },
                      child: Text('⚠️ Dostępny jest bliższy AED', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 18))),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text('🫀 Defibrylator AED', style: TextStyle(fontSize: 24))],
            ),
            SizedBox(height: 8),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.description ?? 'brak danych',
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dokładna lokalizacja: ', style: TextStyle(fontSize: 16)),
                      Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.operator ?? 'brak danych',
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Operator: ', style: TextStyle(fontSize: 16)),
                      Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.openingHours ?? 'brak danych',
                builder: (context, v) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Godziny otwarcia: ', style: TextStyle(fontSize: 16)),
                      Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            SizedBox(height: 4),
            CrossFade<bool>(
                duration: const Duration(milliseconds: 200),
                value: aed.indoor,
                builder: (context, v) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Wewnątrz budynku: ', style: TextStyle(fontSize: 16)),
                      Text(v ? 'tak' : 'nie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            SizedBox(height: 4),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: aed.phone ?? 'brak danych',
                builder: (context, v) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('Calling to: tel:${aed.phone.toString().replaceAll(' ', '')}');
                      launchUrl(Uri.parse('tel:${aed.phone.toString().replaceAll(' ', '')}'));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Kontakt: ', style: TextStyle(fontSize: 16)),
                        Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
            SizedBox(height: 4),
            CrossFade<int>(
                duration: const Duration(milliseconds: 200),
                value: aed.id,
                builder: (context, v) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Identyfikator: ', style: TextStyle(fontSize: 16)),
                      Text(v.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (BuildContext context) {
                    var message = 'Szer: ${aed.location.latitude}';
                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                      return TextButton(
                          child: Text(message, style: TextStyle(fontSize: 16, color: Colors.black)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: aed.location.latitude.toString()));
                            setState(() {
                              message = 'Skopiowano';
                            });
                            Future.delayed(const Duration(milliseconds: 2000), () {
                              setState(() {
                                message = 'Dł: ${aed.location.latitude}';
                              });
                            });
                          });
                    });
                  }),
                  Builder(builder: (BuildContext context) {
                    var message = 'Dł: ${aed.location.longitude}';
                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                      return TextButton(
                          child: Text(message, style: TextStyle(fontSize: 16, color: Colors.black)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: aed.location.longitude.toString()));
                            setState(() {
                              message = 'Skopiowano';
                            });
                            Future.delayed(const Duration(milliseconds: 2000), () {
                              setState(() {
                                message = 'Dł: ${aed.location.longitude}';
                              });
                            });
                          });
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                      child: Text('Nawiguj'),
                      onPressed: () {
                        _openMap(aed.location.latitude, aed.location.longitude);
                        // MapsLauncher.launchCoordinates(aed.location.latitude, aed.location.longitude);
                      })),
            ),
            SizedBox(height: 12),
            CrossFade<String>(
                duration: const Duration(milliseconds: 200),
                value: _translateMeters(selectedAED!.distance!),
                builder: (context, v) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(v, style: TextStyle(color: Colors.orange)),
                    ],
                  );
                })
          ],
        ),
      )
    ]);
  }

  Widget _buildMap() {
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
                          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          zoom: 14,
                          maxZoom: 18,
                          minZoom: 8,
                          plugins: [VectorMapTilesPlugin(), LocationMarkerPlugin(), DragMarkerPlugin()]),
                      layers: <LayerOptions>[
                        TileLayerOptions(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'pl.enteam.aed_map',
                        ),
                        // VectorTileLayerOptions(theme: _getMapTheme(context), tileProviders: TileProviders({'openmaptiles': Store.instance.buildCachingTileProvider()})),
                        LocationMarkerLayerOptions(),
                        DragMarkerPluginOptions(markers: _getMarkers()),
                      ],
                    ),
                    SafeArea(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('Mapa AED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)), Text('${aeds.length} AED dostępnych', style: TextStyle(fontSize: 14))],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showAboutDialog();
                                },
                                child: const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(CupertinoIcons.gear),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
                  ],
                )),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  _selectAED(AED aed) {
    setState(() {
      selectedAED = aed;
    });
    panel.open();
    _animatedMapMove(selectedAED!.location, 14);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude - 0.009);
    final lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      mapController.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
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
      applicationIcon: const Image(image: AssetImage('assets/icon.png'), width: 64),
      applicationName: 'Mapa AED',
      applicationVersion: 'v1.0.0',
      applicationLegalese: 'By Mateusz Woźniak',
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 15), child: Text('Dane o lokalizacjach AED pochodzą z projektu aed.openstreetmap.org.pl')),
      ],
    );
  }

  _getMapTheme(BuildContext context) {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    return ProvidedThemes.lightTheme();
  }

  String _translateMeters(int distance) {
    if (distance > 10000) return 'około ${(distance / 1000).floor()}km stąd';
    return '~${(distance / 200).ceil().toString()} minut biegiem (${distance.toString()}m)';
  }

  _openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
