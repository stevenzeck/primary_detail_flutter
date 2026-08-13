import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:primary_detail_flutter/core/services/database_service.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';
import 'package:sqflite/sqflite.dart';

/// Manual mock for Database to avoid build_runner dependency.
/// We use nullable types for non-nullable parameters to allow mockito matchers (which return null).
class MockDatabase extends Mock implements Database {
  @override
  Future<void> execute(String? sql, [List<Object?>? arguments]) async {
    await super.noSuchMethod(
      Invocation.method(#execute, [sql, arguments]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String? table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(
        #query,
        [table],
        {
          #distinct: distinct,
          #columns: columns,
          #where: where,
          #whereArgs: whereArgs,
          #groupBy: groupBy,
          #having: having,
          #orderBy: orderBy,
          #limit: limit,
          #offset: offset,
        },
      ),
      returnValue: Future<List<Map<String, Object?>>>.value(
        <Map<String, Object?>>[],
      ),
      returnValueForMissingStub: Future<List<Map<String, Object?>>>.value(
        <Map<String, Object?>>[],
      ),
    );
    return (result as List<dynamic>).cast<Map<String, Object?>>();
  }

  @override
  Future<int> update(
    String? table,
    Map<String, Object?>? values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(
        #update,
        [table, values],
        {
          #where: where,
          #whereArgs: whereArgs,
          #conflictAlgorithm: conflictAlgorithm,
        },
      ),
      returnValue: Future<int>.value(0),
      returnValueForMissingStub: Future<int>.value(0),
    );
    return result as int;
  }

  @override
  Future<int> delete(
    String? table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(
        #delete,
        [table],
        {#where: where, #whereArgs: whereArgs},
      ),
      returnValue: Future<int>.value(0),
      returnValueForMissingStub: Future<int>.value(0),
    );
    return result as int;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn)? action, {
    bool? exclusive,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(#transaction, [action], {#exclusive: exclusive}),
      returnValue: Future<T>.value(null as T),
      returnValueForMissingStub: Future<T>.value(null as T),
    );
    return result as T;
  }

  @override
  Future<void> close() async {
    await super.noSuchMethod(
      Invocation.method(#close, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

class MockTransaction extends Mock implements Transaction {
  @override
  Batch batch() => (super.noSuchMethod(
    Invocation.method(#batch, []),
    returnValue: MockBatch(),
  ) as Batch);
}

class MockBatch extends Mock implements Batch {
  @override
  void insert(
    String? table,
    Map<String, Object?>? values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) => super.noSuchMethod(
    Invocation.method(
      #insert,
      [table, values],
      {#nullColumnHack: nullColumnHack, #conflictAlgorithm: conflictAlgorithm},
    ),
  );

  @override
  void delete(String? table, {String? where, List<Object?>? whereArgs}) =>
      super.noSuchMethod(
        Invocation.method(
          #delete,
          [table],
          {#where: where, #whereArgs: whereArgs},
        ),
      );

  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(#commit, [], {
        #exclusive: exclusive,
        #noResult: noResult,
        #continueOnError: continueOnError,
      }),
      returnValue: Future<List<Object?>>.value(<Object?>[]),
      returnValueForMissingStub: Future<List<Object?>>.value(<Object?>[]),
    );
    return result as List<Object?>;
  }
}

/// Mock for DatabaseFactory to intercept top-level sqflite calls.
class MockDatabaseFactory extends Mock implements DatabaseFactory {
  @override
  Future<String> getDatabasesPath() async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(#getDatabasesPath, []),
      returnValue: Future<String>.value('test_path'),
      returnValueForMissingStub: Future<String>.value('test_path'),
    );
    return result as String;
  }

  @override
  Future<Database> openDatabase(
    String? path, {
    OpenDatabaseOptions? options,
  }) async {
    final dynamic result = await super.noSuchMethod(
      Invocation.method(#openDatabase, [path], {#options: options}),
      returnValue: Future<Database>.value(MockDatabase()),
      returnValueForMissingStub: Future<Database>.value(MockDatabase()),
    );
    return result as Database;
  }
}

void main() {
  late PostDatabase postDatabase;
  late MockDatabase mockDatabase;
  late MockDatabaseFactory mockFactory;

  setUp(() {
    mockDatabase = MockDatabase();
    mockFactory = MockDatabaseFactory();

    postDatabase = PostDatabase.db;
    postDatabase.databaseFactoryForTesting = mockFactory;
    postDatabase.databaseInstance = mockDatabase;
  });

  tearDown(() {
    postDatabase.databaseInstance = null;
    postDatabase.databaseFactoryForTesting = null;
  });

  group('PostDatabase Initialization', () {
    test('database getter initializes database when null', () async {
      postDatabase.databaseInstance = null; // Clear manual instance

      when(mockFactory.getDatabasesPath()).thenAnswer((_) async => 'test_path');
      when(mockFactory.openDatabase(any, options: anyNamed('options')))
          .thenAnswer((_) async => mockDatabase);

      final db = await postDatabase.database;

      expect(db, equals(mockDatabase));
      verify(mockFactory.getDatabasesPath()).called(1);
      verify(mockFactory.openDatabase(any, options: anyNamed('options')))
          .called(1);
    });

    test(
      'database getter handles concurrent calls and initializes only once',
      () async {
        postDatabase.databaseInstance = null;
        final completer = Completer<Database>();

        when(mockFactory.getDatabasesPath())
            .thenAnswer((_) async => 'test_path');
        when(mockFactory.openDatabase(any, options: anyNamed('options')))
            .thenAnswer((_) => completer.future);

        // Trigger multiple concurrent calls
        final future1 = postDatabase.database;
        final future2 = postDatabase.database;
        final future3 = postDatabase.database;

        completer.complete(mockDatabase);

        final db1 = await future1;
        final db2 = await future2;
        final db3 = await future3;

        expect(db1, equals(mockDatabase));
        expect(db2, equals(mockDatabase));
        expect(db3, equals(mockDatabase));

        // Verify initialization was only triggered once
        verify(mockFactory.openDatabase(any, options: anyNamed('options')))
            .called(1);
      },
    );
  });

  group('PostDatabase Operations', () {
    final tPost = Post(
      id: const PostId(1),
      userId: const UserId(1),
      title: 'Title',
      body: 'Body',
      isRead: false,
    );

    test('onCreate executes correct SQL', () async {
      await PostDatabase.onCreate(mockDatabase, 1);

      verify(
        mockDatabase.execute(
          argThat(
            allOf([
              contains('CREATE TABLE posts'),
              contains('id INTEGER PRIMARY KEY'),
              contains('userId INTEGER'),
              contains('title TEXT'),
              contains('body TEXT'),
              contains('isread INTEGER'),
            ]),
          ),
        ),
      ).called(1);
    });

    test('getPosts returns list of posts', () async {
      when(mockDatabase.query(any)).thenAnswer(
        (_) async => [
          {'id': 1, 'userId': 1, 'title': 'Title', 'body': 'Body', 'isread': 0},
        ],
      );

      final result = await postDatabase.getPosts();

      expect(result, [tPost]);
      verify(mockDatabase.query('posts')).called(1);
    });

    test('getPost returns post if exists', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer(
        (_) async => [
          {'id': 1, 'userId': 1, 'title': 'Title', 'body': 'Body', 'isread': 0},
        ],
      );

      final result = await postDatabase.getPost(1);

      expect(result, tPost);
      verify(mockDatabase.query('posts', where: 'id = ?', whereArgs: [1]))
          .called(1);
    });

    test('getPost returns null if post does not exist', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => []);

      final result = await postDatabase.getPost(1);

      expect(result, isNull);
    });

    test('updatePost calls database update', () async {
      when(
        mockDatabase.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await postDatabase.updatePost(tPost);

      verify(
        mockDatabase.update(
          'posts',
          any,
          where: 'id = ?',
          whereArgs: [tPost.id],
        ),
      ).called(1);
    });

    test('deletePost calls database delete', () async {
      when(
        mockDatabase.delete(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await postDatabase.deletePost(1);

      verify(mockDatabase.delete('posts', where: 'id = ?', whereArgs: [1]))
          .called(1);
    });

    test('deleteAllPosts calls database delete without where', () async {
      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);

      await postDatabase.deleteAllPosts();

      verify(mockDatabase.delete('posts')).called(1);
    });

    test('insertPosts uses transaction and batch', () async {
      final mockTransaction = MockTransaction();
      final mockBatch = MockBatch();

      when(
        mockDatabase.transaction<void>(
          any as Future<void> Function(Transaction)?,
        ),
      ).thenAnswer((invocation) async {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return await action(mockTransaction);
      });
      when(mockTransaction.batch()).thenReturn(mockBatch);
      when(mockBatch.commit(noResult: anyNamed('noResult')))
          .thenAnswer((_) async => <Object?>[]);

      await postDatabase.insertPosts([tPost]);

      verify(
        mockDatabase.transaction<void>(
          any as Future<void> Function(Transaction)?,
        ),
      ).called(1);
      verify(mockTransaction.batch()).called(1);
      verify(
        mockBatch.insert(
          'posts',
          any,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('deletePosts uses transaction and batch', () async {
      final mockTransaction = MockTransaction();
      final mockBatch = MockBatch();

      when(
        mockDatabase.transaction<void>(
          any as Future<void> Function(Transaction)?,
        ),
      ).thenAnswer((invocation) async {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return await action(mockTransaction);
      });
      when(mockTransaction.batch()).thenReturn(mockBatch);
      when(mockBatch.commit(noResult: anyNamed('noResult')))
          .thenAnswer((_) async => <Object?>[]);

      await postDatabase.deletePosts([1, 2]);

      verify(
        mockDatabase.transaction<void>(
          any as Future<void> Function(Transaction)?,
        ),
      ).called(1);
      verify(mockTransaction.batch()).called(1);
      verify(mockBatch.delete('posts', where: 'id = ?', whereArgs: [1]))
          .called(1);
      verify(mockBatch.delete('posts', where: 'id = ?', whereArgs: [2]))
          .called(1);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('deletePosts returns early if ids are empty', () async {
      await postDatabase.deletePosts([]);
      verifyNever(
        mockDatabase.transaction<void>(
          any as Future<void> Function(Transaction)?,
        ),
      );
    });

    test('close closes database and resets instances', () async {
      when(mockDatabase.close()).thenAnswer((_) async => {});

      await postDatabase.close();

      verify(mockDatabase.close()).called(1);
    });

    group('singleton behavior', () {
      test('db getter returns the same instance', () {
        expect(PostDatabase.db, same(PostDatabase.db));
      });
    });
  });
}
