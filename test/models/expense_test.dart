import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/expense.dart';

void main() {
  group('Expense', () {
    test('fromMap creates instance correctly', () {
      final json = {
        'id': '1',
        'title': 'Cricket Balls',
        'category': 'Equipment',
        'amount': 2500.0,
        'date': '2026-07-18T00:00:00.000',
        'notes': 'Box of 12',
      };
      final expense = Expense.fromMap(json);

      expect(expense.id, '1');
      expect(expense.title, 'Cricket Balls');
      expect(expense.category, 'Equipment');
      expect(expense.amount, 2500.0);
      expect(expense.notes, 'Box of 12');
    });

    test('toMap produces correct map', () {
      final expense = Expense(
        id: '2',
        title: 'Net Repair',
        category: 'Maintenance',
        amount: 3000.0,
        date: DateTime(2026, 7, 16),
        notes: null,
      );
      final map = expense.toMap();

      expect(map['id'], '2');
      expect(map['category'], 'Maintenance');
      expect(map['amount'], 3000.0);
      expect(map['notes'], null);
    });

    test('fromMap handles null notes', () {
      final json = {
        'id': '3',
        'title': 'Water Bottles',
        'category': 'Other',
        'amount': 500.0,
        'date': '2026-07-14T00:00:00.000',
        'notes': null,
      };
      final expense = Expense.fromMap(json);
      expect(expense.notes, null);
    });

    test('toMap and fromMap round trip', () {
      final original = Expense(
        id: '4',
        title: 'Coaching Kit',
        category: 'Equipment',
        amount: 5000.0,
        date: DateTime(2026, 7, 22),
        notes: 'New kits for juniors',
      );
      final map = original.toMap();
      final reconstructed = Expense.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.amount, original.amount);
      expect(reconstructed.notes, original.notes);
    });
  });
}
