import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:young_fighters_academy/screens/splash_screen.dart';
import 'package:young_fighters_academy/providers/auth_provider.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';

void main() {
  testWidgets('SplashScreen displays logo, title, and loading spinner',
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
          home: SplashScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Young Fighters'), findsOneWidget);
    expect(find.text('ACADEMY'), findsOneWidget);
    expect(find.byIcon(Icons.sports_cricket), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
