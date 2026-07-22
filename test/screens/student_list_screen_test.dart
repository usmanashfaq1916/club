import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:young_fighters_academy/screens/students/student_list_screen.dart';
import 'package:young_fighters_academy/providers/student_provider.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';

void main() {
  setUp(() {
    ApiClient.baseUrl = 'http://test.com/api';
  });

  testWidgets('StudentListScreen shows empty state when no students',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    ApiClient.client = http_testing.MockClient((request) async {
      return http.Response(jsonEncode({'results': []}), 200);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
        ],
        child: const MaterialApp(
          home: StudentListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No students found'), findsOneWidget);
    expect(find.text('Add a new student to get started'), findsOneWidget);
  });

  testWidgets('StudentListScreen shows students after loading',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    ApiClient.client = http_testing.MockClient((request) async {
      return http.Response(jsonEncode({
        'results': [
          {
            'id': '1',
            'fullName': 'Rahul Sharma',
            'fatherName': 'Raj Sharma',
            'mobileNumber': '9876543210',
            'dateOfBirth': '2010-05-15T00:00:00.000',
            'age': 14,
            'gender': 'Male',
            'address': 'Mumbai',
            'joinDate': '2024-01-10T00:00:00.000',
            'batch': 'Morning',
            'skillLevel': 'Intermediate',
            'monthlyFee': 1500.0,
            'emergencyContact': '9876543211',
            'bloodGroup': 'O+',
            'isActive': true,
          },
        ],
      }), 200);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
        ],
        child: const MaterialApp(
          home: StudentListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Students'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
