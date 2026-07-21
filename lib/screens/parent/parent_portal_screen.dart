import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ParentPortalScreen extends StatelessWidget {
  const ParentPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Portal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.visibility,
                      size: 48, color: AppTheme.primaryGreen),
                  const SizedBox(height: 12),
                  Text(
                    'Parent Portal',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View your child\'s progress, attendance, fees and more',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _portalCard(context, 'View Attendance', Icons.calendar_today,
              Colors.blue, 'Check daily attendance records'),
          _portalCard(context, 'Fee Status', Icons.account_balance_wallet,
              AppTheme.gold, 'View fee payments and dues'),
          _portalCard(context, 'Performance', Icons.stars,
              Colors.teal, 'View performance ratings and charts'),
          _portalCard(context, 'Download Report', Icons.download,
              AppTheme.primaryGreen, 'Download progress report'),
        ],
      ),
    );
  }

  Widget _portalCard(BuildContext context, String title, IconData icon,
      Color color, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title - Select a student to continue'),
            ),
          );
        },
      ),
    );
  }
}
