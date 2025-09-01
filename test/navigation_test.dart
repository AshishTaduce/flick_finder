import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flick_finder/presentation/screens/home/home_screen.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('HomeScreen should accept navigation callback', (WidgetTester tester) async {
      bool searchCallbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            onNavigateToSearch: () {
              searchCallbackCalled = true;
            },
          ),
        ),
      );

      // Find the search button in the app bar
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);

      // Tap the search button
      await tester.tap(searchButton);
      await tester.pump();

      // Verify the callback was called
      expect(searchCallbackCalled, true);
    });

    testWidgets('HomeScreen should handle null navigation callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            onNavigateToSearch: null,
          ),
        ),
      );

      // Find the search button
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);

      // Tapping should not cause any errors even with null callback
      await tester.tap(searchButton);
      await tester.pump();

      // Test passes if no exception is thrown
    });
  });
}