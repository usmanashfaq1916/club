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
    'id': id,
    'studentId': studentId,
    'month': month,
    'monthlyFee': monthlyFee,
    'discount': discount,
    'paidAmount': paidAmount,
    'balance': balance,
    'dueDate': dueDate.toIso8601String(),
    'paymentDate': paymentDate?.toIso8601String(),
    'paymentMethod': paymentMethod,
    'receiptNumber': receiptNumber,
    'status': status,
  };

  factory Fee.fromMap(Map<String, dynamic> map) => Fee(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    month: map['month'] ?? '',
    monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
    discount: (map['discount'] ?? 0).toDouble(),
    paidAmount: (map['paidAmount'] ?? 0).toDouble(),
    balance: (map['balance'] ?? 0).toDouble(),
    dueDate: DateTime.parse(map['dueDate']),
    paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate']) : null,
    paymentMethod: map['paymentMethod'] ?? '',
    receiptNumber: map['receiptNumber'],
    status: map['status'] ?? 'Pending',
  );
}
