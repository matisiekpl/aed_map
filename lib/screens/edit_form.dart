import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/aed.dart';
import '../store.dart';
import '../utils.dart';

class EditForm extends StatefulWidget {
  final AED aed;
  final bool isEditing;

  const EditForm({Key? key, required this.aed, required this.isEditing})
      : super(key: key);

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> with WidgetsBindingObserver {
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final TextEditingController _operatorEditingController =
      TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _openingHoursEditingController =
      TextEditingController();

  bool indoor = false;
  String access = 'yes';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });

    _descriptionEditingController.text = widget.aed.description ?? '';
    _operatorEditingController.text = widget.aed.operator ?? '';
    _phoneEditingController.text = widget.aed.phone ?? '';
    _openingHoursEditingController.text = widget.aed.openingHours ?? '';
    indoor = widget.aed.indoor;
    access = widget.aed.access ?? 'yes';
  }

  Brightness? _brightness;

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance.window.platformBrightness;
      });
    }
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = _brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editDefibrillator),
          actions: <Widget>[
            IconButton(
              icon: const Icon(CupertinoIcons.globe),
              onPressed: () {
                launchUrl(Uri.parse(
                    'https://www.openstreetmap.org/node/${widget.aed.id}'));
              },
            )
          ]),
      body: Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: Text(AppLocalizations.of(context)!.information),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: const Icon(CupertinoIcons.placemark),
                  title: ConditionalFlexible(
                    child: TextField(
                      controller: _descriptionEditingController,
                      decoration: InputDecoration.collapsed(
                          hintText:
                              AppLocalizations.of(context)!.enterDescription),
                    ),
                  ),
                ),
                SettingsTile.navigation(
                  leading: const Icon(CupertinoIcons.arrow_clockwise_circle),
                  title: Text(AppLocalizations.of(context)!.access),
                  value: Text(translateAccessComment(access, context) ?? ''),
                  onPressed: (context) {
                    _selectAccess();
                  },
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    setState(() {
                      indoor = value;
                    });
                  },
                  initialValue: indoor,
                  leading: const Icon(CupertinoIcons.home),
                  title: Text(AppLocalizations.of(context)!.insideBuilding),
                ),
                SettingsTile(
                  leading: const Icon(CupertinoIcons.person_2),
                  title: ConditionalFlexible(
                    child: TextField(
                      controller: _operatorEditingController,
                      decoration: InputDecoration.collapsed(
                          hintText:
                              AppLocalizations.of(context)!.enterOperator),
                    ),
                  ),
                ),
                SettingsTile(
                  leading: const Icon(CupertinoIcons.phone),
                  title: ConditionalFlexible(
                    child: TextField(
                      controller: _phoneEditingController,
                      decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.of(context)!.enterPhone),
                    ),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text(AppLocalizations.of(context)!.location),
              tiles: [
                SettingsTile(
                    leading: const Icon(CupertinoIcons.globe),
                    title: Text(AppLocalizations.of(context)!.longitude),
                    trailing: Text(
                        widget.aed.location.longitude
                            .toString()
                            .characters
                            .take(12)
                            .string,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black))),
                SettingsTile(
                    leading: const Icon(CupertinoIcons.globe),
                    title: Text(AppLocalizations.of(context)!.latitude),
                    trailing: Text(
                        widget.aed.location.latitude
                            .toString()
                            .characters
                            .take(12)
                            .string,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black))),
              ],
            ),
            CustomSettingsSection(
                child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
              child: CupertinoButton.filled(
                  child: Text(AppLocalizations.of(context)!.save),
                  onPressed: () async {
                    if (widget.isEditing) {
                      AED aed =
                          await Store.instance.updateDefibrillator(getAED());
                      Navigator.of(context).pop(aed);
                    } else {
                      AED aed =
                          await Store.instance.insertDefibrillator(getAED());
                      Navigator.of(context).pop(aed);
                    }
                  }),
            )),
            CustomSettingsSection(
                child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
              child: CupertinoButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            )),
          ],
        ),
      ),
    );
  }

  AED getAED() {
    return AED(
        LatLng(widget.aed.location.latitude, widget.aed.location.longitude),
        widget.aed.id,
        _descriptionEditingController.text,
        indoor,
        _operatorEditingController.text,
        _phoneEditingController.text,
        _openingHoursEditingController.text,
        access);
  }

  void _selectAccess() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.chooseAccess),
          actions: [
                'yes',
                'customers',
                'private',
                'permissive',
                'no',
                'unknown'
              ]
                  .map((label) => CupertinoActionSheetAction(
                        onPressed: () async {
                          setState(() {
                            access = label;
                          });
                          Navigator.of(context).pop();
                        },
                        child:
                            Text(translateAccessComment(label, context) ?? ''),
                      ))
                  .toList() +
              [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                )
              ]),
    );
  }
}
