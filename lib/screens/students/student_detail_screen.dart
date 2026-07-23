import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../config/theme.dart';
import 'student_form_screen.dart';
import '../fees/fee_management_screen.dart';
import '../performance/performance_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentFormScreen(student: student),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context, isDark),
            const SizedBox(height: 16),
            _buildInfoCard(context, isDark),
            const SizedBox(height: 16),
            _buildQRCard(context, isDark),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              backgroundImage: student.photoUrl != null
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl == null
                  ? Text(
                      student.fullName.isNotEmpty
                          ? student.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              student.fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: student.isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: student.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${student.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(),
            _infoRow('Father Name', student.fatherName),
            _infoRow('Date of Birth', student.dateOfBirth.toLocal().toString().split(' ')[0]),
            _infoRow('Age', '${student.age} years'),
            _infoRow('Gender', student.gender),
            _infoRow('Blood Group', student.bloodGroup),
            const SizedBox(height: 12),
            Text('Contact Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(),
            _infoRow('Mobile', student.mobileNumber,
                action: IconButton(
                    icon: const Icon(Icons.phone, color: AppTheme.primaryGreen, size: 20),
                    onPressed: () => launchUrl(
                        Uri.parse('tel:${student.mobileNumber}'))),
                ),
            if (student.whatsappNumber != null)
              _infoRow('WhatsApp', student.whatsappNumber!,
                  action: IconButton(
                      icon: const Icon(Icons.chat, color: Colors.green, size: 20),
                      onPressed: () => launchUrl(Uri.parse(
                          'https://wa.me/${student.whatsappNumber}'))),
                  ),
            _infoRow('Emergency', student.emergencyContact),
            _infoRow('Address', student.address),
            const SizedBox(height: 12),
            Text('Academy Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(),
            _infoRow('Batch', student.batch),
            _infoRow('Skill Level', student.skillLevel),
            if (student.playingRole.isNotEmpty)
              _infoRow('Playing Role', student.playingRole),
            _infoRow('Join Date', student.joinDate.toLocal().toString().split(' ')[0]),
            _infoRow('Monthly Fee', 'Rs.${student.monthlyFee.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildQRCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Student QR Code',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            QrImageView(
              data: student.id,
              version: QrVersions.auto,
              size: 150,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppTheme.primaryGreen,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PerformanceScreen(studentId: student.id)),
              );
            },
            icon: const Icon(Icons.stars),
            label: const Text('Performance'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeeManagementScreen(
                      initialStudentId: student.id),
                ),
              );
            },
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Fees'),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await context
                  .read<StudentProvider>()
                  .deleteStudent(student.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }
}
