import 'package:flutter/material.dart';
import '../models/performance.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class PerformanceProvider extends ChangeNotifier {
  List<Performance> _performances = [];
  bool _isLoading = false;
  String? _error;

  List<Performance> get performances => _performances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPerformances({String? studentId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (studentId != null) params['student_id'] = studentId;
      final data = await ApiClient.get('/performances/', queryParams: params.isNotEmpty ? params : null);
      final results = data['results'] ?? data ?? [];
      _performances = (results as List)
          .map((j) => Performance.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _performances = MockDataService.performances;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  void loadMockData() {
    _performances = MockDataService.performances;
    _error = null;
    notifyListeners();
  }

  List<Performance> getStudentPerformances(String studentId) {
    return _performances
        .where((p) => p.studentId == studentId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Performance? getLatestPerformance(String studentId) {
    final list = getStudentPerformances(studentId);
    return list.isNotEmpty ? list.first : null;
  }

  Future<bool> addPerformance(Performance performance) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.post('/performances/', body: {
        'student': int.tryParse(performance.studentId) ?? performance.studentId,
        'batting_rating': performance.battingRating,
        'bowling_rating': performance.bowlingRating,
        'fielding_rating': performance.fieldingRating,
        'fitness_rating': performance.fitnessRating,
        'discipline_rating': performance.disciplineRating,
        'coach_remarks': performance.coachRemarks ?? '',
      });
      _isLoading = false;
      await loadPerformances(studentId: performance.studentId);
      return true;
    } catch (e) {
      _performances.add(performance);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  void clear() {
    _performances = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
