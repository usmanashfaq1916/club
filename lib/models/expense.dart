class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;
  final String status;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'amount': amount.toString(),
    'date': date.toIso8601String().split('T')[0],
    'notes': notes,
    'status': status,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id']?.toString() ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    date: DateTime.parse(map['date']),
    notes: map['notes'],
    status: map['status'] ?? 'Pending',
  );
}
