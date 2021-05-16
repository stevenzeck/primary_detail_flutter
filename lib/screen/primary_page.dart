import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primarydetailflutter/services/db_service.dart';

import '../model/post.dart';
import '../services/db_service.dart';
import '../services/http_service.dart';
import '../services/utils.dart';
import 'detail_page.dart';

class PrimaryPage extends StatefulWidget {
  PrimaryPage({Key key}) : super(key: key);

  @override
  _PrimaryPageState createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<PrimaryPage> {
  final HttpService httpService = HttpService();
  Future<List<Post>> futurePosts;
  Post selectedItem;

  @override
  void initState() {
    super.initState();
    futurePosts = DatabaseService.db.posts();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Posts List"),
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var posts = snapshot.data;
              return ListView.separated(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return getRow(posts, index);
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 1, thickness: 1);
                },
              );
            } else if (snapshot.hasError) {
              var error = snapshot.error.toString();
              return Center(child: Text(error));
            } else {
              return Center(child: Text("Sorry"));
            }
          }),
    );
  }

  Material getRow(List<Post> posts, int index) {
    return Material(
        child: GestureDetector(
            child: ListTile(
                // Don't select on smaller screens, as it goes to a
                // separate screen instead of the two-pane view
                selected:
                    isTablet(context) ? posts[index] == selectedItem : false,
                title: Text(posts[index].title,
                    style: TextStyle(
                        fontWeight: posts[index].isread == 0
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onTap: () {
                  setState(() {
                    selectedItem = posts[index];
                    posts[index].isread = 1;
                    DatabaseService.db.updatePost(posts[index]);
                    // To remove the previously selected detail page
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }

                    Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (context) {
                          return DetailPage(item: selectedItem);
                        }));
                  });
                })));
  }
}
