import 'package:latlong2/latlong.dart';

class AED {
  LatLng location;
  String? description;
  int id;
  bool indoor;
  String? operator;
  String? phone;
  int? distance;
  String? openingHours;
  String? access;

  AED(this.location, this.id, this.description, this.indoor, this.operator,
      this.phone, this.openingHours, this.access);

  String? getAccessComment() {
    if (access == null) return null;
    Map comments = {
      'yes': 'publicznie dostępny',
      'customers': 'tylko w godzinach pracy',
      'private': 'za zgodą właściciela',
      'permissive': 'publicznie do odwołania',
      'no': 'niedostępny',
      'unknown': 'nieznany',
    };
    return comments[access];
  }
}
