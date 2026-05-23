import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../generated/i18n/app_localizations.dart';
import '../../shared/utils.dart';

class PendingChangesPage extends StatefulWidget {
  const PendingChangesPage({super.key});

  @override
  State<PendingChangesPage> createState() => _PendingChangesPageState();
}

class _PendingChangesPageState extends State<PendingChangesPage> {
  @override
  void initState() {
    super.initState();
    mixpanel.track(pendingChangesEvent);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(appLocalizations.pendingChangesTitle),
      ),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<EditCubit, EditState>(
          builder: (context, state) {
            return DefaultTextStyle.merge(
              style:
                  TextStyle(color: CupertinoColors.label.resolveFrom(context)),
              child: SettingsList(
                platform: DevicePlatform.iOS,
                applicationType: ApplicationType.cupertino,
                lightTheme: const SettingsThemeData(),
                darkTheme: settingsListDarkTheme,
                sections: [
                  SettingsSection(
                    title: Text(appLocalizations.pendingChangesTitle),
                    tiles: state.pendingChanges
                        .asMap()
                        .entries
                        .map((entry) => buildChangeTile(
                            context,
                            entry.value,
                            appLocalizations,
                            (entry.key + 1) == state.pendingChanges.length))
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AbstractSettingsTile buildChangeTile(BuildContext context,
      PendingChange change, AppLocalizations appLocalizations, bool last) {
    final typeLabel = switch (change.type) {
      PendingChangeType.add => appLocalizations.pendingChangeTypeAdd,
      PendingChangeType.edit => appLocalizations.pendingChangeTypeEdit,
      PendingChangeType.delete => appLocalizations.pendingChangeTypeDelete,
    };

    final icon = switch (change.type) {
      PendingChangeType.add =>
        const Icon(CupertinoIcons.plus_circle, color: Colors.green),
      PendingChangeType.edit =>
        const Icon(CupertinoIcons.pencil_circle, color: Colors.orange),
      PendingChangeType.delete =>
        const Icon(CupertinoIcons.trash_circle, color: Colors.red),
    };

    final locationDescription = change.snapshot.locationDescription ?? '';
    final level = change.snapshot.level;
    final indoor = change.snapshot.indoor;
    final operator = change.snapshot.operator;
    final openingHours = change.snapshot.openingHours;
    final phone = change.snapshot.phone;
    final description = change.snapshot.description;
    
    List<String> details = [];
    if (locationDescription.isNotEmpty) details.add(locationDescription);
    if (indoor != null && indoor == 'yes') details.add(appLocalizations.insideBuilding);
    if (level != null && level.isNotEmpty) details.add('${appLocalizations.level}: $level');
    if (operator != null && operator.isNotEmpty) details.add('${appLocalizations.operator}: $operator');
    if (openingHours != null && openingHours.isNotEmpty) details.add('${appLocalizations.openingHours}: $openingHours');
    if (phone != null && phone.isNotEmpty) details.add('${appLocalizations.contact}: $phone');
    if (description != null && description.isNotEmpty) details.add('${appLocalizations.information}: $description');

    final subtitleText = details.join(' • ');

    return SettingsTile(
      leading: icon,
      title: Text(typeLabel),
      description: Text(subtitleText.isNotEmpty 
          ? (last ? '$subtitleText\n${appLocalizations.pendingChangesProcessingInfo}' : subtitleText)
          : (last ? appLocalizations.pendingChangesProcessingInfo : '')),
      onPressed: (context) {
        final pointsCubit = context.read<PointsCubit>();
        final state = pointsCubit.state;
        Defibrillator target = change.snapshot;
        if (state is PointsLoadSuccess) {
          target = state.defibrillators.firstWhere(
            (defibrillator) => defibrillator.id == change.defibrillatorId,
            orElse: () => change.snapshot,
          );
        }
        Navigator.of(context).pop();
        pointsCubit.select(target);
      },
    );
  }
}
