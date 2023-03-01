import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'dart:io' show Platform;

String? formatOpeningHours(String? input) {
  if (input == null) return null;
  input = input
      .replaceAll("Mo", "Pon")
      .replaceAll("Tu", "Wt")
      .replaceAll("We", "Śr")
      .replaceAll("Th", "Czw")
      .replaceAll("Fr", "Pt")
      .replaceAll("Sa", "Sob")
      .replaceAll("Su", "Niedz")
      .split(";")
      .map((k) => k.trim())
      .join("\n");
  return input;
}

class ConditionalFlexible extends StatelessWidget {
  final Widget child;

  const ConditionalFlexible({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? child : Flexible(child: child);
  }
}
