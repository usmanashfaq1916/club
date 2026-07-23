import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/performance_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/student.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  Student? _selectedChild;
  bool _loading = true;
  double _attendancePercent = 0;
  double _feesPaid = 0;
  double _feesTotal = 0;
  int _performanceCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    if (auth.isParent) {
      final studentProv = context.read<StudentProvider>();
      await studentProv.loadStudents();
      if (studentProv.allStudents.isNotEmpty) {
        _selectedChild = studentProv.allStudents.first;
        await _loadChildData(_selectedChild!);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadChildData(Student child) async {
    final attProv = context.read<AttendanceProvider>();
    final feeProv = context.read<FeeProvider>();
    final perfProv = context.read<PerformanceProvider>();

    await Future.wait([
      attProv.loadForDate(DateTime.now()),
      feeProv.loadFees(studentId: child.id),
      perfProv.loadPerformances(studentId: child.id),
    ]);

    final allRecords = attProv.records
        .where((r) => r.studentId == child.id)
        .toList();
    final present = allRecords.where((r) => r.status == 'Present').length;
    _attendancePercent = allRecords.isEmpty
        ? 0
        : (present / allRecords.length) * 100;

    final childFees = feeProv.getStudentFees(child.id);
    _feesPaid = childFees.fold(0.0, (s, f) => s + f.paidAmount);
    _feesTotal = childFees.fold(0.0, (s, f) => s + f.monthlyFee);

    _performanceCount = perfProv.getStudentPerformances(child.id).length;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Portal')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, auth),
                if (auth.isParent && context.watch<StudentProvider>().allStudents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(
                      child: Text('No children linked to your account',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
                if (_selectedChild != null) ...[
                  const SizedBox(height: 16),
                  _buildChildSelector(context),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _portalCard(
                    context,
                    'View Attendance',
                    Icons.calendar_today,
                    Colors.blue,
                    '${_attendancePercent.toStringAsFixed(1)}% attendance',
                    () => _showAttendanceDetail(context),
                  ),
                  _portalCard(
                    context,
                    'Fee Status',
                    Icons.account_balance_wallet,
                    AppTheme.gold,
                    'Rs.${_feesPaid.toStringAsFixed(0)} paid of Rs.${_feesTotal.toStringAsFixed(0)}',
                    () => _showFeeDetail(context),
                  ),
                  _portalCard(
                    context,
                    'Performance',
                    Icons.stars,
                    Colors.teal,
                    '$_performanceCount assessments',
                    () => _showPerformanceDetail(context),
                  ),
                  _portalCard(
                    context,
                    'Download Report',
                    Icons.download,
                    AppTheme.primaryGreen,
                    'Download progress report',
                    () => _showReportOption(context),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.visibility,
                size: 48, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text(
              auth.user?['full_name'] ?? 'Parent Portal',
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
    );
  }

  Widget _buildChildSelector(BuildContext context) {
    final children = context.watch<StudentProvider>().allStudents;
    if (children.length <= 1) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          value: _selectedChild?.id,
          decoration: const InputDecoration(
            labelText: 'Select Child',
            prefixIcon: Icon(Icons.child_care),
            border: InputBorder.none,
          ),
          items: children.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(s.fullName),
          )).toList(),
          onChanged: (id) {
            final child = children.firstWhere((s) => s.id == id);
            setState(() => _selectedChild = child);
            _loadChildData(child);
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('Attendance', '${_attendancePercent.toStringAsFixed(0)}%',
            Colors.blue, Icons.calendar_today),
        _statCard('Fees Paid',
            'Rs.${_feesPaid.toStringAsFixed(0)}',
            AppTheme.gold, Icons.account_balance_wallet),
        _statCard('Assessments', '$_performanceCount',
            Colors.teal, Icons.stars),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portalCard(BuildContext context, String title, IconData icon,
      Color color, String subtitle, VoidCallback onTap) {
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
        onTap: onTap,
      ),
    );
  }

  void _showAttendanceDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_selectedChild!.fullName}\'s Attendance'),
        content: Text(
            'Today\'s attendance: ${_attendancePercent.toStringAsFixed(1)}%\n\n'
            'Check the Attendance tab for detailed daily records.'),
        actions: [TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'))],
      ),
    );
  }

  void _showFeeDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_selectedChild!.fullName}\'s Fees'),
        content: Text(
            'Paid: Rs.${_feesPaid.toStringAsFixed(0)}\n'
            'Total: Rs.${_feesTotal.toStringAsFixed(0)}\n\n'
            'Check the Fees tab for detailed records.'),
        actions: [TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'))],
      ),
    );
  }

  void _showPerformanceDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_selectedChild!.fullName}\'s Performance'),
        content: Text(
            'Total assessments: $_performanceCount\n\n'
            'Check the Performance tab for detailed ratings and charts.'),
        actions: [TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'))],
      ),
    );
  }

  void _showReportOption(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report download - Coming soon')),
    );
  }
}
