import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/fee.dart';

void main() {
  group('Fee', () {
    test('fromMap creates instance correctly', () {
      final json = {
        'id': '1',
        'studentId': '1',
        'month': 'July 2026',
        'monthlyFee': 1500.0,
        'discount': 100.0,
        'paidAmount': 1400.0,
        'balance': 0,
        'dueDate': '2026-07-10T00:00:00.000',
        'paymentDate': '2026-07-05T00:00:00.000',
        'paymentMethod': 'UPI',
        'receiptNumber': 'RCP001',
        'status': 'Paid',
      };
      final fee = Fee.fromMap(json);

      expect(fee.id, '1');
      expect(fee.studentId, '1');
      expect(fee.month, 'July 2026');
      expect(fee.monthlyFee, 1500.0);
      expect(fee.discount, 100.0);
      expect(fee.paidAmount, 1400.0);
      expect(fee.balance, 0);
      expect(fee.dueDate, DateTime(2026, 7, 10));
      expect(fee.paymentDate, DateTime(2026, 7, 5));
      expect(fee.paymentMethod, 'UPI');
      expect(fee.receiptNumber, 'RCP001');
      expect(fee.status, 'Paid');
    });

    test('toMap produces correct map', () {
      final fee = Fee(
        id: '2',
        studentId: '2',
        month: 'August 2026',
        monthlyFee: 1200.0,
        discount: 0,
        paidAmount: 0,
        balance: 1200.0,
        dueDate: DateTime(2026, 8, 10),
        paymentMethod: '',
        status: 'Pending',
      );
      final map = fee.toMap();

      expect(map['id'], '2');
      expect(map['month'], 'August 2026');
      expect(map['balance'], 1200.0);
      expect(map['status'], 'Pending');
      expect(map['paymentDate'], null);
    });

    test('fromMap handles null paymentDate', () {
      final json = {
        'id': '3',
        'studentId': '3',
        'month': 'June 2026',
        'monthlyFee': 1000.0,
        'discount': 0,
        'paidAmount': 0,
        'balance': 1000.0,
        'dueDate': '2026-06-10T00:00:00.000',
        'paymentDate': null,
        'paymentMethod': '',
        'receiptNumber': null,
        'status': 'Pending',
      };
      final fee = Fee.fromMap(json);

      expect(fee.paymentDate, null);
      expect(fee.receiptNumber, null);
    });

    test('toMap and fromMap round trip', () {
      final original = Fee(
        id: '4',
        studentId: '1',
        month: 'September 2026',
        monthlyFee: 1500.0,
        discount: 200.0,
        paidAmount: 1300.0,
        balance: 0,
        dueDate: DateTime(2026, 9, 10),
        paymentDate: DateTime(2026, 9, 5),
        paymentMethod: 'Bank Transfer',
        receiptNumber: 'RCP004',
        status: 'Paid',
      );
      final map = original.toMap();
      final reconstructed = Fee.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.monthlyFee, original.monthlyFee);
      expect(reconstructed.paidAmount, original.paidAmount);
      expect(reconstructed.status, original.status);
    });
  });
}
