import 'package:flutter/material.dart' show TimeOfDay;

enum OpeningHoursMode { none, alwaysOpen, workingHours, custom, advanced }

const List<String> openingHoursDayCodes = [
  'Mo',
  'Tu',
  'We',
  'Th',
  'Fr',
  'Sa',
  'Su'
];

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange(this.start, this.end);
}

class DayHours {
  bool closed;
  List<TimeRange> ranges;

  DayHours({this.closed = true, List<TimeRange>? ranges})
      : ranges = ranges ?? [];

  DayHours copy() {
    return DayHours(
      closed: closed,
      ranges: ranges.map((range) => TimeRange(range.start, range.end)).toList(),
    );
  }
}

class OpeningHoursModel {
  OpeningHoursMode mode;
  List<DayHours> days;
  TimeOfDay workingStart;
  TimeOfDay workingEnd;
  String advancedRaw;

  OpeningHoursModel({
    this.mode = OpeningHoursMode.custom,
    List<DayHours>? days,
    TimeOfDay? workingStart,
    TimeOfDay? workingEnd,
    this.advancedRaw = '',
  })  : days = days ?? List.generate(7, (_) => DayHours(closed: true)),
        workingStart = workingStart ?? const TimeOfDay(hour: 9, minute: 0),
        workingEnd = workingEnd ?? const TimeOfDay(hour: 17, minute: 0);
}

OpeningHoursModel parseOpeningHours(String? value) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) {
    return OpeningHoursModel(mode: OpeningHoursMode.none);
  }
  if (trimmed.toLowerCase() == '24/7') {
    return OpeningHoursModel(mode: OpeningHoursMode.alwaysOpen);
  }
  final workingHoursMatch =
      RegExp(r'^Mo-Fr\s+(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$')
          .firstMatch(trimmed);
  if (workingHoursMatch != null) {
    final startHour = int.parse(workingHoursMatch.group(1)!);
    final startMinute = int.parse(workingHoursMatch.group(2)!);
    final endHour = int.parse(workingHoursMatch.group(3)!);
    final endMinute = int.parse(workingHoursMatch.group(4)!);
    if (startHour <= 24 &&
        endHour <= 24 &&
        startMinute <= 59 &&
        endMinute <= 59) {
      return OpeningHoursModel(
        mode: OpeningHoursMode.workingHours,
        workingStart: TimeOfDay(
            hour: startHour == 24 ? 0 : startHour, minute: startMinute),
        workingEnd:
            TimeOfDay(hour: endHour == 24 ? 0 : endHour, minute: endMinute),
      );
    }
  }
  final days = List<DayHours>.generate(7, (_) => DayHours(closed: true));
  for (final rawRule in trimmed.split(';')) {
    final rule = rawRule.trim();
    if (rule.isEmpty) continue;
    final separatorMatch = RegExp(r'\s+').firstMatch(rule);
    if (separatorMatch == null) {
      return OpeningHoursModel(
          mode: OpeningHoursMode.advanced, advancedRaw: trimmed);
    }
    final dayPart = rule.substring(0, separatorMatch.start).trim();
    final remainder = rule.substring(separatorMatch.end).trim();
    final dayIndices = _parseDayPart(dayPart);
    if (dayIndices == null) {
      return OpeningHoursModel(
          mode: OpeningHoursMode.advanced, advancedRaw: trimmed);
    }
    final remainderLower = remainder.toLowerCase();
    if (remainderLower == 'off' || remainderLower == 'closed') {
      for (final dayIndex in dayIndices) {
        days[dayIndex] = DayHours(closed: true);
      }
      continue;
    }
    final ranges = <TimeRange>[];
    for (final timeToken in remainder.split(',')) {
      final parsedRange = _parseTimeRange(timeToken);
      if (parsedRange == null) {
        return OpeningHoursModel(
            mode: OpeningHoursMode.advanced, advancedRaw: trimmed);
      }
      ranges.add(parsedRange);
    }
    for (final dayIndex in dayIndices) {
      days[dayIndex] = DayHours(
        closed: false,
        ranges: ranges.map((range) => TimeRange(range.start, range.end)).toList(),
      );
    }
  }
  return OpeningHoursModel(mode: OpeningHoursMode.custom, days: days);
}

