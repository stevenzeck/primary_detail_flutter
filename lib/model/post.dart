import 'package:json_annotation/json_annotation.dart';

import '../services/database_service.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  @JsonKey(fromJson: _isReadFromDb, toJson: _isReadToDb)
  bool isread;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isread = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toMap() => _$PostToJson(this);

  static bool _isReadFromDb(int value) => value == 1;

  static int _isReadToDb(bool value) => value ? 1 : 0;

  Post.fromDbMap(Map<String, dynamic> map)
    : id = map[columnId],
      userId = map[columnUserId],
      title = map[columnTitle],
      body = map[columnBody],
      isread = map[columnIsRead] == 1;
}
