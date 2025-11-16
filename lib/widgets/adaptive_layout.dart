import 'package:flutter/material.dart';
import 'package:primary_detail_flutter/main.dart';
import 'package:primary_detail_flutter/model/post.dart';
import 'package:primary_detail_flutter/screens.dart';
import 'package:primary_detail_flutter/screens/post_detail_fetcher.dart';

const double kMinWidthForLargeScreen = 600.0;

class AdaptiveLayout extends StatefulWidget {
  final int? selectedPostId;

  const AdaptiveLayout({this.selectedPostId, super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  Future<Post?>? _postFuture;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      _postFuture = _getPostFuture(widget.selectedPostId);
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPostId != widget.selectedPostId) {
      setState(() {
        _postFuture = _getPostFuture(widget.selectedPostId);
      });
    }
  }

  Future<Post?>? _getPostFuture(int? postId) {
    if (postId == null) {
      return null;
    }
    return RepositoryProvider.of(context).getPost(postId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth >= kMinWidthForLargeScreen;

    Widget detailView = _postFuture != null
        ? PostDetailFetcher(postFuture: _postFuture!)
        : const Center(child: Text('Select a post to see details'));

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
