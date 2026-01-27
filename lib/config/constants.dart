/// Holds application-wide constant values.
class AppConstants {
  /// The base URL for the JSONPlaceholder API.
  static const String apiBaseUrl = 'jsonplaceholder.typicode.com';

  /// The path for fetching posts.
  static const String apiPostsPath = '/posts';

  /// The timeout duration for API requests.
  static const Duration apiTimeout = Duration(seconds: 10);

  /// The minimum width for a screen to be considered "large" (e.g., tablet or desktop).
  static const double kMinWidthForLargeScreen = 600.0;
}
