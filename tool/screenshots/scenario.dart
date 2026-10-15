class ScreenshotLocale {
  const ScreenshotLocale({
    required this.code,
    required this.appStoreCode,
    this.googlePlayCode,
    required this.latitude,
    required this.longitude,
  });

  final String code;
  final String appStoreCode;
  final String? googlePlayCode;
  final double latitude;
  final double longitude;
}

enum ScreenshotScene { map, details, route, dark, add }

enum ScreenshotDevice {
  iphone(width: 1179, height: 2556, pixelRatio: 3, topPadding: 59, bottomPadding: 34, apple: true, scenes: ScreenshotScene.values),
  ipad(width: 2064, height: 2752, pixelRatio: 2, topPadding: 24, bottomPadding: 20, apple: true, scenes: [ScreenshotScene.map, ScreenshotScene.route, ScreenshotScene.dark]),
  android(width: 1080, height: 2400, pixelRatio: 2.625, topPadding: 32, bottomPadding: 24, apple: false, scenes: [ScreenshotScene.map, ScreenshotScene.details, ScreenshotScene.route, ScreenshotScene.dark]),
  tablet(width: 1600, height: 2560, pixelRatio: 2, topPadding: 24, bottomPadding: 24, apple: false, scenes: [ScreenshotScene.map, ScreenshotScene.route, ScreenshotScene.dark]);

  const ScreenshotDevice({
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.topPadding,
    required this.bottomPadding,
    required this.apple,
    required this.scenes,
  });

  final int width;
  final int height;
  final double pixelRatio;
  final double topPadding;
  final double bottomPadding;
  final bool apple;
  final List<ScreenshotScene> scenes;
}

enum ComposeTarget {
  appStoreIphone69(width: 1320, height: 2868, device: ScreenshotDevice.iphone),
  appStoreIphone65(width: 1284, height: 2778, device: ScreenshotDevice.iphone),
  appStoreIpad(width: 2064, height: 2752, device: ScreenshotDevice.ipad),
  googlePlayPhone(width: 1080, height: 1920, device: ScreenshotDevice.android),
  googlePlayTablet(width: 1440, height: 2560, device: ScreenshotDevice.tablet);

  const ComposeTarget({required this.width, required this.height, required this.device});

  final int width;
  final int height;
  final ScreenshotDevice device;
}

class Scenario {
  static const locales = [
    ScreenshotLocale(code: 'pl', appStoreCode: 'pl', googlePlayCode: 'pl-PL', latitude: 52.235992, longitude: 21.010061),
    ScreenshotLocale(code: 'en', appStoreCode: 'en-US', googlePlayCode: 'en-US', latitude: 51.514048, longitude: -0.10443),
    ScreenshotLocale(code: 'de', appStoreCode: 'de-DE', googlePlayCode: 'de-DE', latitude: 53.548188, longitude: 9.989826),
    ScreenshotLocale(code: 'es', appStoreCode: 'es-ES', googlePlayCode: 'es-ES', latitude: 41.379895, longitude: 2.186794),
    ScreenshotLocale(code: 'fr', appStoreCode: 'fr-FR', googlePlayCode: 'fr-FR', latitude: 48.840525, longitude: 2.362106),
    ScreenshotLocale(code: 'it', appStoreCode: 'it',latitude: 45.46546, longitude: 9.188605),
  ];

  static const buildDirectory = 'build/screenshots';
  static const fixturesDirectory = '$buildDirectory/fixtures';
  static const tilesDirectory = '$fixturesDirectory/tiles';
  static const datasetPath = '$fixturesDirectory/world.geojson';
  static const routesPath = '$fixturesDirectory/routes.json';
  static const rawDirectory = '$buildDirectory/raw';
  static const composedDirectory = '$buildDirectory/composed';
  static const captionFontPath = '$fixturesDirectory/Manrope.ttf';
  static const captionsPath = 'tool/screenshots/captions.json';
  static const featureGraphicWidth = 1024;
  static const featureGraphicHeight = 500;
  static const tileZoom = 18;
  static const tileRadius = 6;

  static String rawPath(ScreenshotLocale locale, ScreenshotScene scene, ScreenshotDevice device) =>
      '$rawDirectory/${locale.code}/${device.name}_${scene.name}.png';

  static String composedPath(ScreenshotLocale locale, ScreenshotScene scene, ComposeTarget target) =>
      '$composedDirectory/${locale.code}/${target.name}_${scene.name}.png';

  static const landingScenes = [ScreenshotScene.map, ScreenshotScene.details];
  static const landingMockupWidth = 900;

  static String landingMockupPath(ScreenshotLocale locale, ScreenshotScene scene) =>
      '$composedDirectory/${locale.code}/landing_${scene.name}.png';

  static String landingTestName(ScreenshotLocale locale, ScreenshotScene scene) =>
      'compose · ${locale.code} · landing · ${scene.name}';

  static String featureGraphicPath(ScreenshotLocale locale) =>
      '$composedDirectory/${locale.code}/featureGraphic.png';

  static String composeTestName(ScreenshotLocale locale, ScreenshotScene scene, ComposeTarget target) =>
      'compose · ${locale.code} · ${scene.name} · ${target.name}';

  static String featureGraphicTestName(ScreenshotLocale locale) => 'compose · ${locale.code} · featureGraphic';

  static List<String> captureTestNames() => [
        for (final locale in locales)
          for (final device in ScreenshotDevice.values)
            for (final scene in device.scenes) testName(locale, scene, device),
      ];

  static List<String> composeTestNames() => [
        for (final locale in locales) ...[
          featureGraphicTestName(locale),
          for (final scene in landingScenes) landingTestName(locale, scene),
          for (final target in ComposeTarget.values)
            for (final scene in target.device.scenes) composeTestName(locale, scene, target),
        ],
      ];

  static String testName(ScreenshotLocale locale, ScreenshotScene scene, ScreenshotDevice device) =>
      '${locale.code} · ${scene.name} · ${device.name}';
}
