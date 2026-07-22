import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

http_testing.MockClient createMockClient({
  Map<String, dynamic> Function(String method, String path)? handler,
}) {
  return http_testing.MockClient((request) async {
    if (handler != null) {
      final result = handler(request.method, request.url.path);
      if (result != null) {
        return http.Response(jsonEncode(result), 200);
      }
    }
    return http.Response('{}', 200);
  });
}

http_testing.MockClient createPagedMockClient(List<Map<String, dynamic>> items) {
  return http_testing.MockClient((request) async {
    return http.Response(jsonEncode({'results': items, 'count': items.length}), 200);
  });
}

http_testing.MockClient createErrorMockClient(int statusCode, String message) {
  return http_testing.MockClient((request) async {
    return http.Response(jsonEncode({'detail': message}), statusCode);
  });
}
