import 'package:path/path.dart';
import 'package:primary_detail_flutter/services/http_service.dart';
import 'package:sqflite/sqflite.dart';

const String tablePosts = 'posts';
const String columnId = 'id';
const String columnUserId = 'userId';
const String columnTitle = 'title';
const String columnBody = 'body';
const String columnIsRead = 'isread';

class Post {
  late final int id;
  late final int userId;
  late final String title;
  late final String body;
  late bool isread;

  Post(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body,
      required this.isread});

  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnUserId: userId,
      columnTitle: title,
      columnBody: body,
      columnIsRead: isread ? 1 : 0
    };
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
  Database? _database;

  PostDatabase._();

  static final PostDatabase db = PostDatabase._();

  Future get database async => _database ?? await _initDatabase();

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

  Future<void> insertPost(Post post) async {
    final Database db = await database;
    await db.insert(
      tablePosts,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> posts() async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tablePosts);

    if (maps.isEmpty) {
      List<Post> posts = await httpService.getPosts();
      Batch batch = db.batch();
      for (var post in posts) {
        batch.insert(tablePosts, post.toMap());
      }
      batch.commit();
      maps = await db.query(tablePosts);
    }

    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  Future<Post> getPost(int postId) async {
    final db = await database;
    List<Map<String, dynamic>> maps =
        await db.query(tablePosts, where: '$columnId = ?', whereArgs: [postId]);
    return Post.fromMap(maps[0]);
  }

  Future<void> updatePost(Post post) async {
    final db = await database;
    await db.update(
      tablePosts,
      post.toMap(),
      where: "$columnId = ?",
      whereArgs: [post.id],
    );
  }

  Future<void> deletePost(int id) async {
    final db = await database;
    await db.delete(
      tablePosts,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }
}
