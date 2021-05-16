class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  int isread;

  Post({this.id, this.userId, this.title, this.body, this.isread});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      isread: json['isread'] = 0,
    );
  }

  factory Post.fromMap(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      isread: json['isread'] = 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'title': title,
      'body': body,
      'isread': isread,
    };
  }
}
