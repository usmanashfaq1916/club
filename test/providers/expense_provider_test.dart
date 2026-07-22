import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/expense_provider.dart';
import 'package:young_fighters_academy/models/expense.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/test_data.dart';

void main() {
  group('ExpenseProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('initial state', (tester) async {
      final provider = ExpenseProvider();
      expect(provider.expenses, []);
      expect(provider.isLoading, false);
      expect(provider.filter, 'All');
      expect(provider.totalExpenses, 0);
    });

    testWidgets('loadExpenses populates list', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [TestData.sampleExpense.toMap()],
        }), 200);
      });

      final provider = ExpenseProvider();
      await provider.loadExpenses();

      expect(provider.expenses.length, 1);
      expect(provider.totalExpenses, 2500.0);
      expect(provider.isLoading, false);
    });

    testWidgets('filter by category', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Expense(id: '1', title: 'Balls', category: 'Equipment', amount: 2000, date: DateTime(2026, 7, 1)).toMap(),
            Expense(id: '2', title: 'Salary', category: 'Salary', amount: 10000, date: DateTime(2026, 7, 1)).toMap(),
          ],
        }), 200);
      });

      final provider = ExpenseProvider();
      await provider.loadExpenses();
      expect(provider.expenses.length, 2);

      provider.filter = 'Equipment';
      expect(provider.expenses.length, 1);
      expect(provider.expenses.first.title, 'Balls');

      provider.filter = 'All';
      expect(provider.expenses.length, 2);
    });

    testWidgets('getExpensesForMonth calculates correctly', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            Expense(id: '1', title: 'E1', category: 'Other', amount: 1000, date: DateTime(2026, 7, 1)).toMap(),
            Expense(id: '2', title: 'E2', category: 'Other', amount: 2000, date: DateTime(2026, 7, 15)).toMap(),
            Expense(id: '3', title: 'E3', category: 'Other', amount: 3000, date: DateTime(2026, 8, 1)).toMap(),
          ],
        }), 200);
      });

      final provider = ExpenseProvider();
      await provider.loadExpenses();

      expect(provider.getExpensesForMonth(7, 2026), 3000.0);
      expect(provider.getExpensesForMonth(8, 2026), 3000.0);
      expect(provider.getExpensesForMonth(9, 2026), 0);
    });

    testWidgets('addExpense sends POST and reloads', (tester) async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '10'}), 201);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = ExpenseProvider();
      final result = await provider.addExpense(TestData.sampleExpense);

      expect(result, true);
      expect(postCallCount, 1);
    });

    testWidgets('deleteExpense sends DELETE and reloads', (tester) async {
      int deleteCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'DELETE') {
          deleteCallCount++;
          return http.Response('', 204);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = ExpenseProvider();
      final result = await provider.deleteExpense('1');

      expect(result, true);
      expect(deleteCallCount, 1);
    });

    testWidgets('clearError resets error', (tester) async {
      final provider = ExpenseProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
