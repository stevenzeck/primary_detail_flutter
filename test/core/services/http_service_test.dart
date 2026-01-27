import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:primary_detail_flutter/core/services/http_service.dart';
import 'package:primary_detail_flutter/features/posts/models/post.dart';

void main() {
  const String tBaseUrl = 'jsonplaceholder.typicode.com';

  group('HttpService', () {
    final tPosts = [
      Post(
        id: const PostId(1),
        userId: const UserId(1),
        title: 'Test Title 1',
        body: 'Test Body 1',
      ),
    ];

    group('getPosts', () {
      test('returns a list of posts on 200 OK', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'userId': 1,
                'title': 'Test Title 1',
                'body': 'Test Body 1',
              },
            ]),
            200,
          );
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);
        final result = await service.getPosts();

        expect(result, equals(tPosts));
      });

      test('throws PostNetworkException on 404', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPosts(),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('404'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on timeout', () async {
        final mockClient = MockClient((request) async {
          throw TimeoutException('Timed out');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPosts(),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('timed out'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on ClientException', () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('No internet');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPosts(),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('connect'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on FormatException', () async {
        final mockClient = MockClient((request) async {
          return http.Response('invalid json', 200);
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPosts(),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('format'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on unknown error', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Something went wrong');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPosts(),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('Unknown error'),
            ),
          ),
        );
      });
    });

    group('getPost', () {
      test('returns a single post on 200 OK', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'id': 1,
              'userId': 1,
              'title': 'Test Title 1',
              'body': 'Test Body 1',
            }),
            200,
          );
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);
        final result = await service.getPost(1);

        expect(result, equals(tPosts[0]));
      });

      test('throws PostNetworkException on 404', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPost(1),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('404'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on timeout', () async {
        final mockClient = MockClient((request) async {
          throw TimeoutException('Timed out');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPost(1),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('timed out'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on ClientException', () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('No internet');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPost(1),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('connect'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on FormatException', () async {
        final mockClient = MockClient((request) async {
          return http.Response('invalid json', 200);
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPost(1),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('format'),
            ),
          ),
        );
      });

      test('throws PostNetworkException on unknown error', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Something went wrong');
        });

        final service = HttpService(baseUrl: tBaseUrl, client: mockClient);

        expect(
          () => service.getPost(1),
          throwsA(
            isA<PostNetworkException>().having(
              (e) => e.message,
              'message',
              contains('Unknown error'),
            ),
          ),
        );
      });
    });

    group('PostNetworkException', () {
      test('toString returns the message', () {
        const message = 'Test error';
        final exception = PostNetworkException(message);
        expect(exception.toString(), message);
      });
    });

    test('default constructor uses http.Client', () {
      final service = HttpService(baseUrl: tBaseUrl);
      expect(service.client, isA<http.Client>());
    });
  });
}
