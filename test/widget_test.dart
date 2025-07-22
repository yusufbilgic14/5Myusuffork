// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medipolapp/main.dart';

void main() {
  testWidgets('Medipol app starts with loading screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initial frame to complete
    await tester.pump();

    // Verify that our app starts with the initial loading screen
    // Check for copyright text which should be present
    expect(find.text('Copyrighted 2025® Tüm Hakları Saklıdır'), findsOneWidget);

    // Wait for the loading screen timer to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify app loads successfully (basic check)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
