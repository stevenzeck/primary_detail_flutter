import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/screens/navigator.dart';

import 'routing.dart';

// Runs the app
void main() {
  runApp(const PostsApp());
}

class PostsApp extends StatefulWidget {
  const PostsApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostsAppState();
}

class _PostsAppState extends State<PostsApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final PostRouterDelegate _routerDelegate;
  late final PostRouteInformationParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = PostRouteInformationParser(
      allowedPaths: [
        '/posts',
        '/post/:postId',
      ],
      initialRoute: '/posts',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = PostRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => PostNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: Theme(
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
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              title: 'Posts App',
              routeInformationParser: _routeParser,
              routerDelegate: _routerDelegate,
            ),
          ),
        ),
      );
}
