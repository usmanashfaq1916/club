import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _records = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Attendance> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  int get presentCount =>
      _records.where((r) => r.status == 'Present' && _isToday(r.date)).length;
  int get absentCount =>
      _records.where((r) => r.status == 'Absent' && _isToday(r.date)).length;
  int get leaveCount =>
      _records.where((r) => r.status == 'Leave' && _isToday(r.date)).length;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> loadForDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final data = await ApiClient.get('/attendance/', queryParams: {'date': dateStr});
      final results = data['results'] ?? data ?? [];
      _records = (results as List)
          .map((j) => Attendance.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      notifyListeners();
    } catch (e) {
      _records = MockDataService.attendance
          .where((a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day)
          .toList();
      _error = null;
      notifyListeners();
    }
  }

  void loadMockData() {
    _records = MockDataService.attendance;
    _error = null;
    notifyListeners();
  }

  Future<bool> markAttendance(String studentId, DateTime date, String status) async {
    try {
      await ApiClient.post('/attendance/', body: {
        'student_id': studentId,
        'date': date.toIso8601String().split('T')[0],
        'status': status,
      });
      await loadForDate(date);
      return true;
    } catch (e) {
      final existing = _records.indexWhere((r) =>
          r.studentId == studentId &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day);
      if (existing >= 0) {
        _records[existing] = Attendance(
          id: _records[existing].id,
          studentId: studentId,
          date: date,
          status: status,
        );
      } else {
        _records.add(Attendance(
          id: '${studentId}_${date.millisecondsSinceEpoch}',
          studentId: studentId,
          date: date,
          status: status,
        ));
      }
      notifyListeners();
      return true;
    }
  }

  Future<bool> markBulkAttendance(List<Map<String, dynamic>> records) async {
    try {
      final bulk = records.map((r) => {
        'student_id': r['studentId'],
        'date': (r['date'] as DateTime).toIso8601String().split('T')[0],
        'status': r['status'],
      }).toList();
      await ApiClient.post('/attendance/bulk/', body: bulk);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getMonthlyAttendancePercentage(String studentId, int month, int year) {
    final monthRecords = _records.where((r) {
      final d = r.date;
      return r.studentId == studentId && d.month == month && d.year == year;
    }).toList();
    if (monthRecords.isEmpty) return 0;
    final present = monthRecords.where((r) => r.status == 'Present').length;
    return (present / monthRecords.length) * 100;
  }

  void clear() {
    _records = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
