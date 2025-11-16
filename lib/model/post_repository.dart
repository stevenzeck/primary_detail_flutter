import '../model/post.dart';
import '../services/database_service.dart';
import '../services/http_service.dart';

class PostRepository {
  final HttpService _httpService;
  final PostDatabase _database;

  PostRepository(this._httpService, this._database);

  /// Gets posts from the local database.
  /// If the database is empty, it fetches from the network and saves them.
  Future<List<Post>> getPosts() async {
    List<Post> posts = await _database.getPosts();

    if (posts.isEmpty) {
      final newPosts = await _httpService.getPosts();
      await _database.insertPosts(newPosts);
      return newPosts;
    }

    return posts;
  }

  Future<List<Post>> refreshPosts() async {
    final posts = await _httpService.getPosts();

    final existingPosts = await _database.getPosts();
    final Map<int, Post> existingPostsMap = {
      for (var post in existingPosts) post.id: post,
    };

    for (var newPost in posts) {
      if (existingPostsMap.containsKey(newPost.id)) {
        newPost.isread = existingPostsMap[newPost.id]!.isread;
      }
    }

    await _database.insertPosts(posts);

    return posts;
  }

  /// Gets a single post from the database.
  /// If not found, fetches from the network.
  Future<Post?> getPost(int postId) async {
    Post? post = await _database.getPost(postId);

    if (post == null) {
      try {
        post = await _httpService.getPost(postId);
        await _database.insertPosts([post]);
      } catch (e) {
        return null;
      }
    }
    return post;
  }

  /// Updates a post in the database.
  Future<void> updatePost(Post post) {
    return _database.updatePost(post);
  }
}
