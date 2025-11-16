import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/post.dart';

const String tablePosts = 'posts';
const String columnId = 'id';
const String columnUserId = 'userId';
const String columnTitle = 'title';
const String columnBody = 'body';
const String columnIsRead = 'isread';

class PostDatabase {
  Database? _database;

  PostDatabase._();

  static final PostDatabase db = PostDatabase._();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'posts_database.db'),
      onCreate: (db, version) {
        return db.execute('''
      CREATE TABLE $tablePosts(
        $columnId INTEGER PRIMARY KEY,
        $columnUserId INTEGER,
        $columnTitle TEXT,
        $columnBody TEXT,
        $columnIsRead INTEGER)
      ''');
      },
      version: 1,
    );
  }

  /// Inserts a list of posts into the database.
  Future<void> insertPosts(List<Post> posts) async {
    final Database db = await database;
    Batch batch = db.batch();
    for (var post in posts) {
      batch.insert(
        tablePosts,
        post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves all posts from the database.
  Future<List<Post>> getPosts() async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tablePosts);

    return List.generate(maps.length, (i) => Post.fromDbMap(maps[i]));
  }

  /// Retrieves a single post by its ID.
  /// Returns null if no post is found.
  Future<Post?> getPost(int postId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tablePosts,
      where: '$columnId = ?',
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
      tablePosts,
      post.toMap(),
      where: "$columnId = ?",
      whereArgs: [post.id],
    );
  }

  /// Deletes a single post by ID.
  Future<void> deletePost(int id) async {
    final db = await database;
    await db.delete(tablePosts, where: "$columnId = ?", whereArgs: [id]);
  }

  /// Deletes all posts from the table.
  Future<void> deleteAllPosts() async {
    final db = await database;
    await db.delete(tablePosts);
  }
}
