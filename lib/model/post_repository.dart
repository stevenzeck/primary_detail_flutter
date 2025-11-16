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

  /// Used in pull to refresh.
  Future<List<Post>> refreshPosts() async {
    final posts = await _httpService.getPosts();

    await _database.deleteAllPosts();
    await _database.insertPosts(posts);

    return posts;
  }

  /// Gets a single post from the database.
  Future<Post?> getPost(int postId) {
    return _database.getPost(postId);
  }

  /// Updates a post in the database.
  Future<void> updatePost(Post post) {
    return _database.updatePost(post);
  }
}
