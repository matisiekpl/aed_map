import 'dart:io';

class Progress {
  Progress(this.stepCount);

  final int stepCount;
  int step = 0;
  final Stopwatch stopwatch = Stopwatch()..start();

  static const dim = '\x1B[2m';
  static const red = '\x1B[31m';
  static const reset = '\x1B[0m';
  static const clearLine = '\r\x1B[2K';

  void start(String emoji, String title) {
    step++;
    stdout.writeln('$clearLine$dim[$step/$stepCount]$reset $emoji  $title...');
  }

  void update(int done, int total, String label) {
    const width = 40;
    final filled = total == 0 ? width : (done * width ~/ total);
    final bar = '[${'#' * filled}${'-' * (width - filled)}]';
    final line = '$bar $done/$total $dim$label$reset';
    stdout.write('$clearLine${line.length > 140 ? line.substring(0, 140) : line}');
  }

  void finish(String summary) {
    stdout.writeln('$clearLine      $dim$summary$reset');
  }

  void fail(String message) {
    stdout.writeln('$clearLine${red}error$reset $message');
  }

  void done() {
    final seconds = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    stdout.writeln('✨  Done in ${seconds}s.');
  }
}
