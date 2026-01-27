import 'package:flutter_test/flutter_test.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';
import 'package:primary_detail_flutter/features/posts/data/post_schema.dart';

void main() {
  group('Post Model', () {
    const tPostId = PostId(1);
    const tUserId = UserId(1);

    final tPost = Post(
      id: tPostId,
      userId: tUserId,
      title: 'Title',
      body: 'Body',
      isRead: false,
    );

    test('Default constructor sets isRead to false', () {
      final post = Post(
        id: tPostId,
        userId: tUserId,
        title: 'Title',
        body: 'Body',
      );
      expect(post.isRead, false);
    });

    test('PostId and UserId extension types behave like integers', () {
      expect(tPostId + 1, 2);
      expect(tUserId.isEven, false);
      expect(tPostId.toString(), '1');
    });

    test('fromJson creates correct Post object', () {
      final json = {
        'id': 1,
        'userId': 1,
        'title': 'Title',
        'body': 'Body',
        'isRead': 0,
      };

      final result = Post.fromJson(json);

      expect(result, tPost);
      expect(result.isRead, false);
    });

    test('fromJson handles isRead as 1', () {
      final json = {
        'id': 1,
        'userId': 1,
        'title': 'Title',
        'body': 'Body',
        'isRead': 1,
      };

      final result = Post.fromJson(json);

      expect(result.isRead, true);
    });

    test('toMap returns correct Map object', () {
      final result = tPost.toMap();

      expect(result['id'], 1);
      expect(result['userId'], 1);
      expect(result['title'], 'Title');
      expect(result['body'], 'Body');
      expect(result['isRead'], 0);
    });

    test('toMap handles isRead = true', () {
      final post = tPost.copyWith(isRead: true);
      final result = post.toMap();
      expect(result['isRead'], 1);
    });

    test('fromDbMap handles isRead = 1', () {
      final dbMap = {
        PostSchema.id: 1,
        PostSchema.userId: 1,
        PostSchema.title: 'Title',
        PostSchema.body: 'Body',
        PostSchema.isRead: 1,
      };

      final result = Post.fromDbMap(dbMap);

      expect(result.id, 1);
      expect(result.isRead, true);
    });

    test('fromDbMap handles isRead = 0', () {
      final dbMap = {
        PostSchema.id: 1,
        PostSchema.userId: 1,
        PostSchema.title: 'Title',
        PostSchema.body: 'Body',
        PostSchema.isRead: 0,
      };

      final result = Post.fromDbMap(dbMap);

      expect(result.isRead, false);
    });

    test('copyWith returns identical object if no params provided', () {
      final result = tPost.copyWith();
      expect(result, tPost);
      expect(identical(result, tPost), false); // It's a new instance
    });

    test('copyWith updates all fields', () {
      final result = tPost.copyWith(
        id: const PostId(2),
        userId: const UserId(2),
        title: 'New Title',
        body: 'New Body',
        isRead: true,
      );

      expect(result.id, 2);
      expect(result.userId, 2);
      expect(result.title, 'New Title');
      expect(result.body, 'New Body');
      expect(result.isRead, true);
    });

    test('equality and hashCode', () {
      final post1 = Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'T',
        body: 'B',
        isRead: false,
      );
      final post2 = Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'T',
        body: 'B',
        isRead: false,
      );
      final post3 = Post(
        id: const PostId(2),
        userId: const UserId(1),
        title: 'T',
        body: 'B',
        isRead: false,
      );
      final post4 = post1.copyWith(isRead: true);

      // Equality
      expect(post1, post2);
      expect(post1, isNot(post3));
      expect(post1, isNot(post4));

      // Comparison with non-Post object
      expect(post1, isNot('not a post'));

      // Comparison with null
      expect(post1, isNot(null));

      // HashCode consistency
      expect(post1.hashCode, post2.hashCode);
      expect(post1.hashCode, isNot(post3.hashCode));

      // Identical
      expect(post1 == post1, true);
    });
  });
}
