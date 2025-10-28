import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/screens/navigator.dart';

import 'routing.dart';

void main() {
  runApp(const PostsApp());
}

class PostsApp extends StatefulWidget {
  const PostsApp({super.key});

  @override
  State<StatefulWidget> createState() => _PostsAppState();
}

class _PostsAppState extends State<PostsApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final PostRouterDelegate _routerDelegate;
  late final PostRouteInformationParser _routeParser;

  ThemeMode? themeMode = ThemeMode.system;

  @override
  void initState() {
    _routeParser = PostRouteInformationParser(
      allowedPaths: ['/posts', '/post/:postId'],
      initialRoute: '/posts',
    );
    _routeState = RouteState(_routeParser);
    _routerDelegate = PostRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => PostNavigator(navigatorKey: _navigatorKey),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final materialLightTheme = ThemeData.light();
    final materialDarkTheme = ThemeData.dark();
    const darkDefaultCupertinoTheme = CupertinoThemeData(
      brightness: Brightness.dark,
    );
    final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialDarkTheme.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
          textTheme: CupertinoTextThemeData(
            primaryColor: Colors.white,
            navActionTextStyle: darkDefaultCupertinoTheme
                .textTheme
                .navActionTextStyle
                .copyWith(color: const Color(0xF0F9F9F9)),
            navLargeTitleTextStyle: darkDefaultCupertinoTheme
                .textTheme
                .navLargeTitleTextStyle
                .copyWith(color: const Color(0xF0F9F9F9)),
          ),
        ),
      ),
    );
    final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialLightTheme,
    );

    return RouteStateScope(
      notifier: _routeState,
      child: PlatformProvider(
        builder: (context) => PlatformTheme(
          themeMode: themeMode,
          materialLightTheme: materialLightTheme,
          materialDarkTheme: materialDarkTheme,
          cupertinoLightTheme: cupertinoLightTheme,
          cupertinoDarkTheme: cupertinoDarkTheme,
          matchCupertinoSystemChromeBrightness: true,
          onThemeModeChanged: (newThemeMode) {
            setState(() {
              themeMode = newThemeMode;
            });
          },
          builder: (context) => PlatformApp.router(
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            title: 'Posts App',
            material: (_, _) => MaterialAppRouterData(
              routeInformationParser: _routeParser,
              routerDelegate: _routerDelegate,
              theme: materialLightTheme,
              darkTheme: materialDarkTheme,
              themeMode: themeMode,
            ),
            cupertino: (_, _) => CupertinoAppRouterData(
              routeInformationParser: _routeParser,
              routerDelegate: _routerDelegate,
              theme: themeMode == ThemeMode.dark
                  ? cupertinoDarkTheme
                  : cupertinoLightTheme,
            ),
          ),
        ),
      ),
    );
  }
}
