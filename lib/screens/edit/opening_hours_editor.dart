import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/shared/opening_hours.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_opening_hours/osm_opening_hours.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/i18n/app_localizations.dart';
import '../../shared/utils.dart';

class OpeningHoursEditor extends StatefulWidget {
  final String? initialValue;

  const OpeningHoursEditor({super.key, required this.initialValue});

  @override
  State<OpeningHoursEditor> createState() => _OpeningHoursEditorState();
}

class _OpeningHoursEditorState extends State<OpeningHoursEditor> {
  late OpeningHoursModel model;
  late TextEditingController advancedController;
  bool advancedTagValid = true;

  @override
  void initState() {
    super.initState();
    model = parseOpeningHours(widget.initialValue);
    advancedController = TextEditingController(
      text: model.advancedRaw.isNotEmpty
          ? model.advancedRaw
          : (widget.initialValue ?? ''),
    );
    advancedTagValid = isAdvancedValid(advancedController.text);
  }

  bool isAdvancedValid(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    return OsmOpeningHours.check(trimmed);
  }

  @override
  void dispose() {
    advancedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(appLocalizations.editOpeningHours),
      ),
      child: Theme(
        data: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        child: SafeArea(
          bottom: false,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
            child: SettingsList(
              platform: DevicePlatform.iOS,
              applicationType: ApplicationType.cupertino,
              lightTheme: const SettingsThemeData(),
              darkTheme: settingsListDarkTheme,
              sections: buildSections(context, appLocalizations),
            ),
          ),
        ),
      ),
    );
  }

  List<AbstractSettingsSection> buildSections(
      BuildContext context, AppLocalizations appLocalizations) {
    return [
      SettingsSection(
        tiles: [
          modeTile(
            appLocalizations,
            OpeningHoursMode.alwaysOpen,
            appLocalizations.openingHoursAlwaysOpen,
            CupertinoIcons.clock_solid,
          ),
          modeTile(
            appLocalizations,
            OpeningHoursMode.workingHours,
            appLocalizations.openingHoursWorkingHours,
            CupertinoIcons.briefcase,
          ),
          modeTile(
            appLocalizations,
            OpeningHoursMode.custom,
            appLocalizations.openingHoursCustomSchedule,
            CupertinoIcons.calendar,
          ),
          modeTile(
            appLocalizations,
            OpeningHoursMode.advanced,
            appLocalizations.openingHoursAdvanced,
            CupertinoIcons.textformat,
          ),
        ],
      ),
      if (model.mode == OpeningHoursMode.workingHours)
        SettingsSection(
          title: Text(appLocalizations.openingHoursWorkingHours),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(CupertinoIcons.time),
              title: Text(formatTimeRange(
                  TimeRange(model.workingStart, model.workingEnd))),
              onPressed: (tileContext) async {
                final picked = await pickTimeRange(
                  tileContext,
                  initial: TimeRange(model.workingStart, model.workingEnd),
                );
                if (picked != null) {
                  setState(() {
                    model.workingStart = picked.start;
                    model.workingEnd = picked.end;
                  });
                }
              },
            ),
          ],
        ),
      if (model.mode == OpeningHoursMode.custom)
        SettingsSection(
          title: Text(appLocalizations.openingHoursCustomSchedule),
          tiles: List.generate(
            7,
            (index) => customDayTile(context, appLocalizations, index),
          ),
        ),
      if (model.mode == OpeningHoursMode.advanced)
        SettingsSection(
          title: Text(appLocalizations.openingHoursAdvanced),
          tiles: [
            SettingsTile(
              leading: const Icon(CupertinoIcons.textformat),
              title: TextField(
                controller: advancedController,
                maxLines: 3,
                minLines: 1,
                onChanged: (value) {
                  model.advancedRaw = value;
                  setState(() {
                    advancedTagValid = isAdvancedValid(value);
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: appLocalizations.openingHoursAdvancedHint,
                ),
              ),
            ),
            if (advancedTagValid && advancedController.text.trim().isNotEmpty)
              SettingsTile(
                leading: const Icon(CupertinoIcons.check_mark_circled_solid,
                    color: CupertinoColors.activeGreen),
                title: Text(
                  appLocalizations.openingHoursValidOsmFormat,
                  style: const TextStyle(color: CupertinoColors.activeGreen),
                ),
              ),
            SettingsTile(
              leading: const Icon(CupertinoIcons.book,
                  color: CupertinoColors.activeBlue),
              title: Text(
                appLocalizations.openingHoursOsmDocumentation,
                style: const TextStyle(color: CupertinoColors.activeBlue),
              ),
              onPressed: (_) => launchUrl(
                Uri.parse(
                    'https://wiki.openstreetmap.org/wiki/Key:opening_hours'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      CustomSettingsSection(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
          child: CupertinoButton.filled(
            onPressed: (model.mode == OpeningHoursMode.advanced &&
                    !advancedTagValid)
                ? null
                : () => saveAndPop(context),
            child: Text(appLocalizations.save),
          ),
        ),
      ),
      CustomSettingsSection(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
          child: CupertinoButton(
            onPressed: () => clearAndPop(context),
            child: Text(appLocalizations.openingHoursClear),
          ),
        ),
      ),
      CustomSettingsSection(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
          child: CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLocalizations.cancel),
          ),
        ),
      ),
    ];
  }

  SettingsTile modeTile(
    AppLocalizations appLocalizations,
    OpeningHoursMode targetMode,
    String label,
    IconData icon,
  ) {
    final selected = model.mode == targetMode;
    return SettingsTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
          : null,
      onPressed: (_) => setState(() => model.mode = targetMode),
    );
  }

  SettingsTile customDayTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    int dayIndex,
  ) {
    final dayName = _dayName(appLocalizations, dayIndex);
    final day = model.days[dayIndex];
    final isSet = !day.closed && day.ranges.isNotEmpty;
    final valueLabel = isSet
        ? day.ranges.map(formatTimeRange).join(', ')
        : appLocalizations.openingHoursClosed;
    return SettingsTile(
      leading: const Icon(CupertinoIcons.calendar_today),
      title: Text(dayName),
      value: Text(valueLabel),
      trailing: isSet
          ? const Icon(CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.activeGreen)
          : const Icon(CupertinoIcons.circle,
              color: CupertinoColors.inactiveGray),
      onPressed: (_) => editDayRanges(context, appLocalizations, dayIndex),
    );
  }

  Future<void> editDayRanges(
    BuildContext context,
    AppLocalizations appLocalizations,
    int dayIndex,
  ) async {
    final dayName = _dayName(appLocalizations, dayIndex);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final day = model.days[dayIndex];
            return CupertinoActionSheet(
              title: Text(dayName),
              message: day.closed || day.ranges.isEmpty
                  ? Text(appLocalizations.openingHoursClosed)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: day.ranges
                          .asMap()
                          .entries
                          .map((entry) => rangeRow(
                                builderContext,
                                dayIndex,
                                entry.key,
                                setModalState,
                              ))
                          .toList(),
                    ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () async {
                    final added = await pickTimeRange(builderContext);
                    if (added != null) {
                      setState(() {
                        model.days[dayIndex].closed = false;
                        model.days[dayIndex].ranges.add(added);
                      });
                      setModalState(() {});
                    }
                  },
                  child: Text(appLocalizations.openingHoursAddRange),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(modalContext).pop(),
                child: Text(appLocalizations.backToDaysList),
              ),
            );
          },
        );
      },
    );
  }

  Widget rangeRow(
    BuildContext context,
    int dayIndex,
    int rangeIndex,
    StateSetter setModalState,
  ) {
    final range = model.days[dayIndex].ranges[rangeIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              final updated = await pickTimeRange(context, initial: range);
              if (updated != null) {
                setState(() {
                  model.days[dayIndex].ranges[rangeIndex] = updated;
                });
                setModalState(() {});
              }
            },
            child: Text(formatTimeRange(range)),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                model.days[dayIndex].ranges.removeAt(rangeIndex);
                if (model.days[dayIndex].ranges.isEmpty) {
                  model.days[dayIndex].closed = true;
                }
              });
              setModalState(() {});
            },
            child: const Icon(CupertinoIcons.trash,
                color: CupertinoColors.destructiveRed),
          ),
        ],
      ),
    );
  }

  Future<TimeRange?> pickTimeRange(BuildContext context,
      {TimeRange? initial}) async {
    var start = initial?.start ?? const TimeOfDay(hour: 8, minute: 0);
    var end = initial?.end ?? const TimeOfDay(hour: 17, minute: 0);
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (modalContext) {
        return Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(modalContext),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(modalContext).pop(false),
                      child: Text(AppLocalizations.of(modalContext)!.cancel),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(modalContext).pop(true),
                      child: Text(AppLocalizations.of(modalContext)!.save),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: true,
                          initialDateTime: DateTime(
                              2024, 1, 1, start.hour, start.minute),
                          onDateTimeChanged: (value) {
                            start = TimeOfDay(
                                hour: value.hour, minute: value.minute);
                          },
                        ),
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: true,
                          initialDateTime:
                              DateTime(2024, 1, 1, end.hour, end.minute),
                          onDateTimeChanged: (value) {
                            end = TimeOfDay(
                                hour: value.hour, minute: value.minute);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true) return null;
    return TimeRange(start, end);
  }

  String _dayName(AppLocalizations appLocalizations, int dayIndex) {
    switch (dayIndex) {
      case 0:
        return appLocalizations.dayMonday;
      case 1:
        return appLocalizations.dayTuesday;
      case 2:
        return appLocalizations.dayWednesday;
      case 3:
        return appLocalizations.dayThursday;
      case 4:
        return appLocalizations.dayFriday;
      case 5:
        return appLocalizations.daySaturday;
      default:
        return appLocalizations.daySunday;
    }
  }

  void saveAndPop(BuildContext context) {
    final serialized = buildOpeningHours(model);
    context.read<EditCubit>().editOpeningHours(serialized ?? '');
    Navigator.of(context).pop();
  }

  void clearAndPop(BuildContext context) {
    context.read<EditCubit>().editOpeningHours('');
    Navigator.of(context).pop();
  }
}
