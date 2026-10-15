import 'dart:io';

import 'screenshots/exporter.dart';
import 'screenshots/fixtures.dart';
import 'screenshots/flutter_tests.dart';
import 'screenshots/progress.dart';
import 'screenshots/scenario.dart';

Future<void> main(List<String> arguments) async {
  final onlyIndex = arguments.indexOf('--only');
  final filter = onlyIndex >= 0 && onlyIndex + 1 < arguments.length ? arguments[onlyIndex + 1] : null;
  final progress = Progress(6);
  await FixtureDownloader(progress).download();
  final runner = FlutterTestRunner(progress, filter);
  final captureFailures =
      await runner.run('📱', 'Rendering app screens', 'test/screenshots/capture_test.dart', Scenario.captureTestNames());
  if (captureFailures.isNotEmpty) exit(1);
  final composeFailures =
      await runner.run('🎨', 'Composing store graphics', 'test/screenshots/compose_test.dart', Scenario.composeTestNames());
  if (composeFailures.isNotEmpty) exit(1);
  if (filter == null) {
    await ScreenshotExporter(progress).export();
  } else {
    progress.start('⏭️ ', 'Skipping export (--only $filter)');
  }
  progress.done();
}
