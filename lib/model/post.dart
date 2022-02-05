import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:primarydetailflutter/services/http_service.dart';
import 'package:sqflite/sqflite.dart';

final String tablePosts = 'posts';
final String columnId = '_id';
final String columnUserId = 'userid';
final String columnTitle = 'title';
final String columnBody = 'body';
final String columnIsRead = 'isread';

class Post {
  int id;
  int userId;
  String title;
  String body;
  bool isread;

  Post(
      {@required this.id,
      @required this.userId,
      @required this.title,
      @required this.body,
      @required this.isread});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnUserId: userId,
      columnTitle: title,
      columnBody: body,
      columnIsRead: isread == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Post.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userId = map[columnUserId];
    title = map[columnTitle];
    body = map[columnBody];
    isread = map[columnIsRead] == 1;
  }
}

class PostDatabase {
  final HttpService httpService = HttpService();
  static Database _database;

  PostDatabase._();

  static final PostDatabase db = PostDatabase._();

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
        return db.execute('''
create table $tablePosts( 
  $columnId INTEGER PRIMARY KEY,
  $columnUserId INTEGER, 
  $columnTitle TEXT,
  $columnBody TEXT,
  $columnIsRead INTEGER)
''');
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
      tablePosts,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> posts() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Posts.
    List<Map<String, dynamic>> maps = await db.query(tablePosts);

    if (maps.length == 0) {
      List<Post> posts = await httpService.getPosts();
      Batch batch = db.batch();
      posts.forEach((post) {
        batch.insert(tablePosts, post.toMap());
      });
      batch.commit();
      maps = await db.query(tablePosts);
    }

    // Convert the List<Map<String, dynamic> into a List<Post>.
    return List.generate(maps.length, (i) {
      return Post.fromMap(maps[i]);
    });
  }

  Future<void> updatePost(Post post) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Post.
    await db.update(
      tablePosts,
      post.toMap(),
      // Ensure that the Post has a matching id.
      where: "$columnId = ?",
      // Pass the Post's id as a whereArg to prevent SQL injection.
      whereArgs: [post.id],
    );
  }

  Future<void> deletePost(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Post from the database.
    await db.delete(
      tablePosts,
      // Use a `where` clause to delete a specific post.
      where: "$columnId = ?",
      // Pass the Post's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
