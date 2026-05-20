import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:primary_detail_flutter/features/posts/data/post_repository.dart';
import 'package:primary_detail_flutter/features/posts/logic/post_notifier.dart';
import 'package:primary_detail_flutter/features/posts/logic/post_state.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';

/// Manual mock for PostRepository to avoid external dependencies during tests.
class MockPostRepository implements PostRepository {
  final _controller = StreamController<List<Post>>.broadcast();

  @override
  Stream<List<Post>> get postsStream => _controller.stream;

  List<Post> _posts = [];
  bool fetchAndEmitPostsCalled = false;
  bool refreshPostsCalled = false;
  bool getPostCalled = false;
  bool updatePostCalled = false;
  bool deletePostCalled = false;
  bool deletePostsCalled = false;
  bool disposeCalled = false;

  Completer<void>? fetchAndEmitCompleter;
  Object? fetchAndEmitError;
  Object? refreshError;
  Object? getPostError;
  Object? deletePostError;
  Object? deletePostsError;

  @override
  Future<void> fetchAndEmitPosts() async {
    fetchAndEmitPostsCalled = true;
    if (fetchAndEmitCompleter != null) {
      await fetchAndEmitCompleter!.future;
    }
    if (fetchAndEmitError != null) {
      throw fetchAndEmitError!;
    }
    _controller.add(_posts);
  }

  @override
  Future<void> refreshPosts() async {
    refreshPostsCalled = true;
    if (refreshError != null) {
      throw refreshError!;
    }
  }

  @override
  Future<Post?> getPost(int postId) async {
    getPostCalled = true;
    if (getPostError != null) {
      throw getPostError!;
    }
    final post = _posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) throw Exception('Not found');
    return post;
  }

  @override
  Future<void> updatePost(Post post) async {
    updatePostCalled = true;
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
      _controller.add(_posts);
    }
  }

  @override
  Future<void> deletePost(int id) async {
    deletePostCalled = true;
    if (deletePostError != null) {
      throw deletePostError!;
    }
    _posts.removeWhere((p) => p.id == id);
    _controller.add(_posts);
  }

  @override
  Future<void> deletePosts(List<int> ids) async {
    deletePostsCalled = true;
    if (deletePostsError != null) {
      throw deletePostsError!;
    }
    _posts.removeWhere((p) => ids.contains(p.id));
    _controller.add(_posts);
  }

  @override
  void dispose() {
    disposeCalled = true;
    _controller.close();
  }

  /// Helper method to simulate database updates and emit new state to stream.
  void emit(List<Post> posts) {
    _posts = posts.toList(); // copy to mutable list
    _controller.add(_posts);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }
}

extension on List<Post> {
  Post? firstWhereOrNull(bool Function(Post) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

void main() {
  group('PostNotifier', () {
    late MockPostRepository mockRepository;
    late PostNotifier notifier;

    setUp(() {
      mockRepository = MockPostRepository();
    });

    test('initial state transitions to PostLoading then PostLoaded', () async {
      mockRepository.fetchAndEmitCompleter = Completer<void>();
      notifier = PostNotifier(repository: mockRepository);

      expect(notifier.state, isA<PostLoading>());

      mockRepository.fetchAndEmitCompleter!.complete();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<PostLoaded>());
    });

    test('fetchPosts sets PostError on failure', () async {
      mockRepository.fetchAndEmitError = Exception('Fetch failed');
      notifier = PostNotifier(repository: mockRepository);

      await notifier.fetchPosts();

      expect(notifier.state, isA<PostError>());
      expect((notifier.state as PostError).message, contains('Fetch failed'));
    });

    test('emits PostLoaded when repository emits posts', () async {
      notifier = PostNotifier(repository: mockRepository);

      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Title',
          body: 'Body',
        ),
      ];

      mockRepository.emit(posts);

      // Wait for the stream listener to process
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<PostLoaded>());
      final loaded = notifier.state as PostLoaded;
      expect(loaded.posts, equals(posts));
    });

