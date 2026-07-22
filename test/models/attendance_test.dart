import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/attendance.dart';

void main() {
  group('Attendance', () {
    test('fromMap creates instance correctly', () {
      final json = {
        'id': '1',
        'studentId': '5',
        'date': '2026-07-22T00:00:00.000',
        'status': 'Present',
      };
      final att = Attendance.fromMap(json);

      expect(att.id, '1');
      expect(att.studentId, '5');
      expect(att.date, DateTime(2026, 7, 22));
      expect(att.status, 'Present');
    });

    test('toMap produces correct map', () {
      final att = Attendance(
        id: '2',
        studentId: '3',
        date: DateTime(2026, 7, 21),
        status: 'Absent',
      );
      final map = att.toMap();

      expect(map['id'], '2');
      expect(map['studentId'], '3');
      expect(map['status'], 'Absent');
    });

    test('fromMap handles empty values', () {
      final json = {
        'id': '',
        'studentId': '',
        'date': '2026-01-01T00:00:00.000',
        'status': '',
      };
      final att = Attendance.fromMap(json);

      expect(att.id, '');
      expect(att.studentId, '');
      expect(att.status, '');
    });

    test('toMap and fromMap round trip', () {
      final original = Attendance(
        id: '10',
        studentId: '7',
        date: DateTime(2026, 7, 15),
        status: 'Leave',
      );
      final map = original.toMap();
      final reconstructed = Attendance.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.studentId, original.studentId);
      expect(reconstructed.status, original.status);
    });
  });
}
