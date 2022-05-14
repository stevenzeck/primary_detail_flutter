import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../routing/route_state.dart';
import '../screens.dart';

class PostNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PostNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<PostNavigator> createState() => _PostNavigatorState();
}

class _PostNavigatorState extends State<PostNavigator> {
  final _postDetailsKey = const ValueKey('Post details screens');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Post? selectedPost;
    if (pathTemplate == '/post/:postId') {
      selectedPost = routeState.posts?.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['postId']);
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        if (route.settings is Page &&
            (route.settings as Page).key == _postDetailsKey) {
          routeState.go('/posts');
        }

        return route.didPop(result);
      },
      pages: [
        platformPage(
          key: const ValueKey('PostsListPage'),
          child: const PostsListScreen(),
          context: context,
        ),
        if (selectedPost != null)
          platformPage(
              key: const ValueKey('PostDetailPage'),
              child: DetailPage(
                item: selectedPost,
              ),
              context: context)
      ],
    );
  }
}
