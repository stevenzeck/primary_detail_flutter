import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../widgets/post_list.dart';
import 'detail.dart';

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
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Post> posts = snapshot.data!;
            return PostList(
              posts: posts,
              onTap: _handlePostTapped,
            );
          } else if (snapshot.hasError) {
            var error = snapshot.error.toString();
            return Center(child: Text(error));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _handlePostTapped(Post post) {
    setState(() {
      post.isread = true;
    });
    PostDatabase.db.updatePost(post);
    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) => DetailPage(item: post),
      ),
    );
  }
}
