import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/fee.dart';
import '../../providers/fee_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class AddFeePaymentScreen extends StatefulWidget {
  const AddFeePaymentScreen({super.key});

  @override
  State<AddFeePaymentScreen> createState() => _AddFeePaymentScreenState();
}

class _AddFeePaymentScreenState extends State<AddFeePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStudentId;
  late TextEditingController _amountCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _paidCtrl;

  String _paymentMethod = 'Cash';
  DateTime _dueDate = DateTime.now();
  String _month = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _discountCtrl = TextEditingController(text: '0');
    _paidCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _discountCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student'),
            backgroundColor: AppTheme.red),
      );
      return;
    }

    final monthlyFee = double.tryParse(_amountCtrl.text) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;
    final balance = monthlyFee - discount - paid;

    final fee = Fee(
      id: const Uuid().v4(),
      studentId: _selectedStudentId!,
      month: _month,
      monthlyFee: monthlyFee,
      discount: discount,
      paidAmount: paid,
      balance: balance > 0 ? balance : 0,
      dueDate: _dueDate,
      paymentDate: paid > 0 ? DateTime.now() : null,
      paymentMethod: _paymentMethod,
      receiptNumber: 'RCP-${DateTime.now().millisecondsSinceEpoch}',
      status: paid >= monthlyFee - discount ? 'Paid' : (paid > 0 ? 'Partial' : 'Pending'),
    );

    final success = await context.read<FeeProvider>().addFee(fee);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee record added'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add fee record'),
            backgroundColor: AppTheme.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fee Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<StudentProvider>(
                builder: (context, sp, _) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Select Student *',
                        prefixIcon: Icon(Icons.person)),
                    items: sp.allStudents.map((s) {
                      return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.fullName));
                    }).toList(),
                    onChanged: (v) {
                      setState(() => _selectedStudentId = v);
                      if (v != null) {
                        final student = sp.getStudentById(v);
                        if (student != null) {
                          _amountCtrl.text =
                              student.monthlyFee.toString();
                        }
                      }
                    },
                    validator: (v) =>
                        v == null ? 'Select a student' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Monthly Fee (Rs.) *',
                    prefixIcon: Icon(Icons.money)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Discount (Rs.)',
                          prefixIcon: Icon(Icons.discount)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _paidCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Paid Amount (Rs.) *',
                          prefixIcon: Icon(Icons.payments)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.account_balance)),
                items: AppConstants.feeMethods
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Month',
                    prefixIcon: Icon(Icons.calendar_month)),
                controller: TextEditingController(text: _month),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Fee Record',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
