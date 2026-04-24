import 'dart:io';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/feedback/feedback_cubit.dart';
import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/location/location_state.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/screens/pending_changes/pending_changes_page.dart';
import 'package:aed_map/screens/settings/settings_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../generated/i18n/app_localizations.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    var livechatEnabled = Platform.environment.containsKey('FLUTTER_TEST')
        ? false
        : FirebaseRemoteConfig.instance.getBool('livechat');
    var appLocalizations = AppLocalizations.of(context)!;
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appLocalizations.heading,
                  key: const Key('title'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 32)),
              BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
                if (state is PointsLoadSuccess) {
                  return Text(
                      appLocalizations.subheading(state.defibrillators.length),
                      style: const TextStyle(fontSize: 14));
                } else {
                  return Text(appLocalizations.subheading(0),
                      style: const TextStyle(fontSize: 14));
                }
              }),
              const SizedBox(height: 2),
              Text('OpenStreetMap contributors', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              BlocBuilder<EditCubit, EditState>(builder: (context, editState) {
                if (editState.pendingChanges.isEmpty) return const SizedBox();
                var appLocalizations = AppLocalizations.of(context)!;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    var editCubit = context.read<EditCubit>();
                    var pointsCubit = context.read<PointsCubit>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: editCubit),
                            BlocProvider.value(value: pointsCubit),
                          ],
                          child: const PendingChangesPage(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      appLocalizations.pendingChangesBadge(editState.pendingChanges.length),
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 2),
              BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
                  builder: (context, state) {
                if (state.connected) return const SizedBox();
                return Text(appLocalizations.noNetwork,
                    style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemRed.resolveFrom(context),
                        fontWeight: FontWeight.bold));
              }),
              BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                if (state is! LocationDetermined || !state.permissionDenied) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appLocalizations.noLocationPermission,
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                CupertinoColors.systemRed.resolveFrom(context),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Geolocator.openAppSettings(),
                      child: Card(
                        color: CupertinoColors.secondarySystemBackground
                            .resolveFrom(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(appLocalizations.openSettings,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.label
                                      .resolveFrom(context))),
                        ),
                      ),
                    ),
                  ],
                );
              })
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  BlocListener<EditCubit, EditState>(
                    listener: (BuildContext context, state) {
                      if (state.enabled) {
                        context.read<PanelCubit>().hide();
                      }
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        context.read<EditCubit>().enter();
                      },
                      child: Card(
                          color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(appLocalizations.add,
                                style: TextStyle(fontWeight: FontWeight.w500, color: CupertinoColors.label.resolveFrom(context))),
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      mixpanel.track(aboutEvent);
                      var pointsCubit = context.read<PointsCubit>();
                      var locationCubit = context.read<LocationCubit>();
                      var feedbackCubit = context.read<FeedbackCubit>();
                      var editCubit = context.read<EditCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                                  value: locationCubit,
                                  child: BlocProvider.value(
                                    value: feedbackCubit,
                                    child: BlocProvider.value(
                                        value: pointsCubit,
                                        child: BlocProvider.value(
                                            value: editCubit,
                                            child: const SettingsPage())),
                                  ),
                                )),
                      );
                    },
                    child: Card(
                      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.gear,
                            color: CupertinoColors.label.resolveFrom(context)),
                      ),
                    ),
                  ),
                  if (livechatEnabled) const SizedBox(height: 8),
                  if (livechatEnabled)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        mixpanel.track(livechatEvent);
                        FirebaseAnalytics.instance
                            .logEvent(name: livechatEvent);
                        launchUrl(Uri.parse('https://pomoc.aedmapa.pl/'));
                      },
                      child: Card(
                        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(CupertinoIcons.question_circle,
                              color: CupertinoColors.label.resolveFrom(context)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          )
        ],
      ),
    ));
  }
}
