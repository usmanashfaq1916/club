import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'All';

  List<Expense> get expenses =>
      _filter == 'All'
          ? _expenses
          : _expenses.where((e) => e.category == _filter).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  set filter(String value) {
    _filter = value;
    notifyListeners();
  }

  double get totalExpenses =>
      _expenses.fold(0.0, (prev, e) => prev + e.amount);

  double getExpensesForMonth(int month, int year) {
    return _expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .fold(0.0, (prev, e) => prev + e.amount);
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get('/expenses/');
      final results = data['results'] ?? data ?? [];
      _expenses = (results as List)
          .map((j) => Expense.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _expenses = MockDataService.expenses;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  void loadMockData() {
    _expenses = MockDataService.expenses;
    _error = null;
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.post('/expenses/', body: {
        'title': expense.title,
        'category': expense.category,
        'amount': expense.amount.toString(),
        'date': expense.date.toIso8601String().split('T')[0],
        'notes': expense.notes ?? '',
      });
      _isLoading = false;
      await loadExpenses();
      return true;
    } catch (e) {
      _expenses.add(expense);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await ApiClient.delete('/expenses/$id/');
      await loadExpenses();
      return true;
    } catch (e) {
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    }
  }

  void clear() {
    _expenses = [];
    _filter = 'All';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
