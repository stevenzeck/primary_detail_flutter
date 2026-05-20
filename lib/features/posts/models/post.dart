import 'package:json_annotation/json_annotation.dart';

import '../data/post_schema.dart';

part 'post.g.dart';

extension type const PostId(int value) implements int {}
extension type const UserId(int value) implements int {}

/// A model representing a post.
@JsonSerializable()
class Post {
  /// The unique identifier of the post.
  final PostId id;

  /// The ID of the user who created the post.
  final UserId userId;

  /// The title of the post.
  final String title;

  /// The body content of the post.
  final String body;

  /// Indicates whether the post has been read by the user.
  ///
  /// This field is converted from/to an integer for database storage.
  @JsonKey(fromJson: _isReadFromDb, toJson: _isReadToDb)
  final bool isRead;

  /// Creates a [Post] instance.
  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isRead = false,
  });

  /// Creates a copy of this [Post] with the given fields replaced with the new values.
  Post copyWith({
    PostId? id,
    UserId? userId,
    String? title,
    String? body,
    bool? isRead,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Creates a [Post] from a JSON map.
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  /// Converts this [Post] to a JSON map.
  Map<String, dynamic> toMap() => _$PostToJson(this);

  /// Helper to convert integer value from DB to boolean.
  static bool _isReadFromDb(int value) => value == 1;

  /// Helper to convert boolean value to integer for DB.
  static int _isReadToDb(bool value) => value ? 1 : 0;

  /// Creates a [Post] from a database map (where column names match schema).
  Post.fromDbMap(Map<String, dynamic> map)
    : id = PostId(map[PostSchema.id] as int),
      userId = UserId(map[PostSchema.userId] as int),
      title = map[PostSchema.title] as String,
      body = map[PostSchema.body] as String,
      isRead = map[PostSchema.isRead] == 1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.body == body &&
        other.isRead == isRead;
  }

  @override
  int get hashCode => Object.hash(id, userId, title, body, isRead);
}
