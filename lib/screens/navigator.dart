import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../routing/route_state.dart';
import '../screens.dart';

class PostNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PostNavigator({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<PostNavigator> createState() => _PostNavigatorState();
}

class _PostNavigatorState extends State<PostNavigator> {
  final _postDetailsKey = const ValueKey('Post details screens');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Future<Post>? selectedPost;
    if (pathTemplate == '/post/:postId') {
      int postId = int.parse(routeState.route.parameters['postId']!);
      selectedPost = PostDatabase.db.getPost(postId);
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
            child: FutureBuilder<Post>(
              future: selectedPost,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DetailPage(
                    item: snapshot.data!,
                  );
                } else if (snapshot.hasError) {
                  var error = snapshot.error.toString();
                  return Center(child: Text(error));
                } else {
                  return const Center(child: Text("Loading post..."));
                }
              },
            ),
            context: context,
          ),
      ],
    );
  }
}
