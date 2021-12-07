import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/post.dart';
import '../services/utils.dart';

class DetailPage extends StatelessWidget {
  DetailPage({Key key, @required this.item}) : super(key: key);

  final Post item;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Post Detail"),
        automaticallyImplyLeading: true,
        cupertino: isTablet(context)
            ? null
            : (_, __) =>
                CupertinoNavigationBarData(previousPageTitle: "Post List"),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("ID: ${item.id}")),
            Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("User ID: ${item.userId}")),
            Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("Title: ${item.title}")),
            Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text("${item.body}")),
          ],
        ),
      ),
    );
  }
}
