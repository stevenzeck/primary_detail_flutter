import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primarydetailflutter/model/post.dart';
import 'package:primarydetailflutter/screen/detail_screen.dart';
import 'package:primarydetailflutter/screen/list_screen.dart';
import 'package:primarydetailflutter/services/db_service.dart';

import 'RoutePath.dart';

class PostRouterDelegate extends RouterDelegate<PostRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PostRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  Post _selectedPost;
  bool show404 = false;
  List<Post> posts;

  PostRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  PostRoutePath get currentConfiguration {
    if (show404) {
      return PostRoutePath.unknown();
    }
    return _selectedPost == null
        ? PostRoutePath.home()
        : PostRoutePath.details(posts.indexOf(_selectedPost));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        platformPage(
          key: ValueKey('PostsListPage'),
          child: FutureBuilder(
              future: DatabaseService.db.posts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  posts = snapshot.data;
                  return PostsListScreen(
                      posts: posts,
                      selectedPost: _selectedPost,
                      onTapped: _handlePostTapped);
                } else if (snapshot.hasError) {
                  var error = snapshot.error.toString();
                  return Center(child: Text(error));
                } else {
                  return Center(child: Text("Sorry"));
                }
              }),
          context: context,
        ),
        if (show404)
          platformPage(
              key: ValueKey('UnknownPage'), child: Text(''), context: context)
        else if (_selectedPost != null)
          platformPage(
              key: ValueKey('PostDetailPage'),
              child: DetailPage(
                item: _selectedPost,
              ),
              context: context)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedPost to null
        _selectedPost = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PostRoutePath path) async {
    if (path.isUnknown) {
      _selectedPost = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id < 0 || path.id > posts.length - 1) {
        show404 = true;
        return;
      }

      _selectedPost = posts[path.id];
    } else {
      _selectedPost = null;
    }

    show404 = false;
  }

  void _handlePostTapped(Post post) {
    _selectedPost = post;
    post.isread = 1;
    DatabaseService.db.updatePost(post);
    notifyListeners();
  }
}
