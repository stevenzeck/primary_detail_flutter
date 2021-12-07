import 'dart:async';

import 'package:primarydetailflutter/model/post.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'http_service.dart';

class DatabaseService {
  final HttpService httpService = HttpService();
  static Database _database;

  DatabaseService._();

  static final DatabaseService db = DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await getDatabase();
    return _database;
  }

  getDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'posts_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE posts(id INTEGER PRIMARY KEY, userid INTEGER, title TEXT, body TEXT, isread INTEGER)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertPost(Post post) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Post into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same post is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> posts() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Posts.
    List<Map<String, dynamic>> maps = await db.query('posts');

    if (maps.length == 0) {
      List<Post> posts = await httpService.getPosts();
      Batch batch = db.batch();
      posts.forEach((post) {
        batch.insert('posts', post.toMap());
      });
      batch.commit();
      maps = await db.query('posts');
    }

    // Convert the List<Map<String, dynamic> into a List<Post>.
    return List.generate(maps.length, (i) {
      return Post(
        id: maps[i]['id'],
        userId: maps[i]['userid'],
        title: maps[i]['title'],
        body: maps[i]['body'],
        isread: maps[i]['isread'],
      );
    });
  }

  Future<void> updatePost(Post post) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Post.
    await db.update(
      'posts',
      post.toMap(),
      // Ensure that the Post has a matching id.
      where: "id = ?",
      // Pass the Post's id as a whereArg to prevent SQL injection.
      whereArgs: [post.id],
    );
  }

  Future<void> deletePost(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Post from the database.
    await db.delete(
      'posts',
      // Use a `where` clause to delete a specific post.
      where: "id = ?",
      // Pass the Post's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
