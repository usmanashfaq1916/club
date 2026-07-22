import 'package:young_fighters_academy/models/student.dart';
import 'package:young_fighters_academy/models/attendance.dart';
import 'package:young_fighters_academy/models/fee.dart';
import 'package:young_fighters_academy/models/performance.dart';
import 'package:young_fighters_academy/models/match_record.dart';
import 'package:young_fighters_academy/models/expense.dart';

class TestData {
  static final sampleStudent = Student(
    id: '1',
    fullName: 'Rahul Sharma',
    fatherName: 'Raj Sharma',
    mobileNumber: '9876543210',
    whatsappNumber: '9876543210',
    dateOfBirth: DateTime(2010, 5, 15),
    age: 14,
    gender: 'Male',
    address: '123 Main St, Mumbai',
    joinDate: DateTime(2024, 1, 10),
    batch: 'Morning',
    skillLevel: 'Intermediate',
    monthlyFee: 1500.0,
    emergencyContact: '9876543211',
    bloodGroup: 'O+',
    photoUrl: null,
    isActive: true,
  );

  static final sampleStudentList = [
    sampleStudent,
    Student(
      id: '2',
      fullName: 'Virat Singh',
      fatherName: 'Ravi Singh',
      mobileNumber: '9988776655',
      dateOfBirth: DateTime(2011, 8, 20),
      age: 13,
      gender: 'Male',
      address: '456 Park Ave, Delhi',
      joinDate: DateTime(2024, 2, 15),
      batch: 'Evening',
      skillLevel: 'Beginner',
      monthlyFee: 1200.0,
      emergencyContact: '9988776654',
      bloodGroup: 'B+',
      isActive: true,
    ),
  ];

  static final sampleAttendance = Attendance(
    id: '1',
    studentId: '1',
    date: DateTime(2026, 7, 22),
    status: 'Present',
  );

  static final sampleFee = Fee(
    id: '1',
    studentId: '1',
    month: 'July 2026',
    monthlyFee: 1500.0,
    discount: 0,
    paidAmount: 1500.0,
    balance: 0,
    dueDate: DateTime(2026, 7, 10),
    paymentDate: DateTime(2026, 7, 5),
    paymentMethod: 'Cash',
    receiptNumber: 'RCP001',
    status: 'Paid',
  );

  static final samplePerformance = Performance(
    id: '1',
    studentId: '1',
    date: DateTime(2026, 7, 20),
    battingRating: 8,
    bowlingRating: 7,
    fieldingRating: 9,
    fitnessRating: 8,
    disciplineRating: 9,
    coachRemarks: 'Good improvement',
    overallRating: 8.2,
  );

  static final sampleMatchRecord = MatchRecord(
    id: '1',
    matchDate: DateTime(2026, 7, 15),
    opponent: 'Mumbai Academy',
    runs: 85,
    wickets: 2,
    catches: 1,
    strikeRate: 125.5,
    economy: 4.5,
    result: 'Win',
    isManOfTheMatch: true,
  );

  static final sampleExpense = Expense(
    id: '1',
    title: 'Cricket Balls',
    category: 'Equipment',
    amount: 2500.0,
    date: DateTime(2026, 7, 18),
    notes: 'Box of 12',
  );

  static Map<String, dynamic> studentJson() => {
    'id': '1',
    'fullName': 'Rahul Sharma',
    'fatherName': 'Raj Sharma',
    'mobileNumber': '9876543210',
    'whatsappNumber': '9876543210',
    'dateOfBirth': '2010-05-15T00:00:00.000',
    'age': 14,
    'gender': 'Male',
    'address': '123 Main St, Mumbai',
    'joinDate': '2024-01-10T00:00:00.000',
    'batch': 'Morning',
    'skillLevel': 'Intermediate',
    'monthlyFee': 1500.0,
    'emergencyContact': '9876543211',
    'bloodGroup': 'O+',
    'photoUrl': null,
    'isActive': true,
  };

  static List<Map<String, dynamic>> studentListJson() => [
    studentJson(),
    {
      'id': '2',
      'fullName': 'Virat Singh',
      'fatherName': 'Ravi Singh',
      'mobileNumber': '9988776655',
      'whatsappNumber': null,
      'dateOfBirth': '2011-08-20T00:00:00.000',
      'age': 13,
      'gender': 'Male',
      'address': '456 Park Ave, Delhi',
      'joinDate': '2024-02-15T00:00:00.000',
      'batch': 'Evening',
      'skillLevel': 'Beginner',
      'monthlyFee': 1200.0,
      'emergencyContact': '9988776654',
      'bloodGroup': 'B+',
      'photoUrl': null,
      'isActive': true,
    },
  ];

  static Map<String, dynamic> dashboardJson() => {
    'total_students': 25,
    'active_students': 22,
    'present_today': 18,
    'total_today': 20,
    'fee_collected': 45000.0,
    'pending_fees': 12000.0,
    'monthly_income': 35000.0,
    'monthly_expenses': 15000.0,
    'net_profit': 20000.0,
    'recent_activities': [
      {'type': 'student_added', 'description': 'New student joined', 'timestamp': '2026-07-22T10:00:00Z'},
    ],
    'fee_due_list': [
      {'student_name': 'Rahul Sharma', 'amount': 1500.0, 'due_date': '2026-07-10'},
    ],
  };
}
