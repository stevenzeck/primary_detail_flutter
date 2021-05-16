import 'dart:convert';

import 'package:http/http.dart';

import '../model/post.dart';

class HttpService {
  final Uri postsURL = Uri.https("jsonplaceholder.typicode.com", "/posts");

  Future<List<Post>> getPosts() async {
    Response res = await get(postsURL);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Post> posts = body
          .map(
            (dynamic item) => Post.fromJson(item),
          )
          .toList();

      return posts;
    } else {
      throw Exception("Can't get posts.");
    }
  }
}
