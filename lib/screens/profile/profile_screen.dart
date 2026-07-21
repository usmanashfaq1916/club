import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';
import '../login_screen.dart';
import '../matches/match_screen.dart';
import '../expenses/expense_screen.dart';
import '../reports/report_screen.dart';
import 'coach_management_screen.dart';
import '../parent/parent_portal_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: Icon(
                          auth.user?['role'] == 'Admin'
                              ? Icons.admin_panel_settings
                              : auth.user?['role'] == 'Coach'
                                  ? Icons.sports
                                  : Icons.person,
                          size: 36,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        auth.user?['full_name'] ?? 'User',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          auth.user?['role'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuSection('Management', [
                if (auth.isAdmin)
                  _menuItem(
                    context,
                    Icons.admin_panel_settings,
                    'Manage Coaches',
                    AppTheme.primaryGreen,
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CoachManagementScreen())),
                  ),
                _menuItem(
                  context,
                  Icons.sports_cricket,
                  'Match Records',
                  AppTheme.primaryGreen,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MatchScreen())),
                ),
                _menuItem(
                  context,
                  Icons.receipt_long,
                  'Expenses',
                  AppTheme.red,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ExpenseScreen())),
                ),
                _menuItem(
                  context,
                  Icons.assessment,
                  'Reports',
                  Colors.blue,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportScreen())),
                ),
                if (auth.isCoach)
                  _menuItem(
                    context,
                    Icons.visibility,
                    'Parent Portal View',
                    Colors.teal,
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ParentPortalScreen())),
                  ),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('Settings', [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode),
                  value: isDark,
                  onChanged: (_) =>
                      context.read<ThemeProvider>().toggleTheme(),
                  activeColor: AppTheme.primaryGreen,
                ),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('Account', [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.red),
                  title: const Text('Sign Out',
                      style: TextStyle(color: AppTheme.red)),
                  onTap: () => _logout(context),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                )),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }
}
