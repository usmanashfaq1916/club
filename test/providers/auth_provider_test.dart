import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/auth_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('AuthProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('initial state is not logged in', (tester) async {
      final provider = AuthProvider();
      expect(provider.isLoggedIn, false);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    testWidgets('login successful sets user and isLoggedIn', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.url.path.contains('/auth/login/')) {
          return http.Response(jsonEncode({
            'access': 'token123',
            'refresh': 'refresh123',
          }), 200);
        }
        if (request.url.path.contains('/auth/profile/')) {
          return http.Response(jsonEncode({
            'uid': '1',
            'email': 'admin@test.com',
            'fullName': 'Admin User',
            'role': 'Admin',
            'isActive': true,
          }), 200);
        }
        return http.Response('{}', 200);
      });

      final provider = AuthProvider();
      final result = await provider.login('admin@test.com', 'password');

      expect(result, true);
      expect(provider.isLoggedIn, true);
      expect(provider.isLoading, false);
      expect(provider.userRole, 'Admin');
      expect(provider.isAdmin, true);
      expect(provider.error, null);
    });

    testWidgets('login failure returns false and sets error', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Invalid credentials'}), 401);
      });

      final provider = AuthProvider();
      final result = await provider.login('bad@test.com', 'wrong');

      expect(result, false);
      expect(provider.isLoggedIn, false);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
    });

    testWidgets('logout clears user state', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.url.path.contains('/auth/login/')) {
          return http.Response(jsonEncode({
            'access': 'token123',
            'refresh': 'refresh123',
          }), 200);
        }
        if (request.url.path.contains('/auth/profile/')) {
          return http.Response(jsonEncode({
            'uid': '1',
            'email': 'admin@test.com',
            'fullName': 'Admin',
            'role': 'Admin',
          }), 200);
        }
        return http.Response('{}', 200);
      });

      final provider = AuthProvider();
      await provider.login('admin@test.com', 'password');
      expect(provider.isLoggedIn, true);

      await provider.logout();
      expect(provider.isLoggedIn, false);
      expect(provider.user, null);
    });

    testWidgets('clearError resets error', (tester) async {
      final provider = AuthProvider();
      provider.clearError();
      expect(provider.error, null);
    });

    testWidgets('role getters work correctly', (tester) async {
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.url.path.contains('/auth/login/')) {
          return http.Response(jsonEncode({
            'access': 'token123',
            'refresh': 'refresh123',
          }), 200);
        }
        if (request.url.path.contains('/auth/profile/')) {
          return http.Response(jsonEncode({
            'uid': '2',
            'email': 'coach@test.com',
            'fullName': 'Coach User',
            'role': 'Coach',
          }), 200);
        }
        return http.Response('{}', 200);
      });

      final provider = AuthProvider();
      expect(provider.isAdmin, false);
      expect(provider.isCoach, false);
      expect(provider.isParent, false);
    });
  });
}
