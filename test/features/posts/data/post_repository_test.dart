import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:primary_detail_flutter/core/services/database_service.dart';
import 'package:primary_detail_flutter/core/services/http_service.dart';
import 'package:primary_detail_flutter/features/posts/data/post_repository.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';

class MockHttpService extends Mock implements HttpService {
  @override
  Future<List<Post>> getPosts() =>
      (super.noSuchMethod(
            Invocation.method(#getPosts, []),
            returnValue: Future<List<Post>>.value(<Post>[]),
          )
          as Future<List<Post>>);

  @override
  Future<Post> getPost(int? postId) =>
      (super.noSuchMethod(
            Invocation.method(#getPost, [postId]),
            returnValue: Future<Post>.value(
              Post(
                id: PostId(postId ?? 0),
                userId: const UserId(1),
                title: '',
                body: '',
              ),
            ),
          )
          as Future<Post>);
}

class MockPostDatabase extends Mock implements PostDatabase {
  @override
  Future<List<Post>> getPosts() =>
      (super.noSuchMethod(
            Invocation.method(#getPosts, []),
            returnValue: Future<List<Post>>.value(<Post>[]),
          )
          as Future<List<Post>>);

  @override
  Future<Post?> getPost(int? postId) =>
      (super.noSuchMethod(
            Invocation.method(#getPost, [postId]),
            returnValue: Future<Post?>.value(),
          )
          as Future<Post?>);

  @override
  Future<void> insertPosts(List<Post>? posts) =>
      (super.noSuchMethod(
            Invocation.method(#insertPosts, [posts]),
            returnValue: Future<void>.value(),
          )
          as Future<void>);

  @override
  Future<void> updatePost(Post? post) =>
      (super.noSuchMethod(
            Invocation.method(#updatePost, [post]),
            returnValue: Future<void>.value(),
          )
          as Future<void>);

  @override
  Future<void> deletePost(int? id) =>
      (super.noSuchMethod(
            Invocation.method(#deletePost, [id]),
            returnValue: Future<void>.value(),
          )
          as Future<void>);

  @override
  Future<void> deletePosts(List<int>? ids) =>
      (super.noSuchMethod(
            Invocation.method(#deletePosts, [ids]),
            returnValue: Future<void>.value(),
          )
          as Future<void>);
}

void main() {
  late PostRepository repository;
  late MockHttpService mockHttpService;
  late MockPostDatabase mockDatabase;

  setUp(() {
    mockHttpService = MockHttpService();
    mockDatabase = MockPostDatabase();
    repository = PostRepository(mockHttpService, mockDatabase);
  });

  group('PostRepository', () {
    final tPost = Post(
      id: const PostId(1),
      userId: const UserId(1),
      title: 'Title',
      body: 'Body',
    );
    final tPosts = [tPost];

    test('fetchAndEmitPosts emits local data then refreshes from API', () async {
      when(mockDatabase.getPosts()).thenAnswer((_) async => tPosts);
      when(mockHttpService.getPosts()).thenAnswer((_) async => tPosts);
      when(
        mockDatabase.insertPosts(any),
      ).thenAnswer((_) async => Future<void>.value());

      // We expect the stream to emit twice: once for local, once after refresh.
      final expectation = expectLater(
        repository.postsStream,
        emitsInOrder([tPosts, tPosts]),
      );

      await repository.fetchAndEmitPosts();

      await expectation;
      // 1. Initial local fetch in fetchAndEmitPosts
      // 2. Local fetch inside refreshPosts to merge data
      // 3. Final emit after refresh
      verify(mockDatabase.getPosts()).called(3);
      verify(mockHttpService.getPosts()).called(1);
    });

    test('fetchAndEmitPosts rethrows if both DB and API fail', () async {
      when(mockDatabase.getPosts()).thenAnswer((_) async => []);
      when(
        mockHttpService.getPosts(),
      ).thenThrow(PostNetworkException('API error'));

      expect(
        () => repository.fetchAndEmitPosts(),
        throwsA(isA<PostNetworkException>()),
      );
    });

    test(
      'fetchAndEmitPosts logs error and keeps local data if background refresh fails and local data exists',
      () async {
        when(mockDatabase.getPosts()).thenAnswer((_) async => tPosts);
        when(
          mockHttpService.getPosts(),
        ).thenThrow(PostNetworkException('API error'));

        // We expect the stream to emit once (the local data)
        final expectation = expectLater(repository.postsStream, emits(tPosts));

        // This should NOT throw because we have local data.
        await repository.fetchAndEmitPosts();

        await expectation;

        // verify that it tried to refresh
        verify(mockHttpService.getPosts()).called(1);
        // 1. Initial local fetch in fetchAndEmitPosts
        // 2. Fetch in the catch block to check if empty
        verify(mockDatabase.getPosts()).called(2);
      },
    );

    test('refreshPosts merges API data with local isRead status', () async {
      final localPost = tPost.copyWith(isRead: true);
      final apiPost = tPost.copyWith(isRead: false);

      when(mockDatabase.getPosts()).thenAnswer((_) async => [localPost]);
      when(mockHttpService.getPosts()).thenAnswer((_) async => [apiPost]);
      when(
        mockDatabase.insertPosts(any),
      ).thenAnswer((_) async => Future<void>.value());

      await repository.refreshPosts();

      // Should have saved the merged post (isRead: true from local)
      verify(mockDatabase.insertPosts([localPost])).called(1);
    });

    test('getPost returns DB post if exists', () async {
      when(mockDatabase.getPost(1)).thenAnswer((_) async => tPost);

      final result = await repository.getPost(1);

      expect(result, tPost);
      verify(mockDatabase.getPost(1)).called(1);
      verifyZeroInteractions(mockHttpService);
    });

    test('getPost fetches from API if not in DB', () async {
      when(mockDatabase.getPost(1)).thenAnswer((_) async => null);
      when(mockHttpService.getPost(1)).thenAnswer((_) async => tPost);
      when(mockDatabase.getPosts()).thenAnswer((_) async => [tPost]);
      when(
        mockDatabase.insertPosts(any),
      ).thenAnswer((_) async => Future<void>.value());

      final result = await repository.getPost(1);

      expect(result, tPost);
      verify(mockDatabase.getPost(1)).called(1);
      verify(mockHttpService.getPost(1)).called(1);
      verify(mockDatabase.insertPosts([tPost])).called(1);
    });

    test('updatePost updates DB and emits new data', () async {
      when(mockDatabase.getPosts()).thenAnswer((_) async => [tPost]);
      when(
        mockDatabase.updatePost(any),
      ).thenAnswer((_) async => Future<void>.value());

      await repository.updatePost(tPost);

      verify(mockDatabase.updatePost(tPost)).called(1);
      verify(mockDatabase.getPosts()).called(1);
    });

    test('deletePost deletes from DB and emits new data', () async {
      when(mockDatabase.getPosts()).thenAnswer((_) async => []);
      when(
        mockDatabase.deletePost(any),
      ).thenAnswer((_) async => Future<void>.value());

      await repository.deletePost(1);

      verify(mockDatabase.deletePost(1)).called(1);
      verify(mockDatabase.getPosts()).called(1);
    });

    test('deletePosts deletes multiple from DB and emits new data', () async {
      when(mockDatabase.getPosts()).thenAnswer((_) async => []);
      when(
        mockDatabase.deletePosts(any),
      ).thenAnswer((_) async => Future<void>.value());

      await repository.deletePosts([1, 2]);

      verify(mockDatabase.deletePosts([1, 2])).called(1);
      verify(mockDatabase.getPosts()).called(1);
    });

    test('dispose closes the stream controller', () async {
      repository.dispose();

      expect(repository.postsStream, emitsDone);
    });
  });
}
