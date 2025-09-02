import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick_finder/presentation/widgets/add_to_list_dialog.dart';
import 'package:flick_finder/domain/entities/movie.dart';

void main() {
  group('Add to List Dialog Tests', () {
    testWidgets('should show login message for unauthenticated users', (WidgetTester tester) async {
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        description: 'Test overview',
        posterPath: '/test.jpg',
        backdropPath: '/test_backdrop.jpg',
        releaseDate: DateTime(2023, 1, 1),
        rating: 7.5,
        voteCount: 1000,
        genreIds: [28, 12],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddToListDialog(
                        movieId: 1,
                        movieTitle: 'Test Movie',
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Manage "Test Movie" Lists'), findsOneWidget);
      
      // Verify login message is shown for unauthenticated users
      expect(find.text('Please login with your TMDB account to add movies to your lists.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should show dialog title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddToListDialog(
                        movieId: 123,
                        movieTitle: 'Inception',
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Manage "Inception" Lists'), findsOneWidget);
    });
  });
}