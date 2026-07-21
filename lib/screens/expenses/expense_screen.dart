import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Other';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      category: _category,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    final success = await context.read<ExpenseProvider>().addExpense(expense);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added'),
            backgroundColor: Colors.green),
      );
      _titleCtrl.clear();
      _amountCtrl.clear();
      _notesCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Expense',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Title *',
                            prefixIcon: Icon(Icons.title)),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Amount (₹) *',
                                prefixIcon: Icon(Icons.money)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              return null;
                            })),
                        const SizedBox(width: 12),
                        Expanded(child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category)),
                            items: AppConstants.expenseCategories.map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v!))),
                      ]),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: 'Notes',
                            prefixIcon: Icon(Icons.notes)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Add Expense'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ExpenseProvider>(
              builder: (context, ep, _) {
                if (ep.expenses.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Expense History',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(
                        'Total: ₹${ep.totalExpenses.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppTheme.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _filterChip('All', ep.filter == 'All', () {
                          context.read<ExpenseProvider>().filter = 'All';
                        }),
                        ...AppConstants.expenseCategories.map((c) =>
                            _filterChip(c, ep.filter == c, () {
                              context.read<ExpenseProvider>().filter = c;
                            })),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    ...ep.expenses.map((e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt,
                                  color: AppTheme.red),
                            ),
                            title: Text(e.title),
                            subtitle: Text(
                                '${e.category} | ${e.date.toLocal().toString().split(' ')[0]}'),
                            trailing: Text(
                              '₹${e.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.red,
                              ),
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        checkmarkColor: AppTheme.primaryGreen,
      ),
    );
  }
}
