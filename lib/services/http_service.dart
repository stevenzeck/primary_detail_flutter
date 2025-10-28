import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../model/post.dart';

class HttpService {
  final Uri postsURL = Uri.https("jsonplaceholder.typicode.com", "/posts");

  Future<List<Post>> getPosts() async {
    // Handle network exceptions and response errors
    try {
      Response res = await get(postsURL).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);

        // Convert the dynamic list to a list of Post objects
        List<Post> posts = body
            .map((dynamic item) => Post.fromMap(item))
            .toList();

        return posts;
      } else {
        throw Exception("Can't get posts.");
      }
    } on TimeoutException {
      throw Exception("Request timed out.");
    } on ClientException {
      throw Exception("Can't connect to the server.");
    } on FormatException {
      throw Exception("Invalid server response format.");
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }
}
