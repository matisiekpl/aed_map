// ignore_for_file: use_build_context_synchronously

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/repositories/user_created_defibrillator_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/points/points_cubit.dart';
import '../../generated/i18n/app_localizations.dart';
import '../../models/aed.dart';
import '../../shared/utils.dart';

class EditForm extends StatelessWidget {
  const EditForm({super.key});

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(appLocalizations.editDefibrillator),
      ),
      child: Theme(
          data: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          child: BlocConsumer<EditCubit, EditState>(
            listenWhen: (previous, current) => current.errorMessage != null,
            listener: (context, state) {
              final message = resolveErrorMessage(state.errorMessage!, appLocalizations);
              showCupertinoDialog(
                context: context,
                builder: (dialogContext) => CupertinoAlertDialog(
                  content: Text(message),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            builder: (context, state) {
              if (state is EditInProgress) {
                return SafeArea(
                  bottom: false,
                  child: FutureBuilder<bool>(
                    future: UserCreatedDefibrillatorRepository()
                        .contains(state.defibrillator.id),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return DefaultTextStyle.merge(
                          style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
                          child: SettingsList(
                            platform: DevicePlatform.iOS,
                            applicationType: ApplicationType.cupertino,
                            lightTheme: const SettingsThemeData(),
                            darkTheme: settingsListDarkTheme,
                            sections: buildSections(context, state, snap.data!),
                          ),
                        );
                      }
                      return const Center(child: CupertinoActivityIndicator());
                    },
                  ),
                );
              }
              return Container();
            },
          )),
    );
  }

  String resolveErrorMessage(String errorCode, AppLocalizations appLocalizations) {
    if (errorCode == 'osmErrorUnauthorized') return appLocalizations.osmErrorUnauthorized;
    if (errorCode == 'osmErrorNotFound') return appLocalizations.osmErrorNotFound;
    if (errorCode == 'osmErrorConflict') return appLocalizations.osmErrorConflict;
    if (errorCode.startsWith('osmErrorGeneric:')) {
      final rest = errorCode.substring('osmErrorGeneric:'.length);
      final separatorIndex = rest.indexOf(':');
      final codeString = separatorIndex == -1 ? rest : rest.substring(0, separatorIndex);
      final body = separatorIndex == -1 ? '' : rest.substring(separatorIndex + 1);
      final code = int.tryParse(codeString) ?? 0;
      final base = appLocalizations.osmErrorGeneric(code);
      return body.isEmpty ? base : '$base\n\n$body';
    }
    return errorCode;
  }

  List<AbstractSettingsSection> buildSections(
      BuildContext context, EditInProgress state, bool isUserCreated) {
    var appLocalizations = AppLocalizations.of(context)!;
    return [
      SettingsSection(
        title: Text(appLocalizations.information),
        tiles: <AbstractSettingsTile>[
          SettingsTile(
            leading: const Icon(CupertinoIcons.placemark),
            title: TextFormField(
              initialValue: state.defibrillator.description,
              onChanged: context.read<EditCubit>().editDescription,
              decoration: InputDecoration.collapsed(
                  hintText: appLocalizations.enterDescription),
            ),
          ),
          SettingsTile.navigation(
            leading: const Icon(CupertinoIcons.arrow_clockwise_circle),
            title: Text(appLocalizations.access),
            value: Text(translateAccessComment(state.access, appLocalizations)),
            onPressed: (_) {
              selectAccess(context, appLocalizations, context.read<EditCubit>());
            },
          ),
          SettingsTile.switchTile(
            onToggle: context.read<EditCubit>().editIndoor,
            initialValue: state.defibrillator.indoor == 'yes',
            leading: const Icon(CupertinoIcons.home),
            title: Text(appLocalizations.insideBuilding),
          ),
          SettingsTile(
            leading: const Icon(CupertinoIcons.person_2),
            title: TextFormField(
              initialValue: state.defibrillator.operator,
              onChanged: context.read<EditCubit>().editOperator,
              decoration: InputDecoration.collapsed(
                  hintText: appLocalizations.enterOperator),
            ),
          ),
          SettingsTile(
            leading: const Icon(CupertinoIcons.phone),
            title: TextFormField(
              initialValue: state.defibrillator.phone,
              onChanged: context.read<EditCubit>().editPhone,
              decoration: InputDecoration.collapsed(
                  hintText: appLocalizations.enterPhone),
            ),
          ),
        ],
      ),
      SettingsSection(
        title: Text(appLocalizations.location),
        tiles: [
          SettingsTile(
              leading: const Icon(CupertinoIcons.globe),
              title: Text(appLocalizations.longitude),
              trailing: Text(
                  state.defibrillator.location.longitude
                      .toString()
                      .characters
                      .take(10)
                      .string,
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context)))),
          SettingsTile(
              leading: const Icon(CupertinoIcons.globe),
              title: Text(appLocalizations.latitude),
              trailing: Text(
                  state.defibrillator.location.latitude
                      .toString()
                      .characters
                      .take(10)
                      .string,
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context)))),
        ],
      ),
      if (state.defibrillator.id > 0)
        SettingsSection(
          title: Text('OpenStreetMap'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(CupertinoIcons.cube_box),
              title: Text(appLocalizations.viewOpenStreetMapNode),
              onPressed: (context) {
                launchUrl(Uri.parse('$osmNodePrefix${state.defibrillator.id}'));
              },
            ),
            if (isUserCreated)
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.trash),
                title: Text(appLocalizations.delete),
                onPressed: (context) async {
                  await context.read<EditCubit>().delete(state.defibrillator);
                  await context.read<PointsCubit>().load();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      CustomSettingsSection(
          child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
        child: CupertinoButton.filled(
            onPressed: state.description.isNotEmpty
                ? () async {
                    var defibrillator = await context.read<EditCubit>().save();
                    if (defibrillator != null) {
                      context.read<PointsCubit>().update(defibrillator);
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            child: Text(appLocalizations.save)),
      )),
      CustomSettingsSection(
          child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
        child: CupertinoButton(
            child: Text(appLocalizations.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      )),
    ];
  }

  void selectAccess(BuildContext context, AppLocalizations appLocalizations,
      EditCubit editCubit) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          var actions = [
            'yes',
            'customers',
            'private',
            'permissive',
            'no',
            'unknown'
          ]
              .map((label) => CupertinoActionSheetAction(
                    onPressed: () async {
                      editCubit.editAccess(label);
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(translateAccessComment(label, appLocalizations)),
                  ))
              .toList();
          actions.add(CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(appLocalizations.cancel),
          ));
          return CupertinoActionSheet(
              title: Text(appLocalizations.chooseAccess), actions: actions);
        });
  }
}