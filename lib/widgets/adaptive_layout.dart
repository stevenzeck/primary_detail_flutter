import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/model/post.dart';
import 'package:primary_detail_flutter/routing.dart';
import 'package:primary_detail_flutter/screens.dart';

const double kMinWidthForLargeScreen = 600.0;

class AdaptiveLayout extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AdaptiveLayout({required this.navigatorKey, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;
    final postIdParam = routeState.route.parameters['postId'];
    int? selectedPostId;

    if (pathTemplate == '/post/:postId' && postIdParam != null) {
      selectedPostId = int.tryParse(postIdParam);
    }

    bool isLargeScreen = screenWidth >= kMinWidthForLargeScreen;

    if (isLargeScreen) {
      return Row(
        children: [
          const Expanded(
            flex: 1,
            child: PostsListScreen(),
          ),
          Expanded(
            flex: 2,
            child: selectedPostId != null
                ? FutureBuilder<Post>(
              future: PostDatabase.db.getPost(selectedPostId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: PlatformCircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return DetailPage(item: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading post: ${snapshot.error}'));
                } else {
                  return const Center(child: Text('Post not found.'));
                }
              },
            )
                : const Center(
              child: Text('Select a post to see details'),
            ),
          ),
        ],
      );
    } else {
      return PostNavigator(navigatorKey: navigatorKey);
    }
  }
}
