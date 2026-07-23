import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiClient {
  static const _tokenKey = 'jwt_token';
  static const _refreshKey = 'refresh_token';

  static String baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000/api');
  static http.Client _client = http.Client();

  static http.Client get client => _client;
  static set client(http.Client c) => _client = c;

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setTokens(String access, String refresh) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, access);
      await prefs.setString(_refreshKey, refresh);
    } catch (_) {}
  }

  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshKey);
    } catch (_) {}
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.put(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.delete(uri, headers: await _headers());
    return _handleResponse(response);
  }

  static Future<dynamic> uploadFile(
    String path,
    String field,
    List<int> fileBytes,
    String fileName, {
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes(field, fileBytes, filename: fileName));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    final streamedResponse = await _client.send(request);
    final responseBody = await streamedResponse.stream.bytesToString();
    return _handleResponse(http.Response(responseBody, streamedResponse.statusCode));
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    if (response.statusCode == 401) {
      clearTokens();
    }
    final body = response.body.isEmpty ? '{}' : response.body;
    final detail = jsonDecode(body);
    throw ApiException(
      statusCode: response.statusCode,
      message: detail is Map ? detail.toString() : detail.toString(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'API Error $statusCode: $message';
}
