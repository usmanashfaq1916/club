import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider', () {
    testWidgets('initial theme is light', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      await tester.pump();
      expect(provider.themeMode, ThemeMode.light);
    });

    testWidgets('toggleTheme switches between light and dark', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      await tester.pump();

      await provider.toggleTheme();
      await tester.pump();
      expect(provider.themeMode, ThemeMode.dark);

      await provider.toggleTheme();
      await tester.pump();
      expect(provider.themeMode, ThemeMode.light);
    });

    testWidgets('loads dark mode from SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({'darkMode': true});
      final provider = ThemeProvider();
      await tester.pump();
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
