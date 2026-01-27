import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../features/posts/logic/post_notifier.dart';
import '../../features/posts/ui/screens/post_detail_screen.dart';
import '../../features/posts/ui/screens/post_list_screen.dart';

/// A widget that handles adaptive layout for different screen sizes (split-view on large screens).
class AdaptiveLayout extends StatefulWidget {
  /// The ID of the currently selected post, if any.
  final int? selectedPostId;

  /// Creates an [AdaptiveLayout].
  const AdaptiveLayout({this.selectedPostId, super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> with RestorationMixin {
  /// Restorable property for the selected post ID to persist state across terminations.
  final RestorableIntN _restorableSelectedPostId = RestorableIntN(null);

  /// Flag to track if this is the first time dependencies are changed.
  bool _isFirstLoad = true;

  @override
  String? get restorationId => 'adaptive_layout';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableSelectedPostId, 'selected_post_id');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Handle initial selection logic only once.
    if (_isFirstLoad) {
      _isFirstLoad = false;

      // Determine which ID to select: either from the widget argument or restored state.
      final int? idToSelect =
          widget.selectedPostId ?? _restorableSelectedPostId.value;

      _updateNotifier(idToSelect);

      // If provided via widget, update the restorable state.
      if (widget.selectedPostId != null) {
        _restorableSelectedPostId.value = widget.selectedPostId;
      }
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state if the selected post ID changes from the parent.
    if (oldWidget.selectedPostId != widget.selectedPostId) {
      _restorableSelectedPostId.value = widget.selectedPostId;
      _updateNotifier(widget.selectedPostId);
    }
  }

  /// Updates the [PostNotifier] with the selected post ID.
  void _updateNotifier(int? postId) {
    final notifier = context.read<PostNotifier>();
    // Only update if the selection is different to avoid loops.
    if (notifier.selectedPost?.id != postId) {
      // Schedule the update for after the current build frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifier.selectPost(postId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if the screen is large enough for a split view.
        final bool isLargeScreen =
            constraints.maxWidth >= AppConstants.kMinWidthForLargeScreen;

        final selectedPost = context.watch<PostNotifier>().selectedPost;

        Widget detailView;
        if (selectedPost != null) {
          // Show the detail page for the selected post.
          detailView = DetailPage(
            item: selectedPost,
            showBackButton: !isLargeScreen,
          );
        } else if (widget.selectedPostId != null) {
          // Show a loader if an ID is selected but the post isn't loaded yet.
          detailView = const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          // Show a placeholder if no post is selected.
          detailView = const Center(
            child: Text('Select a post to see details'),
          );
        }

        if (isLargeScreen) {
          // Split-view layout: List on the left, Detail on the right.
          return Row(
            children: [
              const Expanded(
                flex: 1,
                child: PostsListScreen(showBackButton: false),
              ),
              Expanded(flex: 2, child: detailView),
            ],
          );
        } else {
          // Single-view layout: Either List or Detail.
          if (widget.selectedPostId == null) {
            return const PostsListScreen();
          } else {
            return detailView;
          }
        }
      },
    );
  }
}
