import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:safereach/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app runs and loads UI',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Expect to see the Splash Screen or Welcome Screen
      expect(find.text('SafeReach'), findsWidgets);
    });
  });
}
