import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class DashboardProvider extends ChangeNotifier {
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _presentToday = 0;
  int _totalToday = 0;
  double _feeCollected = 0;
  double _pendingFees = 0;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  double _netProfit = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _feeDueList = [];
  bool _isLoading = false;

  int get totalStudents => _totalStudents;
  int get activeStudents => _activeStudents;
  int get presentToday => _presentToday;
  int get totalToday => _totalToday;
  double get attendancePercentage =>
      _totalToday > 0 ? (_presentToday / _totalToday) * 100 : 0;
  double get feeCollected => _feeCollected;
  double get pendingFees => _pendingFees;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpenses => _monthlyExpenses;
  double get netProfit => _netProfit;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<Map<String, dynamic>> get feeDueList => _feeDueList;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/dashboard/');
      _totalStudents = data['total_students'] ?? 0;
      _activeStudents = data['active_students'] ?? 0;
      _presentToday = data['present_today'] ?? 0;
      _totalToday = data['total_today'] ?? 0;
      _feeCollected = (data['fee_collected'] ?? 0).toDouble();
      _pendingFees = (data['pending_fees'] ?? 0).toDouble();
      _monthlyIncome = (data['monthly_income'] ?? 0).toDouble();
      _monthlyExpenses = (data['monthly_expenses'] ?? 0).toDouble();
      _netProfit = (data['net_profit'] ?? 0).toDouble();
      _recentActivities = (data['recent_activities'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      _feeDueList = (data['fee_due_list'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      loadMockData();
    }
  }

  void loadMockData() {
    _totalStudents = MockDataService.students.length;
    _activeStudents = MockDataService.students.where((s) => s.isActive).length;
    _presentToday = 15;
    _totalToday = 18;
    _feeCollected = MockDataService.totalFeeCollected;
    _pendingFees = MockDataService.totalPendingFees;
    _monthlyIncome = MockDataService.totalFeeCollected + 5000;
    _monthlyExpenses = MockDataService.totalExpensesAmount;
    _netProfit = _monthlyIncome - _monthlyExpenses;
    _recentActivities = MockDataService.recentActivities;
    _feeDueList = MockDataService.feeDueList;
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _totalStudents = 0;
    _activeStudents = 0;
    _presentToday = 0;
    _totalToday = 0;
    _feeCollected = 0;
    _pendingFees = 0;
    _monthlyIncome = 0;
    _monthlyExpenses = 0;
    _netProfit = 0;
    _recentActivities = [];
    _feeDueList = [];
    notifyListeners();
  }
}