String? buildOpeningHours(OpeningHoursModel model) {
  if (model.mode == OpeningHoursMode.none) return null;
  if (model.mode == OpeningHoursMode.alwaysOpen) return '24/7';
  if (model.mode == OpeningHoursMode.workingHours) {
    return 'Mo-Fr ${_pad(model.workingStart.hour)}:${_pad(model.workingStart.minute)}-${_pad(model.workingEnd.hour)}:${_pad(model.workingEnd.minute)}';
  }
  if (model.mode == OpeningHoursMode.advanced) {
    final trimmed = model.advancedRaw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  final parts = <String>[];
  var dayIndex = 0;
  while (dayIndex < 7) {
    final currentDay = model.days[dayIndex];
    if (currentDay.closed || currentDay.ranges.isEmpty) {
      dayIndex++;
      continue;
    }
    var endIndex = dayIndex;
    while (endIndex + 1 < 7 &&
        !model.days[endIndex + 1].closed &&
        _rangesEqual(model.days[endIndex + 1].ranges, currentDay.ranges)) {
      endIndex++;
    }
    final dayPart = dayIndex == endIndex
        ? openingHoursDayCodes[dayIndex]
        : '${openingHoursDayCodes[dayIndex]}-${openingHoursDayCodes[endIndex]}';
    final timePart = currentDay.ranges.map(_formatRangeOsm).join(',');
    parts.add('$dayPart $timePart');
    dayIndex = endIndex + 1;
  }
  if (parts.isEmpty) return null;
  return parts.join('; ');
}

String formatTimeOfDay(TimeOfDay time) {
  return '${_pad(time.hour)}:${_pad(time.minute)}';
}

String formatTimeRange(TimeRange range) {
  return '${formatTimeOfDay(range.start)}–${formatTimeOfDay(range.end)}';
}

List<int>? _parseDayPart(String dayPart) {
  final indices = <int>{};
  for (final token in dayPart.split(',')) {
    final normalized = token.trim();
    if (normalized.isEmpty) return null;
    if (normalized.contains('-')) {
      final rangeParts = normalized.split('-');
      if (rangeParts.length != 2) return null;
      final startIndex = _dayCodeIndex(rangeParts[0].trim());
      final endIndex = _dayCodeIndex(rangeParts[1].trim());
      if (startIndex == null || endIndex == null || startIndex > endIndex) {
        return null;
      }
      for (var i = startIndex; i <= endIndex; i++) {
        indices.add(i);
      }
    } else {
      final singleIndex = _dayCodeIndex(normalized);
      if (singleIndex == null) return null;
      indices.add(singleIndex);
    }
  }
  final sorted = indices.toList()..sort();
  return sorted;
}

int? _dayCodeIndex(String code) {
  final index = openingHoursDayCodes.indexOf(code);
  return index >= 0 ? index : null;
}

TimeRange? _parseTimeRange(String token) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$')
      .firstMatch(token.trim());
  if (match == null) return null;
  final startHour = int.parse(match.group(1)!);
  final startMinute = int.parse(match.group(2)!);
  final endHour = int.parse(match.group(3)!);
  final endMinute = int.parse(match.group(4)!);
  if (startHour < 0 ||
      startHour > 24 ||
      endHour < 0 ||
      endHour > 24 ||
      startMinute < 0 ||
      startMinute > 59 ||
      endMinute < 0 ||
      endMinute > 59) {
    return null;
  }
  return TimeRange(
    TimeOfDay(hour: startHour == 24 ? 0 : startHour, minute: startMinute),
    TimeOfDay(hour: endHour == 24 ? 0 : endHour, minute: endMinute),
  );
}

String _formatRangeOsm(TimeRange range) {
  return '${_pad(range.start.hour)}:${_pad(range.start.minute)}-${_pad(range.end.hour)}:${_pad(range.end.minute)}';
}

String _pad(int value) => value.toString().padLeft(2, '0');

bool _rangesEqual(List<TimeRange> a, List<TimeRange> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].start != b[i].start || a[i].end != b[i].end) return false;
  }
  return true;
}
