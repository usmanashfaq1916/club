class Attendance {
  final String id;
  final String studentId;
  final DateTime date;
  final String status;

  Attendance({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'date': date.toIso8601String(),
    'status': status,
  };

  factory Attendance.fromMap(Map<String, dynamic> map) => Attendance(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    date: DateTime.parse(map['date']),
    status: map['status'] ?? '',
  );
}
