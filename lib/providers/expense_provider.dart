import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_client.dart';

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await ApiClient.delete('/expenses/$id/');
      await loadExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
