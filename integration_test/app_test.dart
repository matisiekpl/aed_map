import 'package:aed_map/main.dart' as app;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('shader cache', () {
    testWidgets('shader cache',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 10));
      await tester.drag(
          find.byKey(const Key('closestAed')), const Offset(0, 500));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.gear));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'ZAMKNIJ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zakończ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('⚠️ Najbliższy AED'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.text_bubble));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('navigate_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('text_input_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('close_controls_column')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('navigate')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));
    });
  });
}
