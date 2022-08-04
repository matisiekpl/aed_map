import 'package:latlong2/latlong.dart';

class AED {
  LatLng location;
  String? description;
  int id;
  bool indoor;
  String? operator;
  String? phone;

  AED(this.location, this.id, this.description, this.indoor, this.operator, this.phone);
}