    test('updates selectedPost when new list is emitted', () async {
      notifier = PostNotifier(repository: mockRepository);
      final p1 = Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'T1',
        body: 'B1',
      );
      mockRepository.emit([p1]);
      await Future<void>.delayed(Duration.zero);

      await notifier.selectPost(1);
      expect(notifier.selectedPost!.title, 'T1');

      final p1Updated = p1.copyWith(title: 'T1 Updated');
      mockRepository.emit([p1Updated]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.selectedPost!.title, 'T1 Updated');
    });

    test('deselects post if it is removed from the list', () async {
      notifier = PostNotifier(repository: mockRepository);
      final p1 = Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'T1',
        body: 'B1',
      );
      mockRepository.emit([p1]);
      await Future<void>.delayed(Duration.zero);

      await notifier.selectPost(1);
      expect(notifier.selectedPost, isNotNull);

      mockRepository.emit([]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.selectedPost, isNull);
    });

    test('emits PostError on repository stream error', () async {
      // Use a completer to prevent fetchAndEmitPosts from emitting an empty list after the error
      mockRepository.fetchAndEmitCompleter = Completer<void>();
      notifier = PostNotifier(repository: mockRepository);

      mockRepository.emitError('Stream failure');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isA<PostError>());
      expect((notifier.state as PostError).message, 'Stream failure');
    });

    test('refreshPosts calls repository refresh', () async {
      notifier = PostNotifier(repository: mockRepository);
      await notifier.refreshPosts();
      expect(mockRepository.refreshPostsCalled, true);
    });

    test('refreshPosts sets PostError on failure', () async {
      notifier = PostNotifier(repository: mockRepository);
      mockRepository.refreshError = Exception('Refresh failed');

      await notifier.refreshPosts();

      expect(notifier.state, isA<PostError>());
      expect((notifier.state as PostError).message, contains('Refresh failed'));
    });

    test('selectPost(null) deselects post', () async {
      notifier = PostNotifier(repository: mockRepository);
      final p1 = Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'T1',
        body: 'B1',
      );
      mockRepository.emit([p1]);
      await Future<void>.delayed(Duration.zero);

      await notifier.selectPost(1);
      expect(notifier.selectedPost, isNotNull);

      await notifier.selectPost(null);
      expect(notifier.selectedPost, isNull);
    });

    test('selectPost fetches from repository if not in current state', () async {
      notifier = PostNotifier(repository: mockRepository);
      final post = Post(
        id: const PostId(99),
        userId: const UserId(1),
        title: 'T',
        body: 'B',
      );
      mockRepository.emit([post]);
      await Future<void>.delayed(Duration.zero);

      // Clear the state to simulate post not being in list (e.g. deep link before fetch)
      // Actually selectPost checks the state. If we want it to fetch from repo,
      // it must not be in the current PostLoaded.posts.

      mockRepository.emit([]); // Empty the current state
      await Future<void>.delayed(Duration.zero);

      // Put it back in mock's internal list so getPost can find it
      mockRepository._posts = [post];

      await notifier.selectPost(99);
      expect(notifier.selectedPost!.id, 99);
      expect(mockRepository.getPostCalled, true);
    });

    test('selectPost handles error when getPost fails', () async {
      notifier = PostNotifier(repository: mockRepository);
      mockRepository.emit([]);
      await Future<void>.delayed(Duration.zero);

      mockRepository.getPostError = Exception('Get post failed');

      // This should not throw, but log via debugPrint
      await notifier.selectPost(99);

      expect(notifier.selectedPost, isNull);
      expect(mockRepository.getPostCalled, true);
    });

    test('selectPost marks post as read', () async {
      notifier = PostNotifier(repository: mockRepository);

      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'Title 1',
          body: 'Body 1',
          isRead: false,
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      await notifier.selectPost(1);

      // Wait for repository update to propagate
      await Future<void>.delayed(Duration.zero);

      // The repository mock should have updated the post and emitted it back
      final loaded = notifier.state as PostLoaded;
      expect(loaded.posts.first.isRead, true);
      expect(notifier.selectedPost!.isRead, true);
    });

    test('enterSelectionMode initializes selection correctly', () {
      notifier = PostNotifier(repository: mockRepository);

      notifier.enterSelectionMode(1);

      expect(notifier.isSelectionMode, true);
      expect(notifier.selectedIds, contains(1));
    });

    test('toggleSelection adds and removes ids', () {
      notifier = PostNotifier(repository: mockRepository);
      notifier.enterSelectionMode(null);

      notifier.toggleSelection(1);
      expect(notifier.selectedIds, contains(1));

      notifier.toggleSelection(1);
      expect(notifier.selectedIds, isNot(contains(1)));
    });

    test('exitSelectionMode clears selection', () {
      notifier = PostNotifier(repository: mockRepository);
      notifier.enterSelectionMode(1);

      notifier.exitSelectionMode();

      expect(notifier.isSelectionMode, false);
      expect(notifier.selectedIds, isEmpty);
    });

    test('deleteSelected removes posts and exits selection mode', () async {
      notifier = PostNotifier(repository: mockRepository);
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'T1',
          body: 'B1',
        ),
        Post(
          id: const PostId(2),
          userId: const UserId(1),
          title: 'T2',
          body: 'B2',
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      notifier.enterSelectionMode(1);
      await notifier.deleteSelected();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isSelectionMode, false);
      expect(notifier.selectedIds, isEmpty);

      final loaded = notifier.state as PostLoaded;
      expect(loaded.posts.length, 1);
      expect(loaded.posts.first.id, 2);
    });

    test('deleteSelected handles error', () async {
      notifier = PostNotifier(repository: mockRepository);
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'T1',
          body: 'B1',
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      notifier.enterSelectionMode(1);
      mockRepository.deletePostsError = Exception('Delete selected failed');

      // Should not throw, but log via debugPrint
      await notifier.deleteSelected();

      expect(notifier.isSelectionMode, true); // Still in selection mode
      expect(notifier.selectedIds, contains(1));
    });

    test('markSelectedAsRead updates posts and exits selection mode', () async {
      notifier = PostNotifier(repository: mockRepository);
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'T1',
          body: 'B1',
          isRead: false,
        ),
        Post(
          id: const PostId(2),
          userId: const UserId(1),
          title: 'T2',
          body: 'B2',
          isRead: false,
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      notifier.enterSelectionMode(1);
      await notifier.markSelectedAsRead();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isSelectionMode, false);

      final loaded = notifier.state as PostLoaded;
      final p1 = loaded.posts.firstWhere((p) => p.id == 1);
      final p2 = loaded.posts.firstWhere((p) => p.id == 2);

      expect(p1.isRead, true);
      expect(p2.isRead, false); // Not selected, should remain unread
    });

    test('deletePost removes single post', () async {
      notifier = PostNotifier(repository: mockRepository);
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'T1',
          body: 'B1',
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      await notifier.deletePost(1);
      await Future<void>.delayed(Duration.zero);

      final loaded = notifier.state as PostLoaded;
      expect(loaded.posts, isEmpty);
    });

    test('deletePost handles error', () async {
      notifier = PostNotifier(repository: mockRepository);
      final posts = [
        Post(
          id: const PostId(1),
          userId: const UserId(1),
          title: 'T1',
          body: 'B1',
        ),
      ];
      mockRepository.emit(posts);
      await Future<void>.delayed(Duration.zero);

      mockRepository.deletePostError = Exception('Delete post failed');

      // Should not throw, but log via debugPrint
      await notifier.deletePost(1);

      final loaded = notifier.state as PostLoaded;
      expect(loaded.posts.length, 1); // Post not deleted
    });

    test('dispose cancels subscription', () {
      notifier = PostNotifier(repository: mockRepository);
      notifier.dispose();
      expect(
        mockRepository.disposeCalled,
        false,
      ); // repository shouldn't be disposed by notifier
    });
  });
}
