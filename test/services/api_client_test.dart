import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  setUp(() {
    ApiClient.baseUrl = 'http://test.com/api';
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('ApiClient', () {
    testWidgets('GET request returns data', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final data = await ApiClient.get('/students/');
      expect(data, isA<Map<String, dynamic>>());
      expect(data['results'], []);
    });

    testWidgets('POST request sends body', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response(jsonEncode({'access': 'token123'}), 200);
      });

      final data = await ApiClient.post('/auth/login/', body: {
        'email': 'test@test.com',
        'password': 'password123',
      });
      expect(data['access'], 'token123');
    });

    testWidgets('throws ApiException on 404', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Not found'}), 404);
      });

      expect(
        () => ApiClient.get('/error'),
        throwsA(isA<ApiException>()),
      );
    });

    testWidgets('throws ApiException on 401', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Unauthorized'}), 401);
      });

      expect(
        () => ApiClient.get('/unauthorized'),
        throwsA(isA<ApiException>()),
      );
    });

    testWidgets('returns null for empty body with 2xx', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response('', 204);
      });
      final result = await ApiClient.get('/empty');
      expect(result, null);
    });

    testWidgets('PUT request works', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        expect(request.method, 'PUT');
        return http.Response(jsonEncode({'id': '1', 'fullName': 'Updated'}), 200);
      });
      final data = await ApiClient.put('/students/1/', body: {'fullName': 'Updated'});
      expect(data['fullName'], 'Updated');
    });

    testWidgets('DELETE request works', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('', 204);
      });
      final result = await ApiClient.delete('/students/1/');
      expect(result, null);
    });

    test('ApiException has correct properties', () {
      final exception = ApiException(statusCode: 404, message: 'Not found');
      expect(exception.statusCode, 404);
      expect(exception.message, 'Not found');
      expect(exception.toString(), 'API Error 404: Not found');
    });
  });
}
