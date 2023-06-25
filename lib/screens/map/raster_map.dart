import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:hue_rotation/hue_rotation.dart';
import 'package:latlong2/latlong.dart';

import '../../bloc/location/location_cubit.dart';
import '../../bloc/location/location_state.dart';
import '../../bloc/map_style/map_style_cubit.dart';
import '../../bloc/map_style/map_style_state.dart';
import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../bloc/routing/routing_state.dart';
import '../../shared/cached_network_tile_provider.dart';
import '../../utils.dart';

class RasterMap extends StatefulWidget {
  const RasterMap({super.key});

  @override
  State<RasterMap> createState() => _RasterMapState();
}

class _RasterMapState extends State<RasterMap> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  final SuperclusterMutableController markersController = SuperclusterMutableController();

  bool isMapInitialized = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (BuildContext context, state) {
        if (state is LocationDetermined) {
          _animatedMapMove(state.center, 18);
        }
      },
      child: BlocListener<PointsCubit, PointsState>(
        listener: (BuildContext context, PointsState state) {
          if (state is PointsLoadSuccess) {
            _animatedMapMove(state.selected.location, 18);
          }
        },
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              Flexible(
                  child: Stack(
                children: [
                  BlocBuilder<LocationCubit, LocationState>(builder: (context, state) {
                    if (state is LocationDetermined) {
                      return FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          onPositionChanged: (MapPosition position, bool gesture) {
                            var center = position.center;
                            if (center != null) {
                              context.read<EditCubit>().moveCursor(center);
                            }
                          },
                          onMapReady: () {
                            isMapInitialized = true;
                            context.read<EditCubit>().moveCursor(mapController.center);
                          },
                          center: state.location,
                          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          zoom: 18,
                          maxZoom: 18,
                          minZoom: 8,
                        ),
                        children: [
                          HueRotation(
                            degrees: MediaQuery.of(context).platformBrightness == Brightness.dark ? 180 : 0,
                            child: Builder(builder: (context) {
                              var map = BlocBuilder<MapStyleCubit, MapStyleState>(
                                builder: (BuildContext context, state) {
                                  var style = state.style;
                                  if (style == null) return Container();
                                  return TileLayer(
                                    userAgentPackageName: 'pl.enteam.aed_map',
                                    tileProvider: CachedNetworkTileProvider(),
                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  );
                                },
                              );
                              if (MediaQuery.of(context).platformBrightness != Brightness.dark) return map;
                              return ColorFiltered(
                                colorFilter: invert,
                                child: map,
                              );
                            }),
                          ),
                          BlocListener<RoutingCubit, RoutingState>(
                            listener: (BuildContext context, RoutingState state) {
                              if (state is RoutingSuccess) {
                                context.read<PanelCubit>().cancel();
                                var start =
                                    decodePolyline(state.trip.shape, accuracyExponent: 6).unpackPolyline().first;
                                _animatedMapMove(LatLng(start.latitude, start.longitude), 18);
                              }
                            },
                            child: BlocBuilder<RoutingCubit, RoutingState>(builder: (context, state) {
                              if (state is RoutingSuccess) {
                                return PolylineLayer(
                                  polylines: [
                                    Polyline(
                                        points: decodePolyline(state.trip.shape, accuracyExponent: 6).unpackPolyline(),
                                        color: Colors.blue,
                                        strokeWidth: 5,
                                        isDotted: true),
                                  ],
                                );
                              }
                              return Container();
                            }),
                          ),
                          CurrentLocationLayer(),
                          BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
                            if (state is PointsLoadSuccess) {
                              markersController.replaceAll(state.markers);
                              return SuperclusterLayer.mutable(
                                initialMarkers: state.markers,
                                loadingOverlayBuilder: (context) => Container(),
                                controller: markersController,
                                minimumClusterSize: 3,
                                onMarkerTap: (Marker marker) {
                                  var aed = state.aeds[
                                      int.parse(marker.key.toString().replaceAll('[<\'', '').replaceAll('\'>]', ''))];
                                  context.read<RoutingCubit>().cancel();
                                  context.read<PointsCubit>().select(aed);
                                },
                                clusterWidgetSize: const Size(40, 40),
                                anchor: AnchorPos.align(AnchorAlign.center),
                                clusterZoomAnimation: const AnimationOptions.animate(
                                  curve: Curves.linear,
                                  velocity: 1,
                                ),
                                calculateAggregatedClusterData: true,
                                builder: (context, position, markerCount, extraClusterData) {
                                  return Container(
                                    decoration:
                                        BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.brown),
                                    child: Center(
                                      child: Text(
                                        markerCount.toString(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Container();
                          }),
                        ],
                      );
                    }
                    return Container();
                  }),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!isMapInitialized) {
      return;
    }
    final latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
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
}
