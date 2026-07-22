import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/attendance_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('AttendanceProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('initial state', () {
      final provider = AttendanceProvider();
      expect(provider.records, []);
      expect(provider.isLoading, false);
    });

    test('loadForDate populates records', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            {'id': '1', 'studentId': '1', 'date': '2026-07-22T00:00:00.000', 'status': 'Present'},
            {'id': '2', 'studentId': '2', 'date': '2026-07-22T00:00:00.000', 'status': 'Absent'},
          ],
        }), 200);
      });

      final provider = AttendanceProvider();
      await provider.loadForDate(DateTime(2026, 7, 22));

      expect(provider.records.length, 2);
      expect(provider.error, null);
    });

    test('markAttendance sends POST and reloads', () async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '3'}), 201);
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      final provider = AttendanceProvider();
      final result = await provider.markAttendance('1', DateTime(2026, 7, 22), 'Present');

      expect(result, true);
      expect(postCallCount, 1);
    });

    test('markBulkAttendance sends bulk POST', () async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          expect(request.url.path, contains('/bulk/'));
          return http.Response(jsonEncode([]), 201);
        }
        return http.Response('{}', 200);
      });

      final provider = AttendanceProvider();
      final result = await provider.markBulkAttendance([
        {'studentId': '1', 'date': DateTime(2026, 7, 22), 'status': 'Present'},
        {'studentId': '2', 'date': DateTime(2026, 7, 22), 'status': 'Absent'},
      ]);

      expect(result, true);
      expect(postCallCount, 1);
    });

    test('setSelectedDate updates date', () {
      final provider = AttendanceProvider();
      final newDate = DateTime(2026, 8, 1);
      provider.setSelectedDate(newDate);
      expect(provider.selectedDate, newDate);
    });

    test('presentCount/absentCount return correct counts', () {
      final provider = AttendanceProvider();
      expect(provider.presentCount, 0);
      expect(provider.absentCount, 0);
      expect(provider.leaveCount, 0);
    });

    test('getMonthlyAttendancePercentage calculates correctly', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': [
            {'id': '1', 'studentId': '1', 'date': '2026-07-01T00:00:00.000', 'status': 'Present'},
            {'id': '2', 'studentId': '1', 'date': '2026-07-02T00:00:00.000', 'status': 'Present'},
            {'id': '3', 'studentId': '1', 'date': '2026-07-03T00:00:00.000', 'status': 'Absent'},
            {'id': '4', 'studentId': '1', 'date': '2026-07-04T00:00:00.000', 'status': 'Present'},
          ],
        }), 200);
      });

      final provider = AttendanceProvider();
      await provider.loadForDate(DateTime(2026, 7, 22));

      final pct = provider.getMonthlyAttendancePercentage('1', 7, 2026);
      expect(pct, 75.0);
    });

    test('getMonthlyAttendancePercentage returns 0 for no records', () {
      final provider = AttendanceProvider();
      expect(provider.getMonthlyAttendancePercentage('999', 7, 2026), 0);
    });

    test('clearError resets error', () {
      final provider = AttendanceProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
