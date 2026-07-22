import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/fee_provider.dart';
import 'package:young_fighters_academy/models/fee.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/test_data.dart';

void main() {
  group('FeeProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('initial state', (tester) async {
      final provider = FeeProvider();
      expect(provider.fees, []);
      expect(provider.isLoading, false);
      expect(provider.totalCollected, 0);
      expect(provider.pendingAmount, 0);
      expect(provider.defaulters, []);
    });

    testWidgets('loadFees populates list', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            TestData.sampleFee.toMap(),
          ],
        }), 200);
      });

      final provider = FeeProvider();
      await provider.loadFees();

      expect(provider.fees.length, 1);
      expect(provider.totalCollected, 1500.0);
      expect(provider.pendingAmount, 0);
      expect(provider.isLoading, false);
    });

    testWidgets('loadFees with studentId filter', (tester) async {
      String? capturedQuery;
      ApiClient.client = http_testing.MockClient((request) async {
        capturedQuery = request.url.queryParameters['student_id'];
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = FeeProvider();
      await provider.loadFees(studentId: '1');

      expect(capturedQuery, '1');
    });

    testWidgets('totalCollected calculates sum', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Fee(id: '1', studentId: '1', month: 'Jul', monthlyFee: 1000, paidAmount: 1000, balance: 0, dueDate: DateTime(2026, 7, 10), status: 'Paid').toMap(),
            Fee(id: '2', studentId: '1', month: 'Aug', monthlyFee: 1000, paidAmount: 500, balance: 500, dueDate: DateTime(2026, 8, 10), status: 'Partial').toMap(),
          ],
        }), 200);
      });

      final provider = FeeProvider();
      await provider.loadFees();

      expect(provider.totalCollected, 1500.0);
      expect(provider.pendingAmount, 500.0);
    });

    testWidgets('addFee sends POST and reloads', (tester) async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '10'}), 201);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = FeeProvider();
      final result = await provider.addFee(TestData.sampleFee);

      expect(result, true);
      expect(postCallCount, 1);
    });

    testWidgets('updateFee sends PUT and reloads', (tester) async {
      int putCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'PUT') {
          putCallCount++;
          return http.Response(jsonEncode({'id': '1'}), 200);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = FeeProvider();
      final result = await provider.updateFee('1', {'status': 'Paid'});

      expect(result, true);
      expect(putCallCount, 1);
    });

    testWidgets('getStudentFees filters by studentId', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Fee(id: '1', studentId: '1', month: 'Jul', monthlyFee: 1000, paidAmount: 1000, balance: 0, dueDate: DateTime(2026, 7, 10), status: 'Paid').toMap(),
            Fee(id: '2', studentId: '2', month: 'Jul', monthlyFee: 1000, paidAmount: 0, balance: 1000, dueDate: DateTime(2026, 7, 10), status: 'Pending').toMap(),
          ],
        }), 200);
      });

      final provider = FeeProvider();
      await provider.loadFees();

      final student1Fees = provider.getStudentFees('1');
      expect(student1Fees.length, 1);
      expect(student1Fees.first.studentId, '1');
    });

    testWidgets('clearError resets error', (tester) async {
      final provider = FeeProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
