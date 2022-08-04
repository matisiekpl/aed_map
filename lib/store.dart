import 'package:geolocator/geolocator.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import 'constants.dart';

class Store {
  static Store instance = Store();

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    return await Geolocator.getCurrentPosition();
  }

  VectorTileProvider buildCachingTileProvider() {
    const urlTemplate = 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=$tilesApiKey';
    return MemoryCacheVectorTileProvider(delegate: NetworkVectorTileProvider(urlTemplate: urlTemplate, maximumZoom: 14), maxSizeBytes: 1024 * 1024 * 32);
  }

}
