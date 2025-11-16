import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:primary_detail_flutter/model/post_repository.dart';
import 'package:primary_detail_flutter/services/database_service.dart';
import 'package:primary_detail_flutter/services/http_service.dart';
import 'package:primary_detail_flutter/widgets/adaptive_layout.dart';

import 'routing.dart';

void main() {
  runApp(const PostsApp());
}

class RepositoryProvider extends InheritedWidget {
  final PostRepository repository;

  const RepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  static PostRepository of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<RepositoryProvider>();
    if (provider == null) {
      throw Exception('RepositoryProvider not found in context');
    }
    return provider.repository;
  }

  @override
  bool updateShouldNotify(RepositoryProvider oldWidget) =>
      repository != oldWidget.repository;
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

  late final HttpService _httpService;
  late final PostDatabase _database;
  late final PostRepository _postRepository;

  ThemeMode? themeMode = ThemeMode.system;

  @override
  void initState() {
    _httpService = HttpService();
    _database = PostDatabase.db;
    _postRepository = PostRepository(_httpService, _database);

    _routeParser = PostRouteInformationParser(
      allowedPaths: ['/posts', '/post/:postId'],
      initialRoute: '/posts',
    );
    _routeState = RouteState(_routeParser);
    _routerDelegate = PostRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => AdaptiveLayout(navigatorKey: _navigatorKey),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final materialLightTheme = ThemeData.light(useMaterial3: true);
    final materialDarkTheme = ThemeData.dark(useMaterial3: true);
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

    return RepositoryProvider(
      repository: _postRepository,
      child: RouteStateScope(
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
      ),
    );
  }
}
