import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/adaptive_dialog_action.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../logic/post_notifier.dart';
import '../../models/post.dart';

/// The screen that displays the details of a single post.
// The detail screen does not change, so it is stateless
class DetailPage extends StatelessWidget {
  /// Whether to show the back button in the AppBar.
  final bool showBackButton;

  /// The post item to display.
  final Post item;

  /// Creates a [DetailPage] with the given post item.
  const DetailPage({super.key, required this.item, this.showBackButton = true});

  /// Shows a confirmation dialog and deletes the post if confirmed.
  Future<void> _deletePost(BuildContext context) async {
    final notifier = context.read<PostNotifier>();
    final router = GoRouter.of(context);
    final isLargeScreen = !showBackButton; // Heuristic: no back button usually means split view detail

    final shouldDelete = await showAdaptiveDialog<bool>(
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

    if (shouldDelete == true) {
      // Perform deletion
      await notifier.deletePost(item.id);

      if (!context.mounted) return;

      // If we are in a navigation stack (small screen), pop back.
      // If we are in split view, the notifier update will likely handle clearing the selection
      // or the parent widget logic will. But typically we should just ensure we don't try to pop if we are root.
      if (!isLargeScreen && router.canPop()) {
        router.pop();
      } else if (!isLargeScreen) {
        // Fallback if router logic differs
        Navigator.of(context).pop();
      }
      // For split view (large screen), the AdaptiveLayout listens to notifier changes.
      // When the post is deleted, it disappears from the list.
      // The Notifier logic I added: "_selectedPost = null;" if updatedSelected is null.
      // AdaptiveLayout will then show "Select a post".
    }
  }

  // Build the detail page widget
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('Post Detail'),
      automaticallyImplyLeading: showBackButton,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deletePost(context),
        ),
      ],
      body: SingleChildScrollView(
        padding: const .all(16.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: .bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text('ID: ${item.id}')),
                const SizedBox(width: 8),
                Chip(label: Text('User: ${item.userId}')),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const .all(16.0),
                child: Text(
                  item.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
