import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:young_fighters_academy/screens/dashboard/dashboard_screen.dart';
import 'package:young_fighters_academy/providers/dashboard_provider.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';

void main() {
  setUp(() {
    ApiClient.baseUrl = 'http://test.com/api';
  });

  testWidgets('DashboardScreen shows stat cards after loading',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    ApiClient.client = http_testing.MockClient((request) async {
      return http.Response(jsonEncode({
        'total_students': 25,
        'active_students': 22,
        'present_today': 18,
        'total_today': 20,
        'fee_collected': 45000.0,
        'pending_fees': 12000.0,
        'monthly_income': 35000.0,
        'monthly_expenses': 15000.0,
        'net_profit': 20000.0,
        'recent_activities': [
          {'action': 'New student joined', 'details': 'Rahul Sharma'},
        ],
        'fee_due_list': [
          {'studentId': '1', 'monthlyFee': 1500, 'month': 'July'},
        ],
      }), 200);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Young Fighters Academy'), findsOneWidget);
  });
}
