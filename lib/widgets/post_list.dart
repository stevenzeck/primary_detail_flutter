import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';

// The list of posts itself is stateless
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
        itemBuilder: (context, index) {
          final post = posts[index];
          //FIXME using main2/list2, the tile is still selected for a second upon coming back to list from detail
          return PlatformListTile(
            key: ValueKey(post.id),
            title: Text(
              post.title,
              style: TextStyle(
                fontWeight:
                    post.isread == false ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: onTap != null
                ? () => onTap!(post) // Add null check for onTap
                : null,
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 1, thickness: 1);
        },
      );
}
