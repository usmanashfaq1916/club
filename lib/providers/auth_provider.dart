import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get userRole => _user?['role'] ?? '';
  bool get isAdmin => _user?['role'] == 'Admin';
  bool get isCoach => _user?['role'] == 'Coach';
  bool get isParent => _user?['role'] == 'Parent';

  Future<void> checkAuth() async {
    if (await _authService.isLoggedIn()) {
      try {
        _user = await _authService.getUserProfile();
        notifyListeners();
      } catch (_) {
        _user = null;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatError(Object e) {
    if (e is ApiException) {
      final msg = e.message;
      if (msg.contains('No active account')) return 'Invalid email or password';
      if (msg.contains('Unable to log in')) return 'Invalid email or password';
      if (msg.contains('invalid')) return 'Invalid email or password';
      if (e.statusCode == 401) return 'Invalid email or password';
      if (e.statusCode == 403) return 'Access denied';
      if (e.statusCode == 500) return 'Server error. Try again later.';
    }
    return 'Login failed. Check your connection.';
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> register(String email, String password, String fullName,
      String role, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.register(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
          phone: phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
