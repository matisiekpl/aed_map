import 'dart:convert';
import 'dart:io';

import 'progress.dart';

class FlutterTestRunner {
  FlutterTestRunner(this.progress, this.filter);

  final Progress progress;
  final String? filter;

  Future<List<String>> run(String emoji, String title, String path, List<String> expectedNames) async {
    progress.start(emoji, title);
    final total = expectedNames.where((name) => filter == null || name.contains(filter!)).length;
    final names = <int, String>{};
    final errors = <int, String>{};
    final failures = <String>[];
    var done = 0;
    progress.update(0, total, 'compiling tests');
    final process = await Process.start(
      'flutter',
      ['test', path, '--reporter', 'json'],
      environment: {if (filter != null) 'SCREENSHOT_ONLY': filter!},
    );
    process.stderr.transform(utf8.decoder).listen((_) {});
    await for (final line in process.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('{')) continue;
      final event = jsonDecode(line) as Map<String, dynamic>;
      switch (event['type']) {
        case 'testStart':
          names[event['test']['id'] as int] = event['test']['name'] as String;
        case 'error':
          errors[event['testID'] as int] ??= (event['error'] as String).split('\n').first;
        case 'testDone':
          final name = names[event['testID']] ?? '';
          if (event['hidden'] == true || event['skipped'] == true || name.startsWith('loading ')) break;
          done++;
          if (event['result'] != 'success') {
            failures.add('$name: ${errors[event['testID']] ?? event['result']}');
          }
          progress.update(done, total, name);
      }
    }
    await process.exitCode;
    if (failures.isEmpty) {
      progress.finish('$done/$total passed');
    } else {
      progress.fail('$done/$total, ${failures.length} failed');
      for (final failure in failures) {
        stdout.writeln('    • $failure');
      }
    }
    return failures;
  }
}
