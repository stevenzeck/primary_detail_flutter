import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/adaptive_dialog_action.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../logic/post_notifier.dart';
import '../../logic/post_state.dart';
import '../../models/post.dart';
import '../widgets/post_list_item.dart';

/// The screen that displays the list of posts.
class PostsListScreen extends StatelessWidget {
  /// Whether to show the back button in the AppBar.
  final bool showBackButton;

  /// Creates the [PostsListScreen].
  const PostsListScreen({this.showBackButton = true, super.key});

  @override
  Widget build(BuildContext context) {
    // Watch selection mode to update AppBar
    final PostNotifier(:isSelectionMode, :selectedIds) = context
        .watch<PostNotifier>();
    final selectedCount = selectedIds.length;
    final platform = Theme.of(context).platform;
    final isCupertinoMode =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final isMaterialMode = !isCupertinoMode;

    // Android-specific AppBar when in selection mode
    final shouldShowSelectionAppBar = isMaterialMode && isSelectionMode;

    return AppScaffold(
      title: shouldShowSelectionAppBar
          ? Text('$selectedCount selected')
          : const Text('Posts'),
      backgroundColor: shouldShowSelectionAppBar
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
      automaticallyImplyLeading: showBackButton && !shouldShowSelectionAppBar,
      leading: shouldShowSelectionAppBar
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<PostNotifier>().exitSelectionMode(),
            )
          : null,
      actions: [
        if (shouldShowSelectionAppBar) ...[
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark as read',
            onPressed: () => context.read<PostNotifier>().markSelectedAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
        if (isCupertinoMode)
          // Use standard button here, or AdaptiveDialogAction if simpler
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (isSelectionMode) {
                context.read<PostNotifier>().exitSelectionMode();
              } else {
                context.read<PostNotifier>().enterSelectionMode(null);
              }
            },
            child: Text(isSelectionMode ? 'Done' : 'Edit'),
          ),
      ],
      body: Stack(
        children: [
          const _PostListBody(),
          if (isCupertinoMode && isSelectionMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CupertinoBottomToolbar(
                onMarkRead: () =>
                    context.read<PostNotifier>().markSelectedAsRead(),
                onDelete: () => _showDeleteConfirmation(context),
                enabled: selectedCount > 0,
              ),
            ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting posts.
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final notifier = context.read<PostNotifier>();
    final count = notifier.selectedIds.length;

    if (count == 0) return;

    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Posts'),
        content: Text('Delete $count selected posts?'),
        actions: [
          AdaptiveDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          AdaptiveDialogAction(
            isDestructive: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.deleteSelected();
    }
  }
}

/// A bottom toolbar for iOS-style selection mode actions.
class _CupertinoBottomToolbar extends StatelessWidget {
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final bool enabled;

  const _CupertinoBottomToolbar({
    required this.onMarkRead,
    required this.onDelete,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemGroupedBackground,
      padding: const .only(top: 10, bottom: 20),
      // Basic safe area handling
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          CupertinoButton(
            onPressed: enabled ? onMarkRead : null,
            child: const Text('Mark Read'),
          ),
          CupertinoButton(
            onPressed: enabled ? onDelete : null,
            child: const Text(
              'Delete',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
        ],
      ),
    );
  }
}

/// The body content of the post list screen, handling loading, error, and data states.
class _PostListBody extends StatelessWidget {
  const _PostListBody();

  @override
  Widget build(BuildContext context) {
    final state = context.select<PostNotifier, PostState>((n) => n.state);

    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return switch (state) {
      PostInitial() || PostLoading() => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      PostError(message: final msg) => Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(
              isCupertino
                  ? CupertinoIcons.exclamationmark_circle_fill
                  : Icons.error,
              size: 50,
              color: Colors.red,
            ),
            Text('Error: $msg'),
            isCupertino
                ? CupertinoButton(
                    onPressed: () =>
                        context.read<PostNotifier>().refreshPosts(),
                    child: const Text('Retry'),
                  )
                : TextButton(
                    onPressed: () =>
                        context.read<PostNotifier>().refreshPosts(),
                    child: const Text('Retry'),
                  ),
          ],
        ),
      ),
      PostLoaded(posts: final posts) =>
        posts.isEmpty
            ? const Center(child: Text('No posts available.'))
            : _ActivePostList(posts: posts),
    };
  }
}

/// The active list of posts when data is loaded.
class _ActivePostList extends StatelessWidget {
  final List<Post> posts;

  const _ActivePostList({required this.posts});

  Future<void> _refresh(BuildContext context) async {
    await context.read<PostNotifier>().refreshPosts();
  }

  void _onTap(BuildContext context, Post post) {
    final notifier = context.read<PostNotifier>();
    if (notifier.isSelectionMode) {
      notifier.toggleSelection(post.id);
    } else {
      context.go('/posts/${post.id}');
    }
  }

  void _onLongPress(BuildContext context, Post post) {
    final platform = Theme.of(context).platform;
    final isMaterial =
        platform == TargetPlatform.android ||
        platform == TargetPlatform.fuchsia;

    if (isMaterial) {
      final notifier = context.read<PostNotifier>();
      if (!notifier.isSelectionMode) {
        notifier.enterSelectionMode(post.id);
      } else {
        notifier.toggleSelection(post.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PostNotifier>();
    final isSelectionMode = notifier.isSelectionMode;

    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return CustomScrollView(
        slivers: [
          if (!isSelectionMode)
            CupertinoSliverRefreshControl(onRefresh: () => _refresh(context)),
          SliverSafeArea(
            bottom: isSelectionMode,
            sliver: SliverPadding(
              padding: isSelectionMode ? const .only(bottom: 80) : .zero,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return switch (index.isOdd) {
                    true => const Divider(height: 1, thickness: 1),
                    false => _CupertinoPostListItem(
                      post: posts[index ~/ 2],
                      onTap: () => _onTap(context, posts[index ~/ 2]),
                      isSelectionMode: isSelectionMode,
                      isSelected: notifier.selectedIds.contains(
                        posts[index ~/ 2].id,
                      ),
                    ),
                  };
                }, childCount: (posts.length * 2) - 1),
              ),
            ),
          ),
        ],
      );
    }

    // Material Layout
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: PostList(
        posts: posts,
        onTap: (post) => _onTap(context, post),
        onLongPress: (post) => _onLongPress(context, post),
      ),
    );
  }
}

// Separate widget for Cupertino to keep main file clean and handle specific list item building
/// A Cupertino-style list item for a post.
class _CupertinoPostListItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;

  const _CupertinoPostListItem({
    required this.post,
    required this.onTap,
    required this.isSelectionMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final content = CupertinoListTile(
      key: ValueKey(post.id),
      title: Text(
        post.title,
        style: .new(fontWeight: post.isRead == false ? .bold : .normal),
      ),
      onTap: onTap,
      leading: isSelectionMode
          ? Padding(
              padding: const .only(right: 8.0),
              child: Icon(
                isSelected
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: isSelected
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey,
              ),
            )
          : null,
    );

    if (!isSelectionMode) {
      return Dismissible(
        key: ValueKey(post.id),
        direction: .endToStart,
        background: Container(
          color: CupertinoColors.destructiveRed,
          alignment: .centerRight,
          padding: const .only(right: 16.0),
          child: const Icon(CupertinoIcons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showAdaptiveDialog<bool>(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Delete Post'),
              content: const Text('Are you sure you want to delete this post?'),
              actions: [
                AdaptiveDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                AdaptiveDialogAction(
                  isDestructive: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          context.read<PostNotifier>().deletePost(post.id);
        },
        child: content,
      );
    }

    return content;
  }
}
