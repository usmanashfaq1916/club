import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/performance_provider.dart';
import 'package:young_fighters_academy/models/performance.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/test_data.dart';

void main() {
  group('PerformanceProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('initial state', (tester) async {
      final provider = PerformanceProvider();
      expect(provider.performances, []);
      expect(provider.isLoading, false);
    });

    testWidgets('loadPerformances populates list', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [TestData.samplePerformance.toMap()],
        }), 200);
      });

      final provider = PerformanceProvider();
      await provider.loadPerformances();

      expect(provider.performances.length, 1);
      expect(provider.isLoading, false);
    });

    testWidgets('loadPerformances with studentId filter', (tester) async {
      String? capturedQuery;
      ApiClient.client = http_testing.MockClient((request) async {
        capturedQuery = request.url.queryParameters['student_id'];
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = PerformanceProvider();
      await provider.loadPerformances(studentId: '1');

      expect(capturedQuery, '1');
    });

    testWidgets('getStudentPerformances filters by studentId and sorts', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Performance(id: '1', studentId: '1', date: DateTime(2026, 7, 20)).toMap(),
            Performance(id: '2', studentId: '1', date: DateTime(2026, 7, 25)).toMap(),
            Performance(id: '3', studentId: '2', date: DateTime(2026, 7, 15)).toMap(),
          ],
        }), 200);
      });

      final provider = PerformanceProvider();
      await provider.loadPerformances();

      final student1Perfs = provider.getStudentPerformances('1');
      expect(student1Perfs.length, 2);
      expect(student1Perfs.first.id, '2');
    });

    testWidgets('getLatestPerformance returns most recent', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Performance(id: '1', studentId: '1', date: DateTime(2026, 7, 20)).toMap(),
            Performance(id: '2', studentId: '1', date: DateTime(2026, 7, 25)).toMap(),
          ],
        }), 200);
      });

      final provider = PerformanceProvider();
      await provider.loadPerformances();

      final latest = provider.getLatestPerformance('1');
      expect(latest, isNotNull);
      expect(latest!.id, '2');
    });

    testWidgets('getLatestPerformance returns null for no records', (tester) async {
      final provider = PerformanceProvider();
      expect(provider.getLatestPerformance('999'), null);
    });

    testWidgets('addPerformance sends POST and reloads', (tester) async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '10'}), 201);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = PerformanceProvider();
      final result = await provider.addPerformance(TestData.samplePerformance);

      expect(result, true);
      expect(postCallCount, 1);
    });

    testWidgets('clearError resets error', (tester) async {
      final provider = PerformanceProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
