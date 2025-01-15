import 'package:aed_map/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  CustomBindings();
  SharedPreferences.setMockInitialValues({});

  testWidgets('show nearest defibrillator on app open', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const App(skipOnboarding: true));

      // in case of sudden cardiac arrest, every second matters
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // check if the nearest defibrillator is shown
      expect(find.byKey(const Key('title')), findsOneWidget);
      expect(find.byKey(const Key('closestAed')), findsOneWidget);
      expect(find.byKey(const Key('access')), findsOneWidget);
      expect(find.byKey(const Key('description')), findsOneWidget);
    });
  });
}