import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';

// The detail screen does not change, so it is stateless
class DetailPage extends StatelessWidget {
  /// Pass the post into the DetailPage constructor from the [PostNavigator]
  const DetailPage({Key? key, required this.item}) : super(key: key);

  final Post item;

  // Build the detail page widget
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Post Detail"),
        automaticallyImplyLeading: true,
        cupertino: (_, __) => CupertinoNavigationBarData(
          previousPageTitle: "Posts",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText("ID: ${item.id}"),
            _buildText("User ID: ${item.userId}"),
            _buildText("Title: ${item.title}"),
            Text(item.body),
          ],
        ),
      ),
    );
  }

  /// Builds a text widget with the given text.
  Widget _buildText(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(text),
    );
  }
}
