/// Defines the database schema for the posts table.
class PostSchema {
  /// The name of the table.
  static const String tableName = 'posts';

  /// The primary key column name.
  static const String id = 'id';

  /// The user ID column name.
  static const String userId = 'userId';

  /// The title column name.
  static const String title = 'title';

  /// The body column name.
  static const String body = 'body';

  /// The column name indicating if the post is read (0 or 1).
  static const String isRead = 'isread';
}
