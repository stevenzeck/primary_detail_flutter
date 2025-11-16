import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/model/post_notifier.dart';
import 'package:primary_detail_flutter/screens.dart';
import 'package:provider/provider.dart';

const double kMinWidthForLargeScreen = 600.0;

class AdaptiveLayout extends StatefulWidget {
  final int? selectedPostId;

  const AdaptiveLayout({this.selectedPostId, super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  @override
  void initState() {
    super.initState();
    _updateNotifier(widget.selectedPostId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.selectedPostId != null) {
      _updateNotifier(widget.selectedPostId);
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPostId != widget.selectedPostId) {
      _updateNotifier(widget.selectedPostId);
    }
  }

  void _updateNotifier(int? postId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostNotifier>().selectPost(postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth >= kMinWidthForLargeScreen;

    final selectedPost = context.watch<PostNotifier>().selectedPost;

    Widget detailView;
    if (selectedPost != null) {
      detailView = DetailPage(item: selectedPost);
    } else if (widget.selectedPostId != null) {
      detailView = const Center(child: PlatformCircularProgressIndicator());
    } else {
      detailView = const Center(child: Text('Select a post to see details'));
    }

    if (isLargeScreen) {
      return Row(
        children: [
          const Expanded(flex: 1, child: PostsListScreen()),
          Expanded(flex: 2, child: detailView),
        ],
      );
    } else {
      if (widget.selectedPostId == null) {
        return const PostsListScreen();
      } else {
        return detailView;
      }
    }
  }
}
