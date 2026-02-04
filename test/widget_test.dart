import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_app/main.dart'; // Ensure this matches your package name

void main() {
  testWidgets('Guardian App Dashboard Smoke Test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // Note: Since main.dart uses Firebase.initializeApp(), 
    // real-world tests usually require "mocking" Firebase.
    // For now, we test the UI layout.
    await tester.pumpWidget(const GuardianApp());

    // 2. Verify that the Dashboard Title exists.
    expect(find.text('Security Desk'), findsOneWidget);

    // 3. Verify that the "Scan Vehicle" menu card is present.
    expect(find.text('Scan Vehicle'), findsOneWidget);

    // 4. Verify that we have the history/logs icon.
    expect(find.byIcon(Icons.history), findsOneWidget);

    // 5. Verify that the placeholder text isn't there (Sanity Check).
    expect(find.text('Scan Vehicle coming soon!'), findsNothing);
  });
}