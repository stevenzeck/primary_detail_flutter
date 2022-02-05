import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../services/utils.dart';

class PostsListScreen extends StatefulWidget {
  final onTapped;
  final selectedPost;
  final onPostsLoaded;

  PostsListScreen(
      {@required this.onTapped,
      @required this.selectedPost,
      @required this.onPostsLoaded});

  @override
  State<StatefulWidget> createState() =>
      PostsListState(onTapped, selectedPost, onPostsLoaded);
}

class PostsListState extends State<PostsListScreen> {
  Future<List<Post>> futurePosts;
  final onTapped;
  final selectedPost;
  final onPostsLoaded;

  PostsListState(this.onTapped, this.selectedPost, this.onPostsLoaded);

  @override
  void initState() {
    super.initState();
    futurePosts = PostDatabase.db.posts();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Posts"),
          automaticallyImplyLeading: true,
        ),
        body: FutureBuilder(
            future: futurePosts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Post> posts = snapshot.data;
                onPostsLoaded(posts);
                return ListView.separated(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      Post post = posts[index];
                      return Material(
                          child: GestureDetector(
                              child: ListTile(
                        selected: isTablet(context)
                            ? posts[index] == selectedPost
                            : false,
                        title: Text(post.title,
                            style: TextStyle(
                                fontWeight: post.isread == false
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        onTap: () => onTapped(post),
                      )));
                    },
                    separatorBuilder: (context, index) {
                      return Divider(height: 1, thickness: 1);
                    });
              } else if (snapshot.hasError) {
                var error = snapshot.error.toString();
                return Center(child: Text(error));
              } else {
                return Center(child: Text("Sorry"));
              }
            }));
  }
}
