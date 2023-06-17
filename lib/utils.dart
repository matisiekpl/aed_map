import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:latlong2/latlong.dart';
export 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    show decodePolyline;

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
    return Platform.isAndroid ? child : child;
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

extension PolylineExt on List<List<num>> {
  List<LatLng> unpackPolyline() =>
      map((p) => LatLng(p[0].toDouble(), p[1].toDouble())).toList();
}
