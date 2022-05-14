import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../routing/route_state.dart';
import '../widgets/post_list.dart';

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({super.key});

  @override
  State<StatefulWidget> createState() => PostsListState();
}

class PostsListState extends State<PostsListScreen> {
  Future<List<Post>>? futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = PostDatabase.db.posts();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Posts"),
          automaticallyImplyLeading: true,
        ),
        body: FutureBuilder(
            future: futurePosts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Post> posts = snapshot.data as List<Post>;
                _handlePostsLoaded(posts);
                return PostList(
                  posts: posts,
                  onTap: _handlePostTapped,
                );
              } else if (snapshot.hasError) {
                var error = snapshot.error.toString();
                return Center(child: Text(error));
              } else {
                return const Center(child: Text("Sorry"));
              }
            }));
  }

  RouteState get _routeState => RouteStateScope.of(context);

  void _handlePostTapped(Post post) {
    post.isread = true;
    PostDatabase.db.updatePost(post);
    _routeState.notifyListeners();
    _routeState.go('/post/${post.id}');
  }

  //FIXME this is bad
  void _handlePostsLoaded(List<Post> posts) {
    _routeState.posts = posts;
  }
}
