import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/match_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/test_data.dart';

void main() {
  group('MatchProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('initial state', () {
      final provider = MatchProvider();
      expect(provider.matches, []);
      expect(provider.isLoading, false);
    });

    test('loadMatches populates list', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [TestData.sampleMatchRecord.toMap()],
        }), 200);
      });

      final provider = MatchProvider();
      await provider.loadMatches();

      expect(provider.matches.length, 1);
      expect(provider.matches.first.opponent, 'Mumbai Academy');
      expect(provider.isLoading, false);
    });

    test('addMatch sends POST and reloads', () async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '10'}), 201);
        }
        return http.Response(jsonEncode({'results': [TestData.sampleMatchRecord.toMap()]}), 200);
      });

      final provider = MatchProvider();
      final result = await provider.addMatch(TestData.sampleMatchRecord);

      expect(result, true);
      expect(postCallCount, 1);
    });

    test('deleteMatch sends DELETE and reloads', () async {
      int deleteCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'DELETE') {
          deleteCallCount++;
          return http.Response('', 204);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = MatchProvider();
      final result = await provider.deleteMatch('1');

      expect(result, true);
      expect(deleteCallCount, 1);
    });

    test('loadMatches handles error', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Error'}), 500);
      });

      final provider = MatchProvider();
      await provider.loadMatches();

      expect(provider.error, isNotNull);
    });

    test('clearError resets error', () {
      final provider = MatchProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
