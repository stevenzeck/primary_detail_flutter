import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/main.dart';

import '../model/post.dart';
import '../routing/route_state.dart';
import '../screens.dart';

class PostNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PostNavigator({required this.navigatorKey, super.key});

  @override
  State<PostNavigator> createState() => _PostNavigatorState();
}

class _PostNavigatorState extends State<PostNavigator> {
  final _postDetailsKey = const ValueKey('Post details screens');

  Future<Post?>? _postFuture;
  int? _currentPostId;

  void _handlePageRemoved(Page<dynamic> page) {
    if (page.key == _postDetailsKey) {
      RouteStateScope.of(context).go('/posts');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;
    final postIdParam = routeState.route.parameters['postId'];
    int? selectedPostId;

    if (pathTemplate == '/post/:postId' && postIdParam != null) {
      selectedPostId = int.tryParse(postIdParam);
    }

    if (selectedPostId != _currentPostId) {
      setState(() {
        _currentPostId = selectedPostId;
        if (selectedPostId != null) {
          _postFuture = RepositoryProvider.of(context).getPost(selectedPostId);
        } else {
          _postFuture = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onDidRemovePage: _handlePageRemoved,
      pages: [
        platformPage(
          key: const ValueKey('PostsListPage'),
          child: const PostsListScreen(),
          context: context,
        ),
        if (_postFuture != null)
          platformPage(
            key: _postDetailsKey,
            child: FutureBuilder<Post?>(
              future: _postFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: PlatformCircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading post: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return DetailPage(item: snapshot.data!);
                } else {
                  return const Center(child: Text('Post not found.'));
                }
              },
            ),
            context: context,
          ),
      ],
    );
  }
}
