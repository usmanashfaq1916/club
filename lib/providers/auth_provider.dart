import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
      _error = e.toString();
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
