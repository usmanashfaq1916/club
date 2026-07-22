import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:young_fighters_academy/providers/student_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/test_data.dart';

void main() {
  group('StudentProvider', () {
    setUp(() {
      ApiClient.baseUrl = 'http://test.com/api';
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('initial state is empty', () {
      final provider = StudentProvider();
      expect(provider.students, []);
      expect(provider.isLoading, false);
      expect(provider.totalStudents, 0);
      expect(provider.activeStudents, 0);
    });

    test('loadStudents populates list', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': TestData.studentListJson(),
        }), 200);
      });

      final provider = StudentProvider();
      await provider.loadStudents();

      expect(provider.students.length, 2);
      expect(provider.totalStudents, 2);
      expect(provider.activeStudents, 2);
      expect(provider.isLoading, false);
    });

    test('loadStudents handles error', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Server error'}), 500);
      });

      final provider = StudentProvider();
      await provider.loadStudents();

      expect(provider.error, isNotNull);
      expect(provider.isLoading, false);
    });

    test('search filters students', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': TestData.studentListJson(),
        }), 200);
      });

      final provider = StudentProvider();
      await provider.loadStudents();
      expect(provider.students.length, 2);

      provider.search('Virat');
      expect(provider.students.length, 1);
      expect(provider.students.first.fullName, 'Virat Singh');
    });

    test('search with empty query returns all', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': TestData.studentListJson(),
        }), 200);
      });

      final provider = StudentProvider();
      await provider.loadStudents();
      provider.search('Virat');
      expect(provider.students.length, 1);

      provider.search('');
      expect(provider.students.length, 2);
    });

    test('search by mobile number', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': TestData.studentListJson(),
        }), 200);
      });

      final provider = StudentProvider();
      await provider.loadStudents();
      provider.search('9988776655');
      expect(provider.students.length, 1);
      expect(provider.students.first.fullName, 'Virat Singh');
    });

    test('getStudentById returns correct student', () async {
      ApiClient.client = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({
          'results': TestData.studentListJson(),
        }), 200);
      });

      final provider = StudentProvider();
      await provider.loadStudents();

      final student = provider.getStudentById('1');
      expect(student, isNotNull);
      expect(student!.fullName, 'Rahul Sharma');

      final notFound = provider.getStudentById('999');
      expect(notFound, null);
    });

    test('addStudent sends POST and reloads', () async {
      int postCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'POST') {
          postCallCount++;
          return http.Response(jsonEncode({'id': '3'}), 201);
        }
        return http.Response(jsonEncode({'results': TestData.studentListJson()}), 200);
      });

      final provider = StudentProvider();
      final result = await provider.addStudent(TestData.sampleStudent);

      expect(result, true);
      expect(postCallCount, 1);
    });

    test('deleteStudent sends DELETE and reloads', () async {
      int deleteCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'DELETE') {
          deleteCallCount++;
          return http.Response('', 204);
        }
        return http.Response(jsonEncode({'results': TestData.studentListJson()}), 200);
      });

      final provider = StudentProvider();
      final result = await provider.deleteStudent('1');

      expect(result, true);
      expect(deleteCallCount, 1);
    });

    test('updateStudent sends PUT and reloads', () async {
      int putCallCount = 0;
      ApiClient.client = http_testing.MockClient((request) async {
        if (request.method == 'PUT') {
          putCallCount++;
          return http.Response(jsonEncode({'id': '1', 'fullName': 'Updated'}), 200);
        }
        return http.Response(jsonEncode({'results': TestData.studentListJson()}), 200);
      });

      final provider = StudentProvider();
      final result = await provider.updateStudent('1', {'fullName': 'Updated'});

      expect(result, true);
      expect(putCallCount, 1);
    });

    test('clearError resets error', () {
      final provider = StudentProvider();
      provider.clearError();
      expect(provider.error, null);
    });
  });
}
