import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/student.dart';
import '../helpers/test_data.dart';

void main() {
  group('Student', () {
    test('fromMap creates instance correctly', () {
      final json = TestData.studentJson();
      final student = Student.fromMap(json);

      expect(student.id, '1');
      expect(student.fullName, 'Rahul Sharma');
      expect(student.fatherName, 'Raj Sharma');
      expect(student.mobileNumber, '9876543210');
      expect(student.whatsappNumber, '9876543210');
      expect(student.dateOfBirth, DateTime(2010, 5, 15));
      expect(student.age, 14);
      expect(student.gender, 'Male');
      expect(student.address, '123 Main St, Mumbai');
      expect(student.joinDate, DateTime(2024, 1, 10));
      expect(student.batch, 'Morning');
      expect(student.skillLevel, 'Intermediate');
      expect(student.monthlyFee, 1500.0);
      expect(student.emergencyContact, '9876543211');
      expect(student.bloodGroup, 'O+');
      expect(student.photoUrl, null);
      expect(student.isActive, true);
    });

    test('toMap produces correct map', () {
      final student = TestData.sampleStudent;
      final map = student.toMap();

      expect(map['id'], '1');
      expect(map['fullName'], 'Rahul Sharma');
      expect(map['monthlyFee'], 1500.0);
      expect(map['isActive'], true);
    });

    test('fromMap handles null optionals', () {
      final json = {
        'id': '3',
        'fullName': 'Test Student',
        'fatherName': 'Test Father',
        'mobileNumber': '1111111111',
        'whatsappNumber': null,
        'dateOfBirth': '2012-03-10T00:00:00.000',
        'age': 12,
        'gender': 'Female',
        'address': 'Test Address',
        'joinDate': '2024-06-01T00:00:00.000',
        'batch': 'Evening',
        'skillLevel': 'Beginner',
        'monthlyFee': 1000.0,
        'emergencyContact': '1111111112',
        'bloodGroup': 'A+',
        'photoUrl': null,
        'isActive': false,
      };
      final student = Student.fromMap(json);

      expect(student.whatsappNumber, null);
      expect(student.photoUrl, null);
      expect(student.isActive, false);
    });

    test('toMap and fromMap round trip', () {
      final original = TestData.sampleStudent;
      final map = original.toMap();
      final reconstructed = Student.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.fullName, original.fullName);
      expect(reconstructed.monthlyFee, original.monthlyFee);
      expect(reconstructed.isActive, original.isActive);
    });
  });
}
