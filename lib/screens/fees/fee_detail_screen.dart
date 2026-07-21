import 'package:flutter/material.dart';
import '../../models/fee.dart';
import '../../config/theme.dart';

class FeeDetailScreen extends StatelessWidget {
  final Fee fee;
  final String studentName;

  const FeeDetailScreen({
    super.key,
    required this.fee,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color statusColor;
    switch (fee.status) {
      case 'Paid':
        statusColor = Colors.green;
        break;
      case 'Partial':
        statusColor = AppTheme.orange;
        break;
      default:
        statusColor = AppTheme.red;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 48, color: AppTheme.primaryGreen),
                    const SizedBox(height: 12),
                    Text(studentName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    const SizedBox(height: 8),
                    Text(fee.month,
                        style: TextStyle(color: Colors.grey[600])),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(fee.status,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailRow('Monthly Fee',
                        '₹${fee.monthlyFee.toStringAsFixed(2)}'),
                    const Divider(),
                    _detailRow('Discount',
                        '₹${fee.discount.toStringAsFixed(2)}'),
                    const Divider(),
                    _detailRow('Paid Amount',
                        '₹${fee.paidAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    _detailRow('Balance',
                        '₹${fee.balance.toStringAsFixed(2)}',
                        valueColor: fee.balance > 0
                            ? AppTheme.red
                            : Colors.green),
                    const Divider(),
                    _detailRow('Due Date',
                        fee.dueDate.toLocal().toString().split(' ')[0]),
                    if (fee.paymentDate != null) ...[
                      const Divider(),
                      _detailRow('Payment Date',
                          fee.paymentDate!.toLocal().toString().split(' ')[0]),
                    ],
                    if (fee.paymentMethod.isNotEmpty) ...[
                      const Divider(),
                      _detailRow('Payment Method', fee.paymentMethod),
                    ],
                    if (fee.receiptNumber != null) ...[
                      const Divider(),
                      _detailRow('Receipt Number', fee.receiptNumber!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}
