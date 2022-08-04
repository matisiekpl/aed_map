import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  List<AED> aeds = [];
  AED? selectedAED;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  _initAsync() async {
    var _aeds = await Store.instance.loadAEDs();
    setState(() {
      aeds = _aeds;
      selectedAED = aeds[0];
    });
  }

  List<Marker> _getMarkers() {
    return aeds.map((aed) => Marker(point: aed.location, builder: (context) => SvgPicture.asset('assets/map-pin.svg', color: Colors.red, semanticsLabel: 'A red up arrow'))).cast<Marker>().toList();
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
                maxHeight: 400, borderRadius: radius, panel: Container(decoration: BoxDecoration(borderRadius: radius), child: _buildBottomPanel()), body: SafeArea(child: _buildMap(), top: false)));
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
                Text('⚠️ Najbliższy AED', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text('🫀 Defibrylator AED', style: TextStyle(fontSize: 24))],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Dokładna lokalizacja: ', style: TextStyle(fontSize: 16)),
                Text(aed.description ?? 'brak danych', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Wewnątrz budynku: ', style: TextStyle(fontSize: 16)),
                Text(aed.indoor ? 'tak' : 'nie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Operator: ', style: TextStyle(fontSize: 16)),
                Text(aed.operator ?? 'brak danych', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                print('Calling to: tel:${aed.phone.toString().replaceAll(' ', '')}');
                launchUrl(Uri.parse('tel:${aed.phone.toString().replaceAll(' ', '')}'));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Kontakt: ', style: TextStyle(fontSize: 16)),
                  Text(aed.phone ?? 'brak danych', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Identyfikator: ', style: TextStyle(fontSize: 16)),
                Text(aed.id.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
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
                        MapsLauncher.launchCoordinates(aed.location.latitude, aed.location.longitude);
                      })),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('~9 minut biegiem (450m)', style: TextStyle(color: Colors.orange)),
              ],
            )
          ],
        ),
      )
    ]);
  }

  Widget _buildMap() {
    return FutureBuilder<Position>(
        future: Store.instance.determinePosition(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData || snapshot.hasError) {
            return Column(
              children: [
                Flexible(
                    child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                          center: snapshot.hasData ? LatLng(snapshot.data!.latitude, snapshot.data!.longitude) : warsaw,
                          zoom: 14,
                          maxZoom: 18,
                          plugins: [VectorMapTilesPlugin(), LocationMarkerPlugin()]),
                      // options: MapOptions(center: warsaw, zoom: 14, maxZoom: 18, plugins: [VectorMapTilesPlugin()]),
                      layers: <LayerOptions>[
                        VectorTileLayerOptions(theme: _getMapTheme(context), tileProviders: TileProviders({'openmaptiles': Store.instance.buildCachingTileProvider()})),
                        MarkerLayerOptions(markers: _getMarkers()),
                        LocationMarkerLayerOptions(),
                      ],
                    ),
                    SafeArea(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mapa AED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                          Text('${aeds.length} AED dostępnych', style: TextStyle(fontSize: 14))
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

  _getMapTheme(BuildContext context) {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    return ProvidedThemes.lightTheme();
  }
}
