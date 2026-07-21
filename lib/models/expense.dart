class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    date: DateTime.parse(map['date']),
    notes: map['notes'],
  );
}
