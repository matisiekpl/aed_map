import 'dart:async';
import 'package:aed_map/bloc/map_style/map_style_cubit.dart';
import 'package:aed_map/bloc/map_style/map_style_state.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/screens/edit_form.dart';
import 'package:aed_map/screens/loading_widget.dart';
import 'package:aed_map/utils.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hue_rotation/hue_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../main.dart';
import '../models/aed.dart';
import '../models/trip.dart';
import '../store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final PanelController panel = PanelController();
  final MapController mapController = MapController();
  final SuperclusterMutableController markersController =
      SuperclusterMutableController();

  Brightness? _brightness;

  @override
  void initState() {
    super.initState();
    _initAsync();
    analytics.event();
  }

  LatLng? _position;

  _initAsync() async {
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkNetwork();
    });
    // if (selectedAED != null) _navigate(selectedAED!, init: true);
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

  List<Marker> _getMarkers(List<AED> aeds) {
    return aeds
        .map((aed) {
          if (aed.access == 'yes') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset('assets/green_aed.svg')),
            );
          }
          if (aed.access == 'customers') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset('assets/yellow_aed.svg')),
            );
          }
          if (aed.access == 'private' || aed.access == 'permissive') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset('assets/blue_aed.svg')),
            );
          }
          if (aed.access == 'no') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset('assets/red_aed.svg')),
            );
          }
          if (aed.access == 'unknown') {
            return Marker(
              point: aed.location,
              key: Key(aeds.indexOf(aed).toString()),
              builder: (ctx) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset('assets/grey_aed.svg')),
            );
          }
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/green_aed.svg')),
          );
        })
        .cast<Marker>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
      if (state is PointsStateLoading) {
        return const LoadingWidget();
      }
      if (state is PointsStateLoaded) {
        return Stack(
          children: [
            SlidingUpPanel(
                controller: panel,
                maxHeight: 500,
                borderRadius: radius,
                parallaxEnabled: true,
                parallaxOffset: 0.5,
                onPanelSlide: (value) {
                  setState(() {
                    _floatingPanelPosition = value;
                  });
                },
                panelBuilder: (ScrollController sc) => AnimatedContainer(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: _brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                    duration: const Duration(milliseconds: 300),
                    child: _buildBottomPanel(sc)),
                body: SafeArea(top: false, bottom: false, child: _buildMap())),
            SafeArea(child: _buildHeader()),
            SafeArea(child: _buildFloatingPanel()),
            _editMode
                ? SafeArea(child: _buildMarkerSelectionFooter())
                : Container()
          ],
        );
      }
      return Container();
    }));
  }

  double _floatingPanelPosition = 0;

  Widget _buildFloatingPanel() {
    bool isDarkMode = _brightness == Brightness.dark;
    return Builder(builder: (context) {
      if (_trip == null) return Container();
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _floatingPanelPosition * 400 + 84),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    _animatedMapMove(
                        await Store.instance.determinePosition(), 18);
                  },
                  child: Card(
                      color: isDarkMode ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(128),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12),
                        child: Row(
                          children: [
                            Text(_translateTimeAndLength(),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black)),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 32,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    color: Colors.red,
                                    child: Text(
                                        AppLocalizations.of(context)!.stop,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white)),
                                    onPressed: () {
                                      setState(() {
                                        _isRouting = false;
                                        _trip = null;
                                      });
                                      mapController.rotate(0);
                                      panel.open();
                                    }),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ],
            ),
          )
        ],
      );
    });
  }

  Widget _buildMarkerSelectionFooter() {
    return AnimatedOpacity(
      opacity: _editMode ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(AppLocalizations.of(context)!.chooseLocation,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _editMode = false;
                            });
                            panel.show();
                          },
                          color: Colors.white,
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(color: Colors.black))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                          onPressed: () async {
                            AED aed = AED(
                                LatLng(mapController.center.latitude,
                                    mapController.center.longitude),
                                0,
                                '',
                                false,
                                '',
                                '',
                                '',
                                'yes');
                            AED newAed = await Navigator.of(context).push(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        EditForm(aed: aed, isEditing: false)));
                            // aeds.add(newAed);
                            setState(() {
                              _editMode = false;
                            });
                            // markersController.replaceAll(_getMarkers());
                            await panel.show();
                            _selectAED(newAed);
                          },
                          color: Colors.green,
                          child: Text(AppLocalizations.of(context)!.next)),
                    )
                  ],
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                        offset: const Offset(0, -36),
                        child: SvgPicture.asset('assets/pin.svg', height: 36))
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool _editMode = false;

  Widget _buildBottomPanel(ScrollController sc) {
    bool isDarkMode = _brightness == Brightness.dark;
    return BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
      if (state is PointsStateLoading) {
        return Container();
      }
      if (state is PointsStateLoaded) {
        return ListView(
          padding: const EdgeInsets.all(0),
          controller: sc,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 24.0),
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (state.aeds.first == state.selected)
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _selectAED(state.aeds.first);
                          },
                          child: Text(
                              '⚠️ ${AppLocalizations.of(context)!.closestAED}',
                              key: const Key('closestAed'),
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 18)),
                        ),
                      if (state.aeds.first != state.selected)
                        GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _selectAED(state.aeds.first);
                            },
                            child: Text(
                                '⚠️ ${AppLocalizations.of(context)!.closerAEDAvailable}',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 18))),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (!await Store.instance.authenticate()) return;
                          AED updatedAed = await Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) => EditForm(
                                      aed: state.selected, isEditing: true)));

                          int index = state.aeds
                              .indexWhere((x) => x.id == updatedAed.id);
                          state.aeds[index] = updatedAed;
                          setState(() {
                            _editMode = false;
                          });
                          markersController.replaceAll(_getMarkers(state.aeds));
                          await panel.show();
                          _selectAED(updatedAed);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4, bottom: 4),
                              child: Text(AppLocalizations.of(context)!.edit,
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black)),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: state.selected.getColor(),
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
                                        'assets/${state.selected.getIconFilename()}',
                                        width: 32)),
                                const SizedBox(width: 6),
                                Text(
                                    AppLocalizations.of(context)!.defibrillator,
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: state.selected.getColor() ==
                                                Colors.yellow
                                            ? Colors.black
                                            : Colors.white))
                              ],
                            ),
                            const SizedBox(height: 8),
                            CrossFade<String>(
                                duration: const Duration(milliseconds: 200),
                                value: toNullableString(state.selected
                                        .getAccessComment(context)) ??
                                    AppLocalizations.of(context)!.noData,
                                builder: (context, v) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${AppLocalizations.of(context)!.access}: ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  state.selected.getColor() ==
                                                          Colors.yellow
                                                      ? Colors.black
                                                      : Colors.white)),
                                      Text(v,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  state.selected.getColor() ==
                                                          Colors.yellow
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
                      value: toNullableString(state.selected.description) ??
                          AppLocalizations.of(context)!.noData,
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
                      value: toNullableString(state.selected.operator) ??
                          AppLocalizations.of(context)!.noData,
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
                      value: toNullableString(formatOpeningHours(
                              state.selected.openingHours)) ??
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
                      value: state.selected.indoor,
                      builder: (context, v) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                '${AppLocalizations.of(context)!.insideBuilding}: ',
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
                      value: toNullableString(state.selected.phone) ??
                          AppLocalizations.of(context)!.noData,
                      builder: (context, v) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            launchUrl(Uri.parse(
                                'tel:${state.selected.phone.toString().replaceAll(' ', '')}'));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${AppLocalizations.of(context)!.contact}: ',
                                  style: const TextStyle(fontSize: 16)),
                              Text(v,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: IgnorePointer(
                        ignoring: _isRouting || !_isConnected,
                        child: Opacity(
                          opacity: (_isRouting || !_isConnected) ? 0.5 : 1,
                          child: CupertinoButton.filled(
                              key: const Key('navigate'),
                              onPressed: () async {
                                _navigate(state.selected);
                              },
                              child: Text(_isConnected
                                  ? (_isRouting
                                      ? AppLocalizations.of(context)!
                                          .calculatingRoute
                                      : AppLocalizations.of(context)!.navigate)
                                  : AppLocalizations.of(context)!.noNetwork)),
                        ),
                      )),
                  const SizedBox(height: 12),
                  // aed.image != null
                  //     ? Column(children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Opacity(
                  //                 opacity: 0.5,
                  //                 child: Text(AppLocalizations.of(context)!
                  //                     .imageOfDefibrillator)),
                  //           ],
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Padding(
                  //           padding: const EdgeInsets.only(bottom: 24),
                  //           child: ClipRRect(
                  //               borderRadius:
                  //                   const BorderRadius.all(Radius.circular(8)),
                  //               child: CachedNetworkImage(
                  //                   imageUrl: aed.image ??
                  //                       'https://f003.backblazeb2.com/file/aedphotos/warszawaUM1285.jpg')),
                  //         )
                  //       ])
                  //     : Padding(
                  //         padding: const EdgeInsets.only(bottom: 36.0),
                  //         child: GestureDetector(
                  //           behavior: HitTestBehavior.translucent,
                  //           onTap: () {
                  //             _pickImage();
                  //           },
                  //           child: DottedBorder(
                  //             color: isDarkMode ? Colors.white : Colors.grey,
                  //             dashPattern: const [7, 7],
                  //             borderType: BorderType.RRect,
                  //             radius: const Radius.circular(6),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: const [
                  //                     Text('Dodaj zdjęcie',
                  //                         style: TextStyle(color: Colors.grey))
                  //                   ]),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                ],
              ),
            ),
          ],
        );
      }
      return Container();
    });
  }

  _navigate(AED aed, {bool init = false}) async {
    analytics.event(name: 'navigate');
    setState(() {
      _isRouting = true;
    });
    var route = await Store.instance.navigate(_position!, aed);
    setState(() {
      _trip = route;
      _isRouting = false;
    });
    panel.close();
    var start = decodePolyline(_trip!.shape, accuracyExponent: 6)
        .unpackPolyline()
        .first;
    if (!init) _animatedMapMove(LatLng(start.latitude, start.longitude), 18);
  }

  final ImagePicker picker = ImagePicker();

  // Future<void> _pickImage() async {
  //   await showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Dodaj zdjęcie defibrylatora'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: const <Widget>[
  //               Text('Postaraj się, aby defibrylator był na środku zdjęcia'),
  //               Text(
  //                   'Zapisanie zdjęcia w bazie danych wymaga zalogowania kontem OSM'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Rozumiem'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   // if (!await Store.instance.authenticate()) return;
  //   final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
  //   if (photo == null) return;
  //   var link = await Store.instance.uploadImage(photo.path);
  //   setState(() {
  //     selectedAED!.image = link;
  //   });
  //   panel.open();
  // }

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

  String? toNullableString(String? input) {
    if (input == null) return null;
    if (input.isEmpty) return null;
    return input;
  }

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

  Trip? _trip;
  bool _isRouting = false;

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
                        center: snapshot.data,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        zoom: 18,
                        maxZoom: 18,
                        minZoom: 8,
                      ),
                      children: [
                        HueRotation(
                          degrees: isDarkMode ? 180 : 0,
                          child: Builder(builder: (context) {
                            var map = BlocBuilder<MapStyleCubit, MapStyleState>(
                              builder: (BuildContext context, state) {
                                var style = state.style;
                                if (style == null) return Container();
                                return VectorTileLayer(
                                    tileProviders: style.providers,
                                    theme: style.theme,
                                    maximumZoom: 22,
                                    tileOffset: TileOffset.mapbox,
                                    layerMode: VectorTileLayerMode.vector);
                              },
                            );
                            if (!isDarkMode) return map;
                            return ColorFiltered(
                              colorFilter: invert,
                              child: map,
                            );
                          }),
                        ),
                        if (_trip != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                  points: decodePolyline(_trip!.shape,
                                          accuracyExponent: 6)
                                      .unpackPolyline(),
                                  color: Colors.blue,
                                  strokeWidth: 5,
                                  isDotted: true),
                            ],
                          ),
                        CurrentLocationLayer(),
                        BlocBuilder<PointsCubit, PointsState>(
                            builder: (context, state) {
                          if (state is PointsStateLoaded) {
                            return SuperclusterLayer.mutable(
                              initialMarkers: _getMarkers(state.aeds),
                              loadingOverlayBuilder: (context) => Container(),
                              controller: markersController,
                              minimumClusterSize: 3,
                              onMarkerTap: (Marker marker) {
                                _selectAED(state.aeds[int.parse(marker.key
                                    .toString()
                                    .replaceAll('[<\'', '')
                                    .replaceAll('\'>]', ''))]);
                              },
                              clusterWidgetSize: const Size(40, 40),
                              anchor: AnchorPos.align(AnchorAlign.center),
                              clusterZoomAnimation:
                                  const AnimationOptions.animate(
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return Container();
                        }),
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
              BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
                if (state is PointsStateLoaded) {
                  return Text(
                      AppLocalizations.of(context)!
                          .subheading(state.aeds.length),
                      style: const TextStyle(fontSize: 14));
                } else {
                  return Text(AppLocalizations.of(context)!.subheading(0),
                      style: const TextStyle(fontSize: 14));
                }
              }),
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
                onTap: () async {
                  if (!await Store.instance.authenticate()) return;
                  panel.hide();
                  setState(() {
                    _editMode = true;
                  });
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
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  BetterFeedback.of(context).show((UserFeedback feedback) {
                    Store.instance.sendFeedback(feedback);
                  });
                },
                child: Card(
                  color: _brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.text_bubble,
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
    context.read<PointsCubit>().select(aed);
    setState(() {
      _trip = null;
    });
    panel.open();
    _animatedMapMove(aed.location, 16);
    analytics.event(name: 'select');
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

  String _translateTimeAndLength() {
    return '${(_trip!.time > 60 ? ('${(_trip!.time / 60).floor()} ${AppLocalizations.of(context)!.minutes}') : ('${_trip!.time.floor()} ${AppLocalizations.of(context)!.seconds}'))} (${(_trip!.length * 1000).floor()} ${AppLocalizations.of(context)!.meters})';
  }
}
