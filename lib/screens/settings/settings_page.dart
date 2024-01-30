import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/location/location_state.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/points/points_state.dart';
import '../../utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
            title: Text(appLocalizations.information),
            backgroundColor: Colors.green),
        body: DefaultTextStyle(
          style: TextStyle(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
          child: FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, packageInfo) {
                return SettingsList(
                  lightTheme: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? const SettingsThemeData()
                      : settingsListDarkTheme,
                  sections: [
                    SettingsSection(
                      title: Text(appLocalizations.datasetHeading),
                      tiles: <SettingsTile>[
                        SettingsTile(
                          leading: const Icon(CupertinoIcons.location_solid),
                          title: Text(appLocalizations.defibrillatorsInDataset),
                          value: BlocBuilder<PointsCubit, PointsState>(
                              builder: (context, state) {
                            if (state is PointsLoadSuccess) {
                              return Text(state.aeds.length.toString());
                            }
                            return const Text('-');
                          }),
                        ),
                        SettingsTile(
                          leading: const Icon(CupertinoIcons.map),
                          title: Text(appLocalizations.defibrillatorsWithin5km),
                          value: BlocBuilder<LocationCubit, LocationState>(
                              builder: (context, locationState) {
                            return BlocBuilder<PointsCubit, PointsState>(
                                builder: (context, pointsState) {
                              if (locationState is LocationDetermined &&
                                  pointsState is PointsLoadSuccess) {
                                return Text(getDefibrillatorsWithin5KM(
                                        pointsState.aeds,
                                        locationState.location)
                                    .length
                                    .toString());
                              }
                              return const Text('-');
                            });
                          }),
                        )
                      ],
                    ),
                    SettingsSection(
                      title: Text(appLocalizations.about),
                      tiles: <SettingsTile>[
                        SettingsTile(
                          leading: const Icon(CupertinoIcons.info),
                          title: Text(appLocalizations.version),
                          value: Text(packageInfo.data?.version ?? '-'),
                        ),
                        SettingsTile.navigation(
                          onPressed: (context) {
                            launchUrl(Uri.parse('https://aedmapa.pl'));
                          },
                          leading: const Icon(CupertinoIcons.doc),
                          title: Text(appLocalizations.website),
                          value: const Text('aedmapa.pl'),
                        ),
                        SettingsTile(
                          leading: const Icon(CupertinoIcons.person),
                          title: Text(appLocalizations.author),
                          value: const Text('Mateusz Woźniak'),
                        ),
                        SettingsTile.navigation(
                          onPressed: (context) {
                            launchUrl(Uri.parse('mailto:mateusz@aedmapa.pl'));
                          },
                          leading: const Icon(CupertinoIcons.envelope),
                          title: Text(appLocalizations.contact),
                          value: const Text('mateusz@aedmapa.pl'),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ));
  }
}
