import 'api_client.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final data = await ApiClient.post('/auth/login/', body: {
      'email': email,
      'password': password,
    });
    if (data != null && data['access'] != null) {
      await ApiClient.setTokens(data['access'], data['refresh']);
      final profile = await ApiClient.get('/auth/profile/');
      return profile;
    }
    return null;
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final data = await ApiClient.post('/auth/register/', body: {
      'email': email,
      'username': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      'phone': phone ?? '',
    });
    return data;
  }

  Future<void> logout() async {
    await ApiClient.clearTokens();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await ApiClient.get('/auth/profile/');
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }
}
