import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:primary_detail_flutter/model/post_notifier.dart';
import 'package:provider/provider.dart';

import '../widgets/post_list.dart';

class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PostNotifier>();

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Posts"),
        trailingActions: <Widget>[
          PlatformIconButton(
            icon: Icon(PlatformIcons(context).refresh),
            onPressed: () => context.read<PostNotifier>().refreshPosts(),
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: _buildBody(context, notifier),
    );
  }

  Widget _buildBody(BuildContext context, PostNotifier notifier) {
    if (notifier.isLoading) {
      return Center(child: PlatformCircularProgressIndicator());
    }

    if (notifier.error != null) {
      var error = notifier.error.toString();
      if (error.startsWith("Exception: ")) {
        error = error.substring("Exception: ".length);
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PlatformIcons(context).error, size: 50, color: Colors.red),
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
                onPressed: () => context.read<PostNotifier>().refreshPosts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (notifier.posts.isEmpty) {
      return const Center(child: Text("No posts available."));
    }

    return PostList(
      posts: notifier.posts,
      onTap: (post) {
        context.read<PostNotifier>().selectPost(post.id);
        context.push('/post/${post.id}');
      },
    );
  }
}
