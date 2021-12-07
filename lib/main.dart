import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primarydetailflutter/screen/detail_page.dart';

import 'model/post.dart';
import 'screen/list_screen.dart';
import 'services/db_service.dart';
import 'services/http_service.dart';

void main() {
  runApp(MyApp());
}

final HttpService httpService = HttpService();
Future<List<Post>> futurePosts;

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PostsAppState();
}

class _PostsAppState extends State<MyApp> {
  PostRouterDelegate _routerDelegate = PostRouterDelegate();
  PostRouteInformationParser _routeInformationParser =
      PostRouteInformationParser();

  @override
  void initState() {
    super.initState();
    futurePosts = DatabaseService.db.posts();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformApp.router(
      title: 'Posts App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class PostRouteInformationParser extends RouteInformationParser<PostRoutePath> {
  @override
  Future<PostRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return PostRoutePath.home();
    }

    // Handle '/post/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'post') return PostRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return PostRoutePath.unknown();
      return PostRoutePath.details(id);
    }

    // Handle unknown routes
    return PostRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(PostRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/post/${path.id}');
    }
    return null;
  }
}

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
              future: futurePosts,
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

class PostRoutePath {
  final int id;
  final bool isUnknown;

  PostRoutePath.home()
      : id = null,
        isUnknown = false;

  PostRoutePath.details(this.id) : isUnknown = false;

  PostRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}
