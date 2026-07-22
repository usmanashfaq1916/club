import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/dashboard_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('DashboardProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('initial state has zero values', () {
      final provider = DashboardProvider();
      expect(provider.totalStudents, 0);
      expect(provider.activeStudents, 0);
      expect(provider.presentToday, 0);
      expect(provider.feeCollected, 0);
      expect(provider.isLoading, false);
    });

    test('loadDashboardData populates from API', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'total_students': 25,
          'active_students': 22,
          'present_today': 18,
          'total_today': 20,
          'fee_collected': 45000.0,
          'pending_fees': 12000.0,
          'monthly_income': 35000.0,
          'monthly_expenses': 15000.0,
          'net_profit': 20000.0,
          'recent_activities': [
            {'type': 'student_added', 'description': 'New student joined', 'timestamp': '2026-07-22T10:00:00Z'},
          ],
          'fee_due_list': [
            {'student_name': 'Rahul Sharma', 'amount': 1500.0, 'due_date': '2026-07-10'},
          ],
        }), 200);
      });

      final provider = DashboardProvider();
      await provider.loadDashboardData();

      expect(provider.totalStudents, 25);
      expect(provider.activeStudents, 22);
      expect(provider.presentToday, 18);
      expect(provider.totalToday, 20);
      expect(provider.attendancePercentage, 90.0);
      expect(provider.feeCollected, 45000.0);
      expect(provider.pendingFees, 12000.0);
      expect(provider.monthlyIncome, 35000.0);
      expect(provider.monthlyExpenses, 15000.0);
      expect(provider.netProfit, 20000.0);
      expect(provider.recentActivities.length, 1);
      expect(provider.feeDueList.length, 1);
      expect(provider.isLoading, false);
    });

    test('loadDashboardData handles error gracefully', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Error'}), 500);
      });

      final provider = DashboardProvider();
      await provider.loadDashboardData();

      expect(provider.isLoading, false);
      expect(provider.totalStudents, 0); // should stay at initial values on error
    });

    test('attendancePercentage returns 0 when totalToday is 0', () {
      final provider = DashboardProvider();
      expect(provider.attendancePercentage, 0);
    });
  });
}
