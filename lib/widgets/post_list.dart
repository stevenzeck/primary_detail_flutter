import 'package:flutter/material.dart';

import '../model/post.dart';

class PostList extends StatelessWidget {
  final List<Post> posts;
  final ValueChanged<Post>? onTap;

  const PostList({
    required this.posts,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) => ListTile(
            // selected: isTablet(context)
            //     ? posts[index] == selectedPost
            //     : false,
            title: Text(posts[index].title,
                style: TextStyle(
                    fontWeight: posts[index].isread == false
                        ? FontWeight.bold
                        : FontWeight.normal)),
            onTap: onTap != null ? () => onTap!(posts[index]) : null,
          ),
      separatorBuilder: (context, index) {
        return const Divider(height: 1, thickness: 1);
      });
}
