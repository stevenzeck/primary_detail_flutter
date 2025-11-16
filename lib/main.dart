import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:primary_detail_flutter/model/post_repository.dart';
import 'package:primary_detail_flutter/services/database_service.dart';
import 'package:primary_detail_flutter/services/http_service.dart';
import 'package:primary_detail_flutter/widgets/adaptive_layout.dart';

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
  late final GoRouter _router;
  late final HttpService _httpService;
  late final PostDatabase _database;
  late final PostRepository _postRepository;

  ThemeMode? themeMode = ThemeMode.system;

  @override
  void initState() {
    _httpService = HttpService();
    _database = PostDatabase.db;
    _postRepository = PostRepository(_httpService, _database);

    _router = GoRouter(
      initialLocation: '/posts',
      routes: [
        GoRoute(
          path: '/posts',
          name: 'posts',
          pageBuilder: (context, state) => platformPage(
            context: context,
            key: state.pageKey,
            child: const AdaptiveLayout(selectedPostId: null),
          ),
        ),
        GoRoute(
          path: '/post/:postId',
          name: 'post-detail',
          pageBuilder: (context, state) {
            final postId = int.tryParse(state.pathParameters['postId'] ?? '');
            return platformPage(
              context: context,
              key: state.pageKey,
              child: AdaptiveLayout(selectedPostId: postId),
            );
          },
        ),
      ],
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
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
              routeInformationProvider: _router.routeInformationProvider,
              theme: materialLightTheme,
              darkTheme: materialDarkTheme,
              themeMode: themeMode,
            ),
            cupertino: (_, _) => CupertinoAppRouterData(
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
              routeInformationProvider: _router.routeInformationProvider,
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
