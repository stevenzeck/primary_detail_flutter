import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../data/post_repository.dart';
import '../models/post.dart';
import 'post_state.dart';

/// Manages the state of the posts feature, including fetching, selecting, and modifying posts.
class PostNotifier extends ChangeNotifier {
  final PostRepository _repository;
  StreamSubscription<List<Post>>? _postsSubscription;

  /// Creates a [PostNotifier] and initializes data fetching.
  PostNotifier({required this._repository}) {
    _init();
  }

  PostState _state = const PostInitial();

  /// The current state of the posts (initial, loading, loaded, or error).
  PostState get state => _state;

  Post? _selectedPost;

  /// The currently selected post for detail view.
  Post? get selectedPost => _selectedPost;

  // Selection mode state
  bool _isSelectionMode = false;

  /// Whether the UI is in multi-selection mode.
  bool get isSelectionMode => _isSelectionMode;

  final Set<int> _selectedIds = {};

  /// The set of currently selected post IDs.
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);

  /// Initializes the notifier by listening to the repository stream and fetching data.
  void _init() {
    _postsSubscription = _repository.postsStream.listen(
      (posts) {
        _state = PostLoaded(posts);

        // Update the selected post if it exists in the new list.
        if (_selectedPost != null) {
          final updatedSelected = posts.firstWhereOrNull(
            (p) => p.id == _selectedPost!.id,
          );
          if (updatedSelected != null) {
            _selectedPost = updatedSelected;
          } else {
            // Post was removed (e.g. deleted), so deselect it.
            _selectedPost = null;
          }
        }
        notifyListeners();
      },
      onError: (Object error) {
        _state = PostError(error.toString());
        notifyListeners();
      },
    );

    fetchPosts();
  }

  /// Fetches the initial list of posts.
  Future<void> fetchPosts() async {
    if (_state is PostInitial) {
      _setState(const PostLoading());
    }

    try {
      await _repository.fetchAndEmitPosts();
    } catch (e) {
      _setState(PostError(e.toString()));
    }
  }

  /// Refreshes the list of posts from the API.
  Future<void> refreshPosts() async {
    try {
      await _repository.refreshPosts();
    } catch (e) {
      _setState(PostError(e.toString()));
    }
  }

  /// Selects a post by its ID and marks it as read.
  Future<void> selectPost(int? postId) async {
    if (postId == null) {
      _selectedPost = null;
      notifyListeners();
      return;
    }

    // Optimistically select from current list if available.
    if (_state case PostLoaded(:final posts)) {
      final postFromList = posts.firstWhereOrNull((p) => p.id == postId);
      if (postFromList != null) {
        _selectedPost = postFromList;
        if (!postFromList.isRead) {
          await setReadStatus(postFromList, true);
        }
        notifyListeners();
        return;
      }
    }

    // If not in current list, fetch individual post (e.g. from deep link).
    try {
      final post = await _repository.getPost(postId);
      _selectedPost = post;

      if (_selectedPost != null && !_selectedPost!.isRead) {
        await setReadStatus(_selectedPost!, true);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting post: $e');
    }
  }

  /// Sets the read status of a single post.
  Future<void> setReadStatus(Post post, bool isRead) async {
    try {
      await _repository.updatePost(post.copyWith(isRead: isRead));
    } catch (e) {
      debugPrint('Error updating read status: $e');
    }
  }

  void _setState(PostState newState) {
    _state = newState;
    notifyListeners();
  }

  // --- Selection Mode Logic ---

  /// Enters selection mode, optionally selecting an initial item.
  void enterSelectionMode(int? initialId) {
    _isSelectionMode = true;
    _selectedIds.clear();
    if (initialId != null) {
      _selectedIds.add(initialId);
    }
    notifyListeners();
  }

  /// Exits selection mode and clears selection.
  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }

  /// Toggles the selection state of a post ID.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      // Optional: Auto-exit selection mode if last item deselected?
      // For now, let's keep selection mode active even if empty, until user cancels or acts.
      // But typically Android auto-exits if 0 items. iOS Edit mode usually stays.
      // We will leave it to the UI to decide or user to explicitly cancel.
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Deletes all currently selected posts.
  Future<void> deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    try {
      await _repository.deletePosts(_selectedIds.toList());
      exitSelectionMode();
    } catch (e) {
      debugPrint('Error deleting selected posts: $e');
    }
  }

  /// Deletes a single post by ID.
  Future<void> deletePost(int id) async {
    try {
      await _repository.deletePost(id);
      // If the deleted post was selected for viewing, it's handled in the listener.
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
  }

  /// Marks all selected posts as read.
  Future<void> markSelectedAsRead() async {
    if (_selectedIds.isEmpty) return;

    if (_state case PostLoaded(:final posts)) {
      final postsToUpdate = posts
          .where((p) => _selectedIds.contains(p.id) && !p.isRead)
          .toList();

      for (var post in postsToUpdate) {
        // We can optimize this by adding bulk update to repo if needed,
        // but for now iterating is fine.
        await _repository.updatePost(post.copyWith(isRead: true));
      }
    }
    exitSelectionMode();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}
