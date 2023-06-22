import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hue_rotation/hue_rotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../bloc/location/location_cubit.dart';
import '../../bloc/location/location_state.dart';
import '../../bloc/map_style/map_style_cubit.dart';
import '../../bloc/map_style/map_style_state.dart';
import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../bloc/routing/routing_state.dart';
import '../../models/aed.dart';
import '../../utils.dart';

class VectorMap extends StatefulWidget {
  const VectorMap({super.key});

  @override
  State<VectorMap> createState() => _VectorMapState();
}

class _VectorMapState extends State<VectorMap> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  final SuperclusterMutableController markersController =
      SuperclusterMutableController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PointsCubit,PointsState>(
      listener: (BuildContext context, PointsState state) {
        if(state is PointsStateLoaded) {
          _animatedMapMove(state.selected.location, 18);
        }
      },
      child: SafeArea(
        top: false, bottom: false,
        child: Column(
          children: [
            Flexible(
                child: Stack(
              children: [
                BlocBuilder<LocationCubit, LocationState>(
                    builder: (context, state) {
                  if (state is LocationStateLocated) {
                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: state.location,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        zoom: 18,
                        maxZoom: 18,
                        minZoom: 8,
                      ),
                      children: [
                        HueRotation(
                          degrees: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? 180
                              : 0,
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
                            if (MediaQuery.of(context).platformBrightness !=
                                Brightness.dark) return map;
                            return ColorFiltered(
                              colorFilter: invert,
                              child: map,
                            );
                          }),
                        ),
                        BlocListener<RoutingCubit, RoutingState>(
                          listener: (BuildContext context, RoutingState state) {
                            if (state is RoutingStateShowing) {
                              context.read<PanelCubit>().cancel();
                              var start = decodePolyline(state.trip.shape,
                                      accuracyExponent: 6)
                                  .unpackPolyline()
                                  .first;
                              _animatedMapMove(
                                  LatLng(start.latitude, start.longitude), 18);
                            }
                          },
                          child: BlocBuilder<RoutingCubit, RoutingState>(
                              builder: (context, state) {
                            if (state is RoutingStateShowing) {
                              return PolylineLayer(
                                polylines: [
                                  Polyline(
                                      points: decodePolyline(state.trip.shape,
                                              accuracyExponent: 6)
                                          .unpackPolyline(),
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
                        BlocBuilder<PointsCubit, PointsState>(
                            builder: (context, state) {
                          if (state is PointsStateLoaded) {
                            return SuperclusterLayer.mutable(
                              initialMarkers: _getMarkers(state.aeds),
                              loadingOverlayBuilder: (context) => Container(),
                              controller: markersController,
                              minimumClusterSize: 3,
                              onMarkerTap: (Marker marker) {
                                var aed = state.aeds[int.parse(marker.key
                                    .toString()
                                    .replaceAll('[<\'', '')
                                    .replaceAll('\'>]', ''))];
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
    );
  }

  List<Marker> _getMarkers(List<AED> aeds) => aeds
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
}
