import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedNetworkTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
      TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coordinates, options));
  }
}
