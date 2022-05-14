import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key, required this.item}) : super(key: key);

  final Post item;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Post Detail"),
        automaticallyImplyLeading: true,
        cupertino: (_, __) =>
            CupertinoNavigationBarData(previousPageTitle: "Posts"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(
            10.0, Platform.isIOS ? 100.0 : 20.0, 10.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("ID: ${item.id}")),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("User ID: ${item.userId}")),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("Title: ${item.title}")),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(item.body)),
          ],
        ),
      ),
    );
  }
}
