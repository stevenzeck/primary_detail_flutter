import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:primary_detail_flutter/model/post.dart';
import 'package:primary_detail_flutter/model/post_repository.dart';

class PostNotifier extends ChangeNotifier {
  final PostRepository _repository;

  PostNotifier(this._repository) {
    fetchPosts();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Post? _selectedPost;

  Post? get selectedPost => _selectedPost;

  Future<void> fetchPosts() async {
    _setLoading(true);
    try {
      _posts = await _repository.getPosts();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> refreshPosts() async {
    try {
      _posts = await _repository.refreshPosts();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> selectPost(int? postId) async {
    if (postId == null) {
      _selectedPost = null;
      notifyListeners();
      return;
    }

    final postFromList = _posts.firstWhereOrNull((p) => p.id == postId);

    if (postFromList != null) {
      _selectedPost = postFromList;
      if (!postFromList.isread) {
        _markPostAsRead(postFromList);
      }
    } else {
      _selectedPost = await _repository.getPost(postId);
      if (_selectedPost != null && !_selectedPost!.isread) {
        _markPostAsRead(_selectedPost!);
      }
    }
    notifyListeners();
  }

  void _markPostAsRead(Post post) {
    post.isread = true;
    _repository.updatePost(post);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
  }
}
