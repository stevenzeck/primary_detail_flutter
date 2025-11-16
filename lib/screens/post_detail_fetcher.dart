import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/model/post.dart';
import 'package:primary_detail_flutter/screens/detail.dart';

/// A widget that fetches a post by its ID and displays the DetailPage.
/// This is used by the adaptive layout to show the detail content.
class PostDetailFetcher extends StatelessWidget {
  final Future<Post?> postFuture;

  const PostDetailFetcher({required this.postFuture, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post?>(
      future: postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: PlatformCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading post: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          return DetailPage(item: snapshot.data!);
        } else {
          return const Center(child: Text('Post not found.'));
        }
      },
    );
  }
}
