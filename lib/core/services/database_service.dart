import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/posts/data/post_schema.dart';
import '../../features/posts/models/post.dart';

/// A singleton class to manage the local SQLite database for posts.
class PostDatabase {
  /// The singleton instance of the [PostDatabase].
  static final PostDatabase db = PostDatabase._();

  /// Private constructor for the singleton pattern.
  PostDatabase._();

  Database? _database;
  Future<Database>? _initDbFuture;
  DatabaseFactory? _factoryOverride;

  /// Returns the database instance, initializing it if necessary.
  Future<Database> get database async {
    // If the database is already initialized, return it.
    if (_database != null) return _database!;
    // If initialization is in progress, wait for it.
    _initDbFuture ??= _initDatabase();
    _database = await _initDbFuture;
    return _database!;
  }

  /// Sets the database instance manually for testing purposes.
  @visibleForTesting
  set databaseInstance(Database? db) {
    _database = db;
    // Reset the future so subsequent calls to 'database' can re-initialize if needed.
    _initDbFuture = null;
  }

  /// Sets the database factory manually for testing purposes.
  @visibleForTesting
  set databaseFactoryForTesting(DatabaseFactory? factory) {
    _factoryOverride = factory;
  }

  DatabaseFactory get _factory => _factoryOverride ?? databaseFactory;

  /// Initializes the database.
  Future<Database> _initDatabase() async {
    final factory = _factory;
    return factory.openDatabase(
      // Set the path to the database file.
      join(await factory.getDatabasesPath(), 'posts_database.db'),
      // When creating the database, create the table.
      options: OpenDatabaseOptions(onCreate: onCreate, version: 1),
    );
  }

  /// Creates the database table.
  @visibleForTesting
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${PostSchema.tableName}(
        ${PostSchema.id} INTEGER PRIMARY KEY,
        ${PostSchema.userId} INTEGER,
        ${PostSchema.title} TEXT,
        ${PostSchema.body} TEXT,
        ${PostSchema.isRead} INTEGER)
      ''');
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _initDbFuture = null;
  }

  /// Inserts a list of posts into the database.
  Future<void> insertPosts(List<Post> posts) async {
    final Database db = await database;
    await db.transaction((txn) async {
      final Batch batch = txn.batch();
      for (var post in posts) {
        batch.insert(
          PostSchema.tableName,
          post.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Retrieves all posts from the database.
  Future<List<Post>> getPosts() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      PostSchema.tableName,
    );

    return List.generate(maps.length, (i) => Post.fromDbMap(maps[i]));
  }

  /// Retrieves a single post by its ID.
  /// Returns null if no post is found.
  Future<Post?> getPost(int postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      PostSchema.tableName,
      where: '${PostSchema.id} = ?',
      whereArgs: [postId],
    );

    if (maps.isNotEmpty) {
      return Post.fromDbMap(maps[0]);
    }
    return null;
  }

  /// Updates an existing post.
  Future<void> updatePost(Post post) async {
    final db = await database;
    await db.update(
      PostSchema.tableName,
      post.toMap(),
      where: '${PostSchema.id} = ?',
      whereArgs: [post.id],
    );
  }

  /// Deletes a single post by ID.
  Future<void> deletePost(int id) async {
    final db = await database;
    await db.delete(
      PostSchema.tableName,
      where: '${PostSchema.id} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes multiple posts by their IDs.
  Future<void> deletePosts(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    await db.transaction((txn) async {
      final Batch batch = txn.batch();
      for (var id in ids) {
        batch.delete(
          PostSchema.tableName,
          where: '${PostSchema.id} = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Deletes all posts from the table.
  Future<void> deleteAllPosts() async {
    final db = await database;
    await db.delete(PostSchema.tableName);
  }
}
