import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceMap = {};
  final Map<String, Student> _studentsMap = {};
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final studentProv = context.read<StudentProvider>();
    await studentProv.loadStudents();
    for (final s in studentProv.allStudents) {
      _studentsMap[s.id] = s;
    }
    await context.read<AttendanceProvider>().loadForDate(_selectedDate);
    final records = context.read<AttendanceProvider>().records;
    _attendanceMap.clear();
    for (final r in records) {
      _attendanceMap[r.studentId] = r.status;
    }
    if (mounted) {
      setState(() => _initialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAttendance),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Column(
                children: [
                  Text(_selectedDate.day.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
                  Text(_getMonthYear(), style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _loadData();
  }

  String _getMonthYear() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  Widget _buildStudentList() {
    if (_initialLoading) return const Center(child: CircularProgressIndicator());

    return Consumer<StudentProvider>(
      builder: (context, sp, _) {
        final students = sp.allStudents;
        if (students.isEmpty) {
          return Center(child: Text('No students found',
              style: TextStyle(color: Colors.grey[600])));
        }
        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final currentStatus = _attendanceMap[student.id] ?? 'Present';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    child: Text(student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : '?',
                        style: const TextStyle(color: AppTheme.primaryGreen)),
                  ),
                  title: Text(student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(student.batch),
                  trailing: _buildStatusChips(student.id, currentStatus),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChips(String studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppConstants.attendanceStatus.map((status) {
        final isSelected = currentStatus == status;
        Color color;
        switch (status) {
          case 'Present': color = Colors.green; break;
          case 'Absent': color = AppTheme.red; break;
          case 'Leave': color = AppTheme.orange; break;
          default: color = Colors.grey;
        }
        return GestureDetector(
          onTap: () => setState(() => _attendanceMap[studentId] = status),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? color : Colors.grey[400]!),
            ),
            child: Text(status[0],
                style: TextStyle(fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : Colors.grey[600])),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveAttendance() async {
    final provider = context.read<AttendanceProvider>();
    final records = _attendanceMap.entries.map((e) => {
      'studentId': e.key,
      'date': _selectedDate,
      'status': e.value,
    }).toList();
    final success = await provider.markBulkAttendance(records);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Attendance saved' : 'Failed to save'),
        backgroundColor: success ? Colors.green : AppTheme.red,
      ),
    );
  }
}
