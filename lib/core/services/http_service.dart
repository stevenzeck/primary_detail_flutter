import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../../features/posts/models/post.dart';

/// A service class responsible for making HTTP requests.
class HttpService {
  /// The base URL for the API.
  final String baseUrl;

  /// The HTTP client to perform requests.
  final http.Client client;

  /// Creates an [HttpService] with a base URL and an optional client.
  HttpService({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Fetches a list of posts from the API.
  Future<List<Post>> getPosts() async {
    try {
      final res = await client
          .get(Uri.https(baseUrl, AppConstants.apiPostsPath))
          .timeout(AppConstants.apiTimeout);

      if (res.statusCode == 200) {
        // Parses the posts in a separate isolate to avoid blocking the UI.
        return await compute(_parsePosts, res.body);
      } else {
        throw PostNetworkException(
          "Can't get posts (Status: ${res.statusCode}).",
        );
      }
    } on TimeoutException {
      throw PostNetworkException('Request timed out.');
    } on http.ClientException {
      throw PostNetworkException("Can't connect to the server.");
    } on FormatException {
      throw PostNetworkException('Invalid server response format.');
    } catch (e) {
      if (e is PostNetworkException) rethrow;
      throw PostNetworkException('Unknown error: $e');
    }
  }

  /// Fetches a single post by its ID.
  Future<Post> getPost(int postId) async {
    final Uri postURL = Uri.https(
      baseUrl,
      '${AppConstants.apiPostsPath}/$postId',
    );
    try {
      final res = await client.get(postURL).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Post.fromJson(body);
      } else {
        throw PostNetworkException(
          "Can't get post (Status: ${res.statusCode}).",
        );
      }
    } on TimeoutException {
      throw PostNetworkException('Request timed out.');
    } on http.ClientException {
      throw PostNetworkException("Can't connect to the server.");
    } on FormatException {
      throw PostNetworkException('Invalid server response format.');
    } catch (e) {
      if (e is PostNetworkException) rethrow;
      throw PostNetworkException('Unknown error: $e');
    }
  }
}

/// A custom exception class for network-related errors fetching posts.
class PostNetworkException implements Exception {
  /// The error message.
  final String message;

  /// Creates a [PostNetworkException].
  PostNetworkException(this.message);

  @override
  String toString() => message;
}

/// Helper function to parse a JSON string into a list of [Post] objects.
///
/// This is a top-level function so it can be passed to [compute].
List<Post> _parsePosts(String responseBody) {
  final body = jsonDecode(responseBody) as List<dynamic>;
  return body
      .map((dynamic item) => Post.fromJson(item as Map<String, dynamic>))
      .toList();
}
