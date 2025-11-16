import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:primary_detail_flutter/model/post_notifier.dart';
import 'package:primary_detail_flutter/model/post_repository.dart';
import 'package:primary_detail_flutter/services/database_service.dart';
import 'package:primary_detail_flutter/services/http_service.dart';
import 'package:primary_detail_flutter/themes.dart';
import 'package:primary_detail_flutter/widgets/adaptive_layout.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const PostsApp());
}

class PostsApp extends StatefulWidget {
  const PostsApp({super.key});

  @override
  State<StatefulWidget> createState() => _PostsAppState();
}

class _PostsAppState extends State<PostsApp> {
  late final GoRouter _router;

  ThemeMode? themeMode = ThemeMode.system;

  @override
  void initState() {
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
    return MultiProvider(
      providers: [
        Provider(create: (_) => HttpService()),
        Provider(create: (_) => PostDatabase.db),
        ProxyProvider2<HttpService, PostDatabase, PostRepository>(
          update: (_, http, db, previous) => PostRepository(http, db),
        ),
        ChangeNotifierProxyProvider<PostRepository, PostNotifier>(
          create: (context) => PostNotifier(context.read<PostRepository>()),
          update: (_, repo, previous) => PostNotifier(repo),
        ),
      ],
      child: PlatformProvider(
        builder: (context) => PlatformTheme(
          themeMode: themeMode,
          materialLightTheme: AppThemes.materialLightTheme,
          materialDarkTheme: AppThemes.materialDarkTheme,
          cupertinoLightTheme: AppThemes.cupertinoLightTheme,
          cupertinoDarkTheme: AppThemes.cupertinoDarkTheme,
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
              theme: AppThemes.materialLightTheme,
              darkTheme: AppThemes.materialDarkTheme,
              themeMode: themeMode,
            ),
            cupertino: (_, _) => CupertinoAppRouterData(
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
              routeInformationProvider: _router.routeInformationProvider,
              theme: themeMode == ThemeMode.dark
                  ? AppThemes.cupertinoDarkTheme
                  : AppThemes.cupertinoLightTheme,
            ),
          ),
        ),
      ),
    );
  }
}
