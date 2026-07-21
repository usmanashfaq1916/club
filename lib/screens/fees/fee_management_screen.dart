import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/theme.dart';
import 'fee_detail_screen.dart';
import 'add_fee_payment_screen.dart';

class FeeManagementScreen extends StatefulWidget {
  final String? initialStudentId;

  const FeeManagementScreen({super.key, this.initialStudentId});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<FeeProvider>().loadFees(
        studentId: widget.initialStudentId);
    await context.read<StudentProvider>().loadStudents();
    if (mounted) setState(() => _initialLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Management')),
      body: Consumer2<FeeProvider, StudentProvider>(
        builder: (context, feeProv, studentProv, _) {
          if (_initialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final fees = widget.initialStudentId != null
              ? feeProv.fees
                  .where((f) => f.studentId == widget.initialStudentId)
                  .toList()
              : feeProv.fees;

          if (fees.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No fee records found',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AddFeePaymentScreen()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Fee Record'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard('Collected',
                          '₹${feeProv.totalCollected.toStringAsFixed(0)}', Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard('Pending',
                          '₹${feeProv.pendingAmount.toStringAsFixed(0)}', AppTheme.red),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: fees.length,
                    itemBuilder: (context, index) {
                      final fee = fees[index];
                      final student = studentProv.getStudentById(fee.studentId);
                      Color statusColor;
                      switch (fee.status) {
                        case 'Paid': statusColor = Colors.green; break;
                        case 'Partial': statusColor = AppTheme.orange; break;
                        default: statusColor = AppTheme.red;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => FeeDetailScreen(
                                    fee: fee,
                                    studentName: student?.fullName ?? 'Unknown')));
                          },
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            child: Text(
                              student?.fullName.isNotEmpty == true
                                  ? student!.fullName[0].toUpperCase() : '?',
                              style: TextStyle(color: statusColor)),
                          ),
                          title: Text(student?.fullName ?? 'Unknown Student',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              '${fee.month} | Due: ₹${fee.monthlyFee.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey[600])),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(fee.status,
                                style: TextStyle(color: statusColor,
                                    fontSize: 11, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddFeePaymentScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
