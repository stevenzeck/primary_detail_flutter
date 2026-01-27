import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'config/themes.dart';
import 'core/di/dependencies.dart';

/// The entry point of the application.
void main() {
  runApp(const PostsApp());
}

/// The root widget of the application.
class PostsApp extends StatelessWidget {
  /// Creates the [PostsApp].
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Provide dependencies to the widget tree.
      providers: appProviders,
      child: RestorationScope(
        restorationId: 'app',
        child: MaterialApp.router(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'Posts App',
          routerConfig: router,
          theme: AppThemes.materialLightTheme,
          darkTheme: AppThemes.materialDarkTheme,
          themeMode: .system,
        ),
      ),
    );
  }
}
