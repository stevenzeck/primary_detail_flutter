import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primarydetailflutter/routing/PostRouteInformationParser.dart';
import 'package:primarydetailflutter/routing/PostRouterDelegate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PostsAppState();
}

class _PostsAppState extends State<MyApp> {
  PostRouterDelegate _routerDelegate = PostRouterDelegate();
  PostRouteInformationParser _routeInformationParser =
      PostRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
        ),
        child: PlatformProvider(
          builder: (context) => PlatformApp.router(
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            title: 'Posts App',
            routeInformationParser: _routeInformationParser,
            routerDelegate: _routerDelegate,
          ),
        ));
  }
}
