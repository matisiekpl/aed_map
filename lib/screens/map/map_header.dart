import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/screens/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                  return Text(appLocalizations.subheading(state.aeds.length),
                      style: const TextStyle(fontSize: 14));
                } else {
                  return Text(appLocalizations.subheading(0),
                      style: const TextStyle(fontSize: 14));
                }
              }),
              const SizedBox(height: 2),
              BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
                  builder: (context, state) {
                if (state.connected) return const SizedBox();
                return Text(appLocalizations.noNetwork,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold));
              })
            ],
          ),
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  mixpanel.track(aboutEvent);
                  var pointsCubit = context.read<PointsCubit>();
                  var locationCubit = context.read<LocationCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                              value: locationCubit,
                              child: BlocProvider.value(
                                  value: pointsCubit,
                                  child: const SettingsPage()),
                            )),
                  );
                },
                child: Card(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.gear,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(CupertinoIcons.wand_rays,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
