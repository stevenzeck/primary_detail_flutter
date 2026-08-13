import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:primary_detail_flutter/core/widgets/adaptive_dialog_action.dart';
import 'package:primary_detail_flutter/features/posts/logic/post_notifier.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';
import 'package:primary_detail_flutter/features/posts/ui/screens/post_list_screen.dart';
import 'package:provider/provider.dart';

import '../../logic/post_notifier_test.dart';

void main() {
  late MockPostRepository mockRepository;
  late PostNotifier postNotifier;

  setUp(() {
    mockRepository = MockPostRepository();
    // Prevent the mock from emitting immediately so we can catch the loading state
    mockRepository.fetchAndEmitCompleter = Completer<void>();
    postNotifier = PostNotifier(repository: mockRepository);
  });

  Widget createWidgetUnderTest({
    TargetPlatform platform = TargetPlatform.android,
    bool showBackButton = true,
    GoRouter? router,
  }) {
    final widget = ChangeNotifierProvider<PostNotifier>.value(
      value: postNotifier,
      child: PostsListScreen(showBackButton: showBackButton),
    );

    if (router != null) {
      return MaterialApp.router(
        theme: ThemeData(platform: platform),
        routerConfig: router,
      );
    }

    return MaterialApp(
      theme: ThemeData(platform: platform),
      home: widget,
    );
  }

  group('PostsListScreen', () {
    testWidgets('renders loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // On Android, it should show CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders CupertinoActivityIndicator on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no posts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit([]);
      await tester.pump();

      expect(find.text('No posts available.'), findsOneWidget);
    });

    testWidgets('renders error state and retry works (Android)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emitError('Network failed');
      await tester.pump();

      expect(find.text('Error: Network failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(mockRepository.refreshPostsCalled, isTrue);
    });

    testWidgets('renders error state and retry works (iOS)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emitError('Network failed');
      await tester.pump();

      expect(find.text('Error: Network failed'), findsOneWidget);
      expect(
        find.byIcon(CupertinoIcons.exclamationmark_circle_fill),
        findsOneWidget,
      );
      expect(
        find.byType(CupertinoButton),
        findsNWidgets(2),
      ); // Edit button and Retry button

      await tester.tap(find.text('Retry'));
      expect(mockRepository.refreshPostsCalled, isTrue);
    });

    testWidgets('renders list of posts and checks font weight', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Unread Post',
          body: 'Body 1',
          isRead: false,
        ),
        Post(
          id: const PostId(2),
          userId: const UserId(1),
          title: 'Read Post',
          body: 'Body 2',
          isRead: true,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest());

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      final unreadText = tester.widget<Text>(find.text('Unread Post'));
      expect(unreadText.style?.fontWeight, FontWeight.bold);

      final readText = tester.widget<Text>(find.text('Read Post'));
      expect(readText.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('navigates to post detail on tap', (WidgetTester tester) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                ChangeNotifierProvider<PostNotifier>.value(
                  value: postNotifier,
                  child: const PostsListScreen(),
                ),
          ),
          GoRoute(
            path: '/posts/:id',
            builder: (context, state) =>
                const Scaffold(body: Text('Post Detail Page')),
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(router: router));
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.tap(find.text('Post 1'));
      await tester.pumpAndSettle();

      expect(find.text('Post Detail Page'), findsOneWidget);
    });

    testWidgets('enters selection mode on long press (Android)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();

      expect(postNotifier.isSelectionMode, isTrue);
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('enters selection mode on long press (Fuchsia)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.fuchsia),
      );

      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();

      expect(postNotifier.isSelectionMode, isTrue);
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('exits selection mode via close icon (Android)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.isSelectionMode, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(postNotifier.isSelectionMode, isFalse);
    });

    testWidgets('selection mode actions and cancel dialog (Android)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();

      // Mark as read
      await tester.tap(find.byIcon(Icons.mark_email_read));
      await tester.pump();
      expect(mockRepository.updatePostCalled, isTrue);
      expect(postNotifier.isSelectionMode, isFalse);

      // Re-enter selection mode for delete test
      await tester.longPress(find.text('Post 1'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Posts'), findsOneWidget);

      // Test Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(mockRepository.deletePostsCalled, isFalse);
      expect(postNotifier.isSelectionMode, isTrue);

      // Test Confirm Delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AdaptiveDialogAction),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.deletePostsCalled, isTrue);
    });

    testWidgets('selection mode early return when count is 0 (Android)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();

      // Deselect the item
      await tester.tap(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, isEmpty);

      // Click delete - should do nothing (early return)
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Posts'), findsNothing);
    });

    testWidgets('selection mode actions, toggling and exit (iOS)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
        Post(
          id: const PostId(2),
          userId: const UserId(1),
          title: 'Post 2',
          body: 'Body 2',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      // Verify dividers on iOS
      expect(find.byType(Divider), findsOneWidget);

      // iOS enters selection mode via 'Edit' button
      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(postNotifier.isSelectionMode, isTrue);
      expect(find.text('Done'), findsOneWidget);

      // Select an item and check icons
      expect(find.byIcon(CupertinoIcons.circle), findsNWidgets(2));
      await tester.tap(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, contains(1));
      expect(
        find.byIcon(CupertinoIcons.check_mark_circled_solid),
        findsOneWidget,
      );
      expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);

      // Deselect via tap
      await tester.tap(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, isEmpty);
      expect(find.byIcon(CupertinoIcons.circle), findsNWidgets(2));

      // Select again for action
      await tester.tap(find.text('Post 1'));
      await tester.pump();

      // Bottom toolbar actions
      expect(find.text('Mark Read'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Mark Read'));
      await tester.pump();
      expect(mockRepository.updatePostCalled, isTrue);
      expect(postNotifier.isSelectionMode, isFalse);

      // Re-enter and test Done button
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(postNotifier.isSelectionMode, isFalse);
    });

    testWidgets(
      'iOS bottom toolbar buttons are disabled when no items selected',
      (WidgetTester tester) async {
        final posts = [
          Post(
            id: const PostId(1),
            userId: const UserId(1),
            title: 'Post 1',
            body: 'Body 1',
          ),
        ];

        await tester.pumpWidget(
          createWidgetUnderTest(platform: TargetPlatform.iOS),
        );
        mockRepository.fetchAndEmitCompleter!.complete();
        mockRepository.emit(posts);
        await tester.pump();

        await tester.tap(find.text('Edit'));
        await tester.pump();

        // Mark Read and Delete should be present but their callbacks null if disabled
        final markReadButton = tester.widget<CupertinoButton>(
          find.widgetWithText(CupertinoButton, 'Mark Read'),
        );
        expect(markReadButton.onPressed, isNull);

        final deleteButton = tester.widget<CupertinoButton>(
          find.widgetWithText(CupertinoButton, 'Delete'),
        );
        expect(deleteButton.onPressed, isNull);
      },
    );

    testWidgets('Delete via bottom toolbar (iOS)', (WidgetTester tester) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.tap(find.text('Post 1'));
      await tester.pump();

      // Target the 'Delete' button in the toolbar, not the one in the dialog (yet)
      await tester.tap(find.widgetWithText(CupertinoButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Posts'), findsOneWidget);
      // Now tap 'Delete' in the dialog
      await tester.tap(
        find.descendant(
          of: find.byType(AdaptiveDialogAction),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.deletePostsCalled, isTrue);
    });

    testWidgets('toggles selection via tap when in selection mode (Android)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      await tester.longPress(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, contains(1));

      // Tap to deselect
      await tester.tap(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, isEmpty);

      // Tap to re-select
      await tester.tap(find.text('Post 1'));
      await tester.pump();
      expect(postNotifier.selectedIds, contains(1));
    });

    testWidgets(
      'long press toggles selection when already in selection mode (Android)',
      (WidgetTester tester) async {
        final posts = [
          Post(
            id: const PostId(1),
            userId: const UserId(1),
            title: 'Post 1',
            body: 'Body 1',
          ),
          Post(
            id: const PostId(2),
            userId: const UserId(1),
            title: 'Post 2',
            body: 'Body 2',
          ),
        ];

        await tester.pumpWidget(
          createWidgetUnderTest(platform: TargetPlatform.android),
        );
        mockRepository.fetchAndEmitCompleter!.complete();
        mockRepository.emit(posts);
        await tester.pump();

        await tester.longPress(find.text('Post 1'));
        await tester.pump();
        expect(postNotifier.selectedIds, contains(1));

        // Long press second item
        await tester.longPress(find.text('Post 2'));
        await tester.pump();
        expect(postNotifier.selectedIds, contains(1));
        expect(postNotifier.selectedIds, contains(2));

        // Long press first item to deselect
        await tester.longPress(find.text('Post 1'));
        await tester.pump();
        expect(postNotifier.selectedIds, isNot(contains(1)));
        expect(postNotifier.selectedIds, contains(2));
      },
    );

    testWidgets('swipe to delete and cancel (iOS)', (
      WidgetTester tester,
    ) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      // Swipe left to reveal actions
      await tester.drag(find.text('Post 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Find delete button
      expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);

      // Tap delete icon to trigger dialog
      await tester.tap(find.byIcon(CupertinoIcons.delete), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Delete Post'), findsOneWidget);

      // Test Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(mockRepository.deletePostCalled, isFalse);
      expect(find.text('Post 1'), findsOneWidget);

      // Trigger again and Confirm
      await tester.drag(find.text('Post 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.delete), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AdaptiveDialogAction),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.deletePostCalled, isTrue);
    });

    testWidgets('pull to refresh (Android)', (WidgetTester tester) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest());
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      // Pull down to refresh
      await tester.drag(find.text('Post 1'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(mockRepository.refreshPostsCalled, isTrue);
    });

    testWidgets('pull to refresh (iOS)', (WidgetTester tester) async {
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Post 1',
          body: 'Body 1',
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      mockRepository.fetchAndEmitCompleter!.complete();
      mockRepository.emit(posts);
      await tester.pump();

      // Pull down to refresh (CupertinoSliverRefreshControl)
      await tester.drag(find.text('Post 1'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(mockRepository.refreshPostsCalled, isTrue);
    });

    testWidgets('respects showBackButton parameter', (
      WidgetTester tester,
    ) async {
      // Internal function to test a specific value of showBackButton
      Future<void> testWith(bool value) async {
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(), // Force fresh widget tree
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: TextButton(
                    key: const Key('push_button'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            ChangeNotifierProvider<PostNotifier>.value(
                              value: postNotifier,
                              child: PostsListScreen(showBackButton: value),
                            ),
                      ),
                    ),
                    child: const Text('Push'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('push_button')));
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 500),
        ); // Wait for transition

        mockRepository.fetchAndEmitCompleter!.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        if (value) {
          expect(find.byType(BackButton), findsOneWidget);
        } else {
          expect(find.byType(BackButton), findsNothing);
        }

        // Reset for next run if needed
        mockRepository.fetchAndEmitCompleter = Completer<void>();
      }

      await testWith(false);
      await testWith(true);
    });
  });
}
