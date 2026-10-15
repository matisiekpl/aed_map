import 'dart:io';

import 'package:image/image.dart' as img;

import 'progress.dart';
import 'scenario.dart';

class ScreenshotExporter {
  ScreenshotExporter(this.progress);

  final Progress progress;

  static const appStoreDirectory = 'ios/fastlane/screenshots';
  static const googlePlayDirectory = 'android/fastlane/metadata/android';
  static const landingDirectory = 'landing/public/screenshots';
  static const landingWidth = 720;

  Future<void> export() async {
    progress.start('🚚', 'Exporting to fastlane and landing');
    final jobs = [
      for (final locale in Scenario.locales) ...[
        ...appStoreJobs(locale),
        if (locale.googlePlayCode != null) ...googlePlayJobs(locale),
        ...landingJobs(locale),
      ],
    ];
    clean(landingDirectory);
    for (final locale in Scenario.locales) {
      clean('$appStoreDirectory/${locale.appStoreCode}');
      if (locale.googlePlayCode == null) continue;
      for (final folder in ['phoneScreenshots', 'sevenInchScreenshots', 'tenInchScreenshots']) {
        clean('$googlePlayDirectory/${locale.googlePlayCode}/images/$folder');
      }
    }
    for (final (index, job) in jobs.indexed) {
      progress.update(index + 1, jobs.length, job.destination);
      await job.run();
    }
    progress.finish('${jobs.length} files');
  }

  void clean(String path) {
    final directory = Directory(path);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  List<ExportJob> appStoreJobs(ScreenshotLocale locale) => [
        for (final target in [ComposeTarget.appStoreIphone69, ComposeTarget.appStoreIphone65, ComposeTarget.appStoreIpad])
          for (final (index, scene) in target.device.scenes.indexed)
            ExportJob(
              Scenario.composedPath(locale, scene, target),
              '$appStoreDirectory/${locale.appStoreCode}/${index + 1}_${target.name}_${scene.name}.png',
            ),
      ];

  List<ExportJob> googlePlayJobs(ScreenshotLocale locale) {
    final images = '$googlePlayDirectory/${locale.googlePlayCode}/images';
    return [
      ExportJob(Scenario.featureGraphicPath(locale), '$images/featureGraphic.png'),
      for (final (index, scene) in ComposeTarget.googlePlayPhone.device.scenes.indexed)
        ExportJob(Scenario.composedPath(locale, scene, ComposeTarget.googlePlayPhone),
            '$images/phoneScreenshots/${index + 1}_${scene.name}.png'),
      for (final folder in ['sevenInchScreenshots', 'tenInchScreenshots'])
        for (final (index, scene) in ComposeTarget.googlePlayTablet.device.scenes.indexed)
          ExportJob(Scenario.composedPath(locale, scene, ComposeTarget.googlePlayTablet),
              '$images/$folder/${index + 1}_${scene.name}.png'),
    ];
  }

  List<ExportJob> landingJobs(ScreenshotLocale locale) => [
        for (final scene in Scenario.landingScenes)
          ExportJob(Scenario.landingMockupPath(locale, scene), '$landingDirectory/${locale.code}/${scene.name}.webp',
              width: landingWidth),
      ];
}

class ExportJob {
  ExportJob(this.source, this.destination, {this.width});

  final String source;
  final String destination;
  final int? width;

  Future<void> run() async {
    if (destination.endsWith('.webp')) {
      await File(destination).parent.create(recursive: true);
      final result = await Process.run('cwebp', ['-quiet', '-q', '82', '-alpha_q', '90', '-resize', '$width', '0', source, '-o', destination]);
      if (result.exitCode != 0) {
        throw ProcessException('cwebp', [source], 'cwebp failed (brew install webp): ${result.stderr}', result.exitCode);
      }
      return;
    }
    var image = img.decodePng(await File(source).readAsBytes())!.convert(numChannels: 3);
    if (width != null) {
      image = img.copyResize(image, width: width, interpolation: img.Interpolation.average);
    }
    final file = File(destination);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(img.encodePng(image, level: 9));
  }
}
