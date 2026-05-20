import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/posts/data/post_repository.dart';
import '../../features/posts/logic/post_notifier.dart';
import '../services/database_service.dart';
import '../services/http_service.dart';

// Initialize the singleton instances for services and repositories.
final _httpService = HttpService(baseUrl: 'jsonplaceholder.typicode.com');
final _postDatabase = PostDatabase.db;
final _postRepository = PostRepository(
  httpService: _httpService,
  database: _postDatabase,
);

/// Returns the list of providers used in the application.
List<SingleChildWidget> get appProviders {
  return [
    // Provide the PostRepository for dependency injection.
    Provider<PostRepository>.value(value: _postRepository),
    // Provide the PostNotifier for state management.
    ChangeNotifierProvider<PostNotifier>(
      create: (_) => PostNotifier(repository: _postRepository),
    ),
    // Provie the Theme change notifier
    ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    // If needed
    // Provider<HttpService>.value(value: _httpService),
  ];
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = .system;

  ThemeMode get mode => _mode;

  void toggleTheme(bool isDark) {
    _mode = isDark ? .dark : .light;
    notifyListeners();
  }
}
