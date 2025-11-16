import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/main.dart';
import 'package:primary_detail_flutter/model/post.dart';
import 'package:primary_detail_flutter/routing.dart';
import 'package:primary_detail_flutter/screens.dart';

const double kMinWidthForLargeScreen = 600.0;

class AdaptiveLayout extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AdaptiveLayout({required this.navigatorKey, super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  Future<Post?>? _postFuture;
  int? _currentPostId;

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
    final screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth >= kMinWidthForLargeScreen;

    if (isLargeScreen) {
      return Row(
        children: [
          const Expanded(flex: 1, child: PostsListScreen()),
          Expanded(
            flex: 2,
            child: _postFuture != null
                ? FutureBuilder<Post?>(
                    future: _postFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: PlatformCircularProgressIndicator(),
                        );
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
                  )
                : const Center(child: Text('Select a post to see details')),
          ),
        ],
      );
    } else {
      return PostNavigator(navigatorKey: widget.navigatorKey);
    }
  }
}
