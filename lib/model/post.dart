class Post {
  late final int id;
  late final int userId;
  late final String title;
  late final String body;
  late bool isread;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isread,
  });

  /// Converts this Post object into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'isread': isread ? 1 : 0,
    };
  }

  /// Creates a Post object from a JSON map.
  /// Assumes 'isread' is false by default.
  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    title = json['title'];
    body = json['body'];
    isread = false;
  }

  /// Creates a Post object from a database map.
  Post.fromDbMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['userId'];
    title = map['title'];
    body = map['body'];
    isread = map['isread'] == 1;
  }
}
