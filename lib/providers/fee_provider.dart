import 'package:flutter/material.dart';
import '../models/fee.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class FeeProvider extends ChangeNotifier {
  List<Fee> _fees = [];
  bool _isLoading = false;
  String? _error;

  List<Fee> get fees => _fees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalCollected =>
      _fees.fold(0.0, (prev, f) => prev + f.paidAmount);
  double get pendingAmount => _fees
      .where((f) => f.status == 'Pending' || f.status == 'Partial')
      .fold(0.0, (prev, f) => prev + (f.monthlyFee - f.paidAmount));
  List<Fee> get defaulters =>
      _fees.where((f) => f.status == 'Pending').toList();

  Future<void> loadFees({String? studentId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (studentId != null) params['student_id'] = studentId;
      final data = await ApiClient.get('/fees/', queryParams: params.isNotEmpty ? params : null);
      final results = data['results'] ?? data ?? [];
      _fees = (results as List)
          .map((j) => Fee.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _fees = MockDataService.fees;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  void loadMockData() {
    _fees = MockDataService.fees;
    _error = null;
    notifyListeners();
  }

  Future<bool> addFee(Fee fee) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.post('/fees/', body: {
        'student': int.tryParse(fee.studentId) ?? fee.studentId,
        'month': fee.month,
        'monthly_fee': fee.monthlyFee.toString(),
        'discount': fee.discount.toString(),
        'paid_amount': fee.paidAmount.toString(),
        'balance': fee.balance.toString(),
        'due_date': fee.dueDate.toIso8601String().split('T')[0],
        'payment_date': fee.paymentDate?.toIso8601String().split('T')[0],
        'payment_method': fee.paymentMethod,
        'receipt_number': fee.receiptNumber ?? '',
        'status': fee.status,
      });
      _isLoading = false;
      await loadFees();
      return true;
    } catch (e) {
      _fees.add(fee);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateFee(String id, Map<String, dynamic> data) async {
    try {
      await ApiClient.put('/fees/$id/', body: data);
      await loadFees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Fee> getStudentFees(String studentId) {
    return _fees.where((f) => f.studentId == studentId).toList();
  }

  void clear() {
    _fees = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
