import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../services/utils.dart';

class PostsListScreen extends StatelessWidget {
  final List<Post> posts;
  final ValueChanged<Post> onTapped;
  final Post selectedPost;

  PostsListScreen(
      {@required this.posts,
      @required this.onTapped,
      @required this.selectedPost});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Posts"),
          automaticallyImplyLeading: true,
        ),
        body: ListView.separated(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            Post post = posts[index];
            return Material(
                child: GestureDetector(
                    child: ListTile(
              selected:
                  isTablet(context) ? posts[index] == selectedPost : false,
              title: Text(post.title,
                  style: TextStyle(
                      fontWeight: post.isread == 0
                          ? FontWeight.bold
                          : FontWeight.normal)),
              onTap: () => onTapped(post),
            )));
          },
          separatorBuilder: (context, index) {
            return Divider(height: 1, thickness: 1);
          },
        ));
  }
}
