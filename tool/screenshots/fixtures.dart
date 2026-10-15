import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'progress.dart';
import 'scenario.dart';

class FixtureDownloader {
  FixtureDownloader(this.progress);

  final Progress progress;
  final http.Client client = http.Client();

  static const userAgent = 'pl.enteam.aed_map screenshot generator';
  static const datasetUrl = 'https://openaedmap.org/api/v1/countries/WORLD.geojson';
  static const valhallaUrl = 'https://sa.tt.com.pl/valhalla2Move/raw_route.php/route';
  static const captionFontUrl = 'https://github.com/google/fonts/raw/main/ofl/manrope/Manrope%5Bwght%5D.ttf';

  Future<void> download() async {
    final dataset = await downloadDataset();
    final routes = await downloadRoutes(dataset);
    await downloadTiles(routes);
    await downloadFont();
    client.close();
  }

  Future<void> downloadFont() async {
    final file = File(Scenario.captionFontPath);
    if (file.existsSync()) return;
    final response = await client.get(Uri.parse(captionFontUrl));
    if (response.statusCode != 200) {
      throw HttpException('Manrope font: HTTP ${response.statusCode}');
    }
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<List<List<double>>> downloadDataset() async {
    progress.start('🔍', 'Fetching AED dataset');
    final file = File(Scenario.datasetPath);
    final isFresh = file.existsSync() &&
        DateTime.now().difference(file.lastModifiedSync()) < const Duration(days: 1);
    if (!isFresh) {
      progress.update(0, 1, 'downloading $datasetUrl');
      final response = await client.get(Uri.parse(datasetUrl), headers: {'User-Agent': userAgent});
      if (response.statusCode != 200) {
        throw HttpException('AED dataset: HTTP ${response.statusCode}');
      }
      final dataset = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      for (final feature in dataset['features'] as List<dynamic>) {
        (feature['properties'] as Map<String, dynamic>).remove('image');
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(dataset));
    }
    final features = jsonDecode(await file.readAsString())['features'] as List<dynamic>;
    final points = features
        .map((feature) => (feature['geometry']['coordinates'] as List<dynamic>).cast<num>())
        .map((coordinates) => [coordinates[1].toDouble(), coordinates[0].toDouble()])
        .toList();
    progress.finish('${points.length} defibrillators${isFresh ? ' (cached)' : ''}');
    return points;
  }

  Future<Map<String, dynamic>> downloadRoutes(List<List<double>> dataset) async {
    progress.start('🚶', 'Fetching walking routes');
    final routesFile = File(Scenario.routesPath);
    if (routesFile.existsSync() &&
        routesFile.lastModifiedSync().isAfter(File(Scenario.datasetPath).lastModifiedSync())) {
      final routes = jsonDecode(await routesFile.readAsString()) as Map<String, dynamic>;
      if (routes.length == Scenario.locales.length) {
        progress.finish('${routes.length} routes (cached)');
        return routes;
      }
    }
    final routes = <String, dynamic>{};
    for (final (index, locale) in Scenario.locales.indexed) {
      progress.update(index, Scenario.locales.length, locale.code);
      final start = [locale.latitude, locale.longitude];
      final nearest = dataset.reduce((best, point) => distance(start, point) < distance(start, best) ? point : best);
      final payload = {
        'costing': 'pedestrian',
        'costing_options': {
          'pedestrian': {'walking_speed': 9}
        },
        'units': 'meters',
        'id': 'aed_navigation',
        'locations': [
          {'lat': start[0], 'lon': start[1]},
          {'lat': nearest[0], 'lon': nearest[1]},
        ],
      };
      final response = await client.get(Uri.parse('$valhallaUrl?json=${Uri.encodeQueryComponent(jsonEncode(payload))}'));
      final trip = jsonDecode(response.body)['trip'];
      routes[locale.code] = {
        'start': start,
        'aed': nearest,
        'shape': trip['legs'][0]['shape'],
        'time': trip['summary']['time'],
        'length': trip['summary']['length'],
      };
    }
    await File(Scenario.routesPath).writeAsString(const JsonEncoder.withIndent('  ').convert(routes));
    progress.finish('${routes.length} routes from Valhalla');
    return routes;
  }

  Future<void> downloadTiles(Map<String, dynamic> routes) async {
    progress.start('🧩', 'Fetching OpenStreetMap tiles');
    final tiles = <(int, int)>{};
    for (final route in routes.values) {
      for (final point in [route['start'], route['aed']]) {
        final (centerX, centerY) = tileOf((point as List<dynamic>).cast<double>());
        for (var x = centerX - Scenario.tileRadius; x <= centerX + Scenario.tileRadius; x++) {
          for (var y = centerY - Scenario.tileRadius; y <= centerY + Scenario.tileRadius; y++) {
            tiles.add((x, y));
          }
        }
      }
    }
    final missing = tiles
        .where((tile) => !File('${Scenario.tilesDirectory}/${Scenario.tileZoom}/${tile.$1}/${tile.$2}.png').existsSync())
        .toList();
    var done = 0;
    final queue = List.of(missing);
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final (x, y) = queue.removeLast();
        final file = File('${Scenario.tilesDirectory}/${Scenario.tileZoom}/$x/$y.png');
        final response = await client.get(
            Uri.parse('https://tile.openstreetmap.org/${Scenario.tileZoom}/$x/$y.png'),
            headers: {'User-Agent': userAgent});
        if (response.statusCode == 200) {
          await file.parent.create(recursive: true);
          await file.writeAsBytes(response.bodyBytes);
        }
        progress.update(++done, missing.length, '${Scenario.tileZoom}/$x/$y');
      }
    }

    await Future.wait(List.generate(2, (_) => worker()));
    progress.finish('${tiles.length} tiles, ${missing.length} downloaded');
  }

  (int, int) tileOf(List<double> point) {
    final scale = 1 << Scenario.tileZoom;
    final latitude = point[0] * pi / 180;
    final x = ((point[1] + 180) / 360 * scale).floor();
    final y = ((1 - log(tan(latitude) + 1 / cos(latitude)) / pi) / 2 * scale).floor();
    return (x, y);
  }

  double distance(List<double> from, List<double> to) {
    const earthRadius = 6371000.0;
    final latitudeDelta = (to[0] - from[0]) * pi / 180;
    final longitudeDelta = (to[1] - from[1]) * pi / 180;
    final a = pow(sin(latitudeDelta / 2), 2) +
        cos(from[0] * pi / 180) * cos(to[0] * pi / 180) * pow(sin(longitudeDelta / 2), 2);
    return 2 * earthRadius * asin(sqrt(a));
  }
}
