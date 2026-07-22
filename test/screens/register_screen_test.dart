import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:young_fighters_academy/screens/register_screen.dart';
import 'package:young_fighters_academy/providers/auth_provider.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';
import 'package:young_fighters_academy/services/api_client.dart';

void main() {
  setUp(() {
    ApiClient.baseUrl = 'http://test.com/api';
  });

  testWidgets('RegisterScreen renders all fields and button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Young Fighters Academy'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('RegisterScreen shows validation errors on empty submit',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.dragUntilVisible(
      find.text('Sign Up'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Enter full name'), findsOneWidget);
    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });

  testWidgets('RegisterScreen validates email format',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.dragUntilVisible(
      find.text('Sign Up'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('RegisterScreen validates password match',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@test.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'different');
    await tester.dragUntilVisible(
      find.text('Sign Up'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('RegisterScreen navigates to login on "Already have an account?"',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.dragUntilVisible(
      find.text('Already have an account? Sign In'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Already have an account? Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}
