import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/api_client.dart';
import '../../config/theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportCard(
            context,
            'Student Report',
            Icons.people,
            AppTheme.primaryGreen,
            'Generate complete list of all students',
            () => _generateStudentReport(context),
          ),
          _reportCard(
            context,
            'Attendance Report',
            Icons.calendar_today,
            Colors.blue,
            'Monthly attendance summary',
            () => _generateAttendanceReport(context),
          ),
          _reportCard(
            context,
            'Fee Defaulter Report',
            Icons.warning,
            AppTheme.red,
            'List of students with pending fees',
            () => _generateFeeDefaulterReport(context),
          ),
          _reportCard(
            context,
            'Monthly Financial Report',
            Icons.account_balance,
            AppTheme.gold,
            'Income, expenses, and profit summary',
            () => _generateFinancialReport(context),
          ),
          _reportCard(
            context,
            'Performance Report',
            Icons.stars,
            Colors.teal,
            'Student performance ratings summary',
            () => _generatePerformanceReport(context),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.download),
      ),
    );
  }

  Future<void> _generateStudentReport(BuildContext context) async {
    try {
      final data = await ApiClient.get('/students/');
      final results = data['results'] ?? data ?? [];
      final students = results as List;

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text('Young Fighters Academy - Student Report',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['ID', 'Name', 'Father', 'Mobile', 'Batch', 'Fee'],
              data: students.map((s) {
                final d = s as Map<String, dynamic>;
                return [
                  d['id'].toString().substring(0, 8),
                  d['full_name'] ?? '',
                  d['father_name'] ?? '',
                  d['mobile_number'] ?? '',
                  d['batch'] ?? '',
                  '\u20b9${(d['monthly_fee'] ?? 0).toStringAsFixed(0)}',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await _sharePdf(context, pdf, 'student_report');
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _generateAttendanceReport(BuildContext context) async {
    try {
      final data = await ApiClient.get('/attendance/');
      final results = data['results'] ?? data ?? [];
      final attend = results as List;

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text('Young Fighters Academy - Attendance Report',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Student ID', 'Date', 'Status'],
              data: attend.map((a) {
                final d = a as Map<String, dynamic>;
                return [
                  d['student'].toString().substring(0, 8),
                  (d['date'] ?? '').toString().substring(0, 10),
                  d['status'] ?? '',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await _sharePdf(context, pdf, 'attendance_report');
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _generateFeeDefaulterReport(BuildContext context) async {
    try {
      final data = await ApiClient.get('/fees/', queryParams: {'status': 'Pending'});
      final results = data['results'] ?? data ?? [];
      final fees = results as List;

      if (fees.isEmpty) {
        _showError(context, 'No defaulters found');
        return;
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text('Young Fighters Academy - Fee Defaulters',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Student ID', 'Month', 'Amount', 'Due Date'],
              data: fees.map((f) {
                final d = f as Map<String, dynamic>;
                return [
                  d['student'].toString().substring(0, 8),
                  d['month'] ?? '',
                  '\u20b9${(d['monthly_fee'] ?? 0).toStringAsFixed(0)}',
                  (d['due_date'] ?? '').toString().substring(0, 10),
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await _sharePdf(context, pdf, 'fee_defaulters');
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _generateFinancialReport(BuildContext context) async {
    try {
      final feesData = await ApiClient.get('/fees/');
      final feesResults = feesData['results'] ?? feesData ?? [];
      final feesList = feesResults as List;

      final expData = await ApiClient.get('/expenses/');
      final expResults = expData['results'] ?? expData ?? [];
      final expensesList = expResults as List;

      double totalIncome = 0;
      double totalExpenses = 0;
      for (final f in feesList) {
        totalIncome += ((f as Map)['paid_amount'] ?? 0).toDouble();
      }
      for (final e in expensesList) {
        totalExpenses += ((e as Map)['amount'] ?? 0).toDouble();
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Financial Report',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Income',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text('\u20b9${totalIncome.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.green,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Expenses',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text('\u20b9${totalExpenses.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.red,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Net Profit',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\u20b9${(totalIncome - totalExpenses).toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: totalIncome >= totalExpenses
                            ? PdfColors.green
                            : PdfColors.red,
                      )),
                ],
              ),
            ],
          ),
        ),
      );

      await _sharePdf(context, pdf, 'financial_report');
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _generatePerformanceReport(BuildContext context) async {
    try {
      final data = await ApiClient.get('/performances/');
      final results = data['results'] ?? data ?? [];
      final perf = results as List;

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text('Performance Report',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: [
                'Student',
                'Bat',
                'Bowl',
                'Field',
                'Fit',
                'Disc',
                'Overall'
              ],
              data: perf.map((p) {
                final d = p as Map<String, dynamic>;
                return [
                  d['student'].toString().substring(0, 8),
                  '${d['batting_rating'] ?? 0}',
                  '${d['bowling_rating'] ?? 0}',
                  '${d['fielding_rating'] ?? 0}',
                  '${d['fitness_rating'] ?? 0}',
                  '${d['discipline_rating'] ?? 0}',
                  '${(d['overall_rating'] ?? 0).toStringAsFixed(1)}',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await _sharePdf(context, pdf, 'performance_report');
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _sharePdf(
      BuildContext context, pw.Document pdf, String fileName) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: fileName);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.red),
    );
  }
}
