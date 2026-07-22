import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:young_fighters_academy/screens/home_screen.dart';
import 'package:young_fighters_academy/providers/auth_provider.dart';
import 'package:young_fighters_academy/providers/student_provider.dart';
import 'package:young_fighters_academy/providers/attendance_provider.dart';
import 'package:young_fighters_academy/providers/fee_provider.dart';
import 'package:young_fighters_academy/providers/performance_provider.dart';
import 'package:young_fighters_academy/providers/match_provider.dart';
import 'package:young_fighters_academy/providers/expense_provider.dart';
import 'package:young_fighters_academy/providers/dashboard_provider.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';

void main() {
  setUp(() {
    ApiClient.baseUrl = 'http://test.com/api';
  });

  testWidgets('HomeScreen has 5 navigation tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
          ChangeNotifierProvider(create: (_) => FeeProvider()),
          ChangeNotifierProvider(create: (_) => PerformanceProvider()),
          ChangeNotifierProvider(create: (_) => MatchProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Fees'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('HomeScreen starts on Dashboard tab',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
          ChangeNotifierProvider(create: (_) => FeeProvider()),
          ChangeNotifierProvider(create: (_) => PerformanceProvider()),
          ChangeNotifierProvider(create: (_) => MatchProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNWidgets(2));
  });
}
