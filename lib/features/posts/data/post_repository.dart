import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/http_service.dart';
import '../models/post.dart';

/// Repository class to act as a single source of truth for post data,
/// coordinating between the local database and the remote API.
class PostRepository {
  final HttpService _httpService;
  final PostDatabase _database;

  /// Stream controller to broadcast updates to the list of posts.
  final _postsStreamController = StreamController<List<Post>>.broadcast();

  /// Creates a [PostRepository] with dependencies.
  PostRepository(this._httpService, this._database);

  /// Exposes the stream of posts.
  Stream<List<Post>> get postsStream => _postsStreamController.stream;

  /// Fetches posts from the DB and emits them immediately.
  /// Then attempts to refresh data from the API in the background.
  Future<void> fetchAndEmitPosts() async {
    // Emit local data first for instant UI feedback.
    await _emitLatestDbData();
    try {
      // Fetch fresh data from the network.
      await refreshPosts();
    } catch (e) {
      // If network fails, check if we have local data.
      final localPosts = await _database.getPosts();
      if (localPosts.isEmpty) {
        // If no local data and network failed, propagate the error.
        rethrow;
      }
      // Otherwise, log the error and keep showing local data.
      debugPrint('Background refresh failed: $e');
    }
  }

  /// Fetches from API, merges with local data (to preserve `isRead` status),
  /// and updates the Database (Source of Truth).
  Future<void> refreshPosts() async {
    try {
      final apiPosts = await _httpService.getPosts();
      final existingPosts = await _database.getPosts();

      // Create a map for O(1) lookup of existing posts.
      final existingPostsMap = {for (var post in existingPosts) post.id: post};

      // Merge API data with local state (isRead).
      final mergedPosts = apiPosts.map((apiPost) {
        final localPost = existingPostsMap[apiPost.id];
        if (localPost != null) {
          return apiPost.copyWith(isRead: localPost.isRead);
        }
        return apiPost;
      }).toList();

      // Save merged data to the local database.
      await _database.insertPosts(mergedPosts);
      // Emit the updated data from the database.
      await _emitLatestDbData();
    } catch (e) {
      _postsStreamController.addError(e);
      rethrow;
    }
  }

  /// Gets a single post.
  /// Tries the DB first. If missing, fetches from API and updates DB.
  Future<Post?> getPost(int postId) async {
    Post? post = await _database.getPost(postId);
    if (post == null) {
      try {
        post = await _httpService.getPost(postId);
        // Cache the fetched post locally.
        await _database.insertPosts([post]);
        await _emitLatestDbData();
      } catch (e) {
        return null;
      }
    }
    return post;
  }

  /// Updates a post in the database and emits the change (e.g. marking as read).
  Future<void> updatePost(Post post) async {
    await _database.updatePost(post);
    await _emitLatestDbData();
  }

  /// Deletes a post by ID and emits the change.
  Future<void> deletePost(int id) async {
    await _database.deletePost(id);
    await _emitLatestDbData();
  }

  /// Deletes multiple posts by IDs and emits the change.
  Future<void> deletePosts(List<int> ids) async {
    await _database.deletePosts(ids);
    await _emitLatestDbData();
  }

  /// Helper to read the DB and push the current state to the stream.
  Future<void> _emitLatestDbData() async {
    final posts = await _database.getPosts();
    _postsStreamController.add(posts);
  }

  /// Disposes resources.
  void dispose() {
    _postsStreamController.close();
  }
}
