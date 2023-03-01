import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/aed.dart';

class EditForm extends StatefulWidget {
  final AED aed;
  final bool isEditing;

  const EditForm({Key? key, required this.aed, required this.isEditing})
      : super(key: key);

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
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
    _descriptionEditingController.text = widget.aed.description ?? '';
    _operatorEditingController.text = widget.aed.operator ?? '';
    _phoneEditingController.text = widget.aed.phone ?? '';
    _openingHoursEditingController.text = widget.aed.openingHours ?? '';
    indoor = widget.aed.indoor;
    access = widget.aed.access ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj defibrylator')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Informacje'),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(CupertinoIcons.placemark),
                title: const Text('Opis'),
                value: TextField(
                  controller: _descriptionEditingController,
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Wpisz opis lokalizacji'),
                ),
              ),
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.arrow_clockwise_circle),
                title: const Text('Dostęp'),
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
                title: const Text('Wewnątrz budynku?'),
              ),
              SettingsTile(
                leading: const Icon(CupertinoIcons.person_2),
                title: const Text('Operator'),
                value: TextField(
                  controller: _operatorEditingController,
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Wpisz operatora'),
                ),
              ),
              SettingsTile(
                leading: const Icon(CupertinoIcons.phone),
                title: const Text('Kontakt'),
                value: TextField(
                  controller: _phoneEditingController,
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Wpisz numer telefonu'),
                ),
              ),
              // SettingsTile(
              //   leading: const Icon(CupertinoIcons.time),
              //   title: const Text('Godziny otwarcia'),
              //   value: TextField(
              //     controller: _openingHoursEditingController,
              //     decoration: const InputDecoration.collapsed(
              //         hintText: 'Wpisz godziny otwarcia w formacie OSM'),
              //   ),
              // ),
            ],
          ),
          SettingsSection(
            title: const Text('Lokalizacja'),
            tiles: [
              SettingsTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: const Text('Długość geograficzna'),
                  trailing: Text(widget.aed.location.longitude
                      .toString()
                      .characters
                      .take(12)
                      .string)),
              SettingsTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: const Text('Szerokość geograficzna'),
                  trailing: Text(widget.aed.location.latitude
                      .toString()
                      .characters
                      .take(12)
                      .string)),
            ],
          ),
          CustomSettingsSection(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
            child: CupertinoButton.filled(
                child: const Text('Zapisz'), onPressed: () {}),
          )),
          CustomSettingsSection(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
            child: CupertinoButton(
                child: Text(widget.isEditing ? 'Usuń' : 'Anuluj',
                    style: const TextStyle(color: Colors.red)),
                onPressed: () {
                  if (widget.isEditing) {
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
          )),
        ],
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
        _operatorEditingController.text,
        access);
  }

  void _selectAccess() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Wybierz dostępność'),
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
                  child: Text('Anuluj'),
                )
              ]),
    );
  }
}
