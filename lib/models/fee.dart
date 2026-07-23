class Fee {
  final String id;
  final String studentId;
  final String month;
  final double monthlyFee;
  final double discount;
  final double paidAmount;
  final double balance;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String paymentMethod;
  final String? receiptNumber;
  final String status;

  Fee({
    required this.id,
    required this.studentId,
    required this.month,
    required this.monthlyFee,
    this.discount = 0,
    this.paidAmount = 0,
    this.balance = 0,
    required this.dueDate,
    this.paymentDate,
    this.paymentMethod = '',
    this.receiptNumber,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() => {
    'student': studentId,
    'month': month,
    'monthly_fee': monthlyFee.toString(),
    'discount': discount.toString(),
    'paid_amount': paidAmount.toString(),
    'balance': balance.toString(),
    'due_date': dueDate.toIso8601String().split('T')[0],
    'payment_date': paymentDate?.toIso8601String().split('T')[0],
    'payment_method': paymentMethod,
    'receipt_number': receiptNumber,
    'status': status,
  };

  factory Fee.fromMap(Map<String, dynamic> map) => Fee(
    id: map['id']?.toString() ?? '',
    studentId: map['student']?.toString() ?? '',
    month: map['month'] ?? '',
    monthlyFee: (map['monthly_fee'] ?? 0).toDouble(),
    discount: (map['discount'] ?? 0).toDouble(),
    paidAmount: (map['paid_amount'] ?? 0).toDouble(),
    balance: (map['balance'] ?? 0).toDouble(),
    dueDate: DateTime.parse(map['due_date']),
    paymentDate: map['payment_date'] != null ? DateTime.parse(map['payment_date']) : null,
    paymentMethod: map['payment_method'] ?? '',
    receiptNumber: map['receipt_number'],
    status: map['status'] ?? 'Pending',
  );
}
