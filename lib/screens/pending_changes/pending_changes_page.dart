import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../generated/i18n/app_localizations.dart';
import '../../shared/utils.dart';

class PendingChangesPage extends StatelessWidget {
  const PendingChangesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.pendingChangesTitle),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<EditCubit, EditState>(
        builder: (context, state) {
          return SettingsList(
            lightTheme: MediaQuery.of(context).platformBrightness == Brightness.light
                ? const SettingsThemeData()
                : settingsListDarkTheme,
            sections: [
              SettingsSection(
                title: Text(appLocalizations.pendingChangesTitle),
                tiles: state.pendingChanges
                    .map((change) => buildChangeTile(context, change, appLocalizations))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  AbstractSettingsTile buildChangeTile(
      BuildContext context, PendingChange change, AppLocalizations appLocalizations) {
    final typeLabel = switch (change.type) {
      PendingChangeType.add => appLocalizations.pendingChangeTypeAdd,
      PendingChangeType.edit => appLocalizations.pendingChangeTypeEdit,
      PendingChangeType.delete => appLocalizations.pendingChangeTypeDelete,
    };

    final icon = switch (change.type) {
      PendingChangeType.add => const Icon(CupertinoIcons.plus_circle, color: Colors.green),
      PendingChangeType.edit => const Icon(CupertinoIcons.pencil_circle, color: Colors.orange),
      PendingChangeType.delete => const Icon(CupertinoIcons.trash_circle, color: Colors.red),
    };

    final description = change.snapshot.description ?? '';

    return SettingsTile(
      leading: icon,
      title: Text('$typeLabel${description.isNotEmpty ? ': $description' : ''}'),
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