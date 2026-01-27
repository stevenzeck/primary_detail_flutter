import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/post_notifier.dart';
import '../../models/post.dart';

/// A widget that displays a list of posts.
// The list of posts itself is stateless
class PostList extends StatelessWidget {
  /// The list of posts to display.
  final List<Post> posts;

  /// Callback when a post is tapped.
  final ValueChanged<Post>? onTap;

  /// Callback when a post is long-pressed.
  final ValueChanged<Post>? onLongPress;

  /// Creates a [PostList].
  const PostList({
    required this.posts,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // We watch notifier here to update list items on selection change efficiently
    // Ideally we'd optimize to only rebuild the changed item, but for this scope it's fine.
    final notifier = context.watch<PostNotifier>();

    return ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isSelected = notifier.selectedIds.contains(post.id);

        return Material(
          // Highlight the item if it's selected.
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          child: InkWell(
            onTap: onTap != null ? () => onTap!(post) : null,
            onLongPress: onLongPress != null ? () => onLongPress!(post) : null,
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                post.title,
                style: TextStyle(
                  // Bold the title if the post is unread.
                  fontWeight: post.isRead == false ? .bold : .normal,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1, thickness: 1);
      },
    );
  }
}
