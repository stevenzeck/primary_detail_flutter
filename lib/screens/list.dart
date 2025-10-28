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
  Future<List<Post>>? _futurePosts;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() {
    setState(() {
      _futurePosts = PostDatabase.db.posts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Posts"),
        trailingActions: <Widget>[
          PlatformIconButton(
            icon: Icon(PlatformIcons(context).refresh),
            onPressed: _fetchPosts,
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: PlatformCircularProgressIndicator());
          } else if (snapshot.hasData) {
            List<Post> posts = snapshot.data!;
            return PostList(posts: posts, onTap: _handlePostTapped);
          } else if (snapshot.hasError) {
            var error = snapshot.error.toString();
            if (error.startsWith("Exception: ")) {
              error = error.substring("Exception: ".length);
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PlatformIcons(context).error,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Failed to load posts:",
                      style: platformThemeData(
                        context,
                        material: (data) => data.textTheme.titleMedium,
                        cupertino: (data) => data.textTheme.navTitleTextStyle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    PlatformTextButton(
                      onPressed: _fetchPosts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No posts available."));
          }
        },
      ),
    );
  }

  RouteState get _routeState => RouteStateScope.of(context);

  void _handlePostTapped(Post post) {
    setState(() {
      post.isread = true;
    });
    PostDatabase.db.updatePost(post);
    _routeState.go('/post/${post.id}');
  }
}
