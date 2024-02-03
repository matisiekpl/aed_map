import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/location/location_cubit.dart';
import '../../bloc/location/location_state.dart';
import '../../bloc/network_status/network_status_state.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../bloc/routing/routing_cubit.dart';
import '../../bloc/routing/routing_state.dart';
import '../../models/aed.dart';
import '../../utils.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return BlocListener<PointsCubit, PointsState>(
      listener: (context, state) {
        if (state is PointsLoadSuccess) {
          context.read<PanelCubit>().open();
        }
      },
      child: BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
        if (state is PointsLoadInProgress) {
          return Container();
        }
        if (state is PointsLoadSuccess) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
            ),
            child: ListView(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              controller: scrollController,
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
                          if (state.aeds.first.id == state.selected.id)
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _selectAED(context, state.aeds.first);
                              },
                              child: Text('⚠️ ${appLocalizations.closestAED}',
                                  key: const Key('closestAed'),
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 18)),
                            ),
                          if (state.aeds.first.id != state.selected.id)
                            GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _selectAED(context, state.aeds.first);
                                },
                                child: Text(
                                    '⚠️ ${appLocalizations.closerAEDAvailable}',
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 18))),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              context.read<PanelCubit>().show();
                              context.read<EditCubit>().edit(state.selected);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  child: Text(appLocalizations.edit,
                                      style: TextStyle(
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
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
                                    Text(appLocalizations.defibrillator,
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
                                    value: state.selected
                                            .getAccessComment(appLocalizations)
                                            .purge() ??
                                        appLocalizations.noData,
                                    builder: (context, v) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("${appLocalizations.access}: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: state.selected
                                                              .getColor() ==
                                                          Colors.yellow
                                                      ? Colors.black
                                                      : Colors.white)),
                                          Text(v,
                                              key: const Key('access'),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: state.selected
                                                              .getColor() ==
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
                          value: state.selected.description.purge() ??
                              appLocalizations.noData,
                          builder: (context, v) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appLocalizations.location,
                                    style: const TextStyle(fontSize: 16)),
                                Text(v,
                                    key: const Key('description'),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            );
                          }),
                      const SizedBox(height: 4),
                      CrossFade<String>(
                          duration: const Duration(milliseconds: 200),
                          value: state.selected.operator.purge() ??
                              appLocalizations.noData,
                          builder: (context, v) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appLocalizations.operator,
                                    style: const TextStyle(fontSize: 16)),
                                Text(v,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            );
                          }),
                      const SizedBox(height: 4),
                      CrossFade<String>(
                          duration: const Duration(milliseconds: 200),
                          value: formatOpeningHours(state.selected.openingHours)
                                  .purge() ??
                              appLocalizations.noData,
                          builder: (context, v) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appLocalizations.openingHours,
                                    style: const TextStyle(fontSize: 16)),
                                Text(v,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
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
                                Text('${appLocalizations.insideBuilding}: ',
                                    style: const TextStyle(fontSize: 16)),
                                Text(
                                    v
                                        ? appLocalizations.yes
                                        : appLocalizations.no,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            );
                          }),
                      const SizedBox(height: 4),
                      CrossFade<String>(
                          duration: const Duration(milliseconds: 200),
                          value: state.selected.phone.purge() ??
                              appLocalizations.noData,
                          builder: (context, v) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (state.selected.phone.purge() != null) {
                                  launchUrl(Uri.parse(
                                      'tel:${state.selected.phone.toString().replaceAll(' ', '')}'));
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('${appLocalizations.contact}: ',
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
                          child: BlocBuilder<LocationCubit, LocationState>(
                              builder: (context, locationState) {
                            if (locationState is LocationDetermined) {
                              return BlocBuilder<RoutingCubit, RoutingState>(
                                  builder: (context, routingCubitState) {
                                if (routingCubitState
                                    is RoutingCalculatingInProgress) {
                                  return IgnorePointer(
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: CupertinoButton.filled(
                                          key:
                                              const Key('navigate_in_progress'),
                                          onPressed: () async {
                                            context
                                                .read<RoutingCubit>()
                                                .navigate(
                                                    locationState.location,
                                                    state.selected);
                                          },
                                          child: Text(appLocalizations
                                              .calculatingRoute)),
                                    ),
                                  );
                                }
                                return BlocBuilder<NetworkStatusCubit,
                                        NetworkStatusState>(
                                    builder: (context, networkState) {
                                  return CupertinoButton.filled(
                                      key: const Key('navigate'),
                                      onPressed: networkState.connected
                                          ? () async {
                                              context
                                                  .read<RoutingCubit>()
                                                  .navigate(
                                                      locationState.location,
                                                      state.selected);
                                            }
                                          : null,
                                      child: Text(networkState.connected
                                          ? appLocalizations.navigate
                                          : appLocalizations.noNetwork));
                                });
                              });
                            }
                            return Container();
                          })),
                      const SizedBox(height: 12),
                      if ((state.selected.image ?? '').isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: state.selected.image ?? '',
                            placeholder: (context, url) => Container(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          );
        }
        return Container();
      }),
    );
  }

  _selectAED(BuildContext context, AED aed) async {
    context.read<RoutingCubit>().cancel();
    context.read<PointsCubit>().select(aed);
    context.read<PanelCubit>().show();
  }
}
