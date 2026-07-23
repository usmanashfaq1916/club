import '../models/student.dart';
import '../models/attendance.dart';
import '../models/fee.dart';
import '../models/performance.dart';
import '../models/match_record.dart';
import '../models/expense.dart';

class MockDataService {
  static bool _initialized = false;
  static List<Student> _students = [];
  static List<Attendance> _attendance = [];
  static List<Fee> _fees = [];
  static List<Performance> _performances = [];
  static List<MatchRecord> _matches = [];
  static List<Expense> _expenses = [];

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _generateStudents();
    _generateAttendance();
    _generateFees();
    _generatePerformances();
    _generateMatches();
    _generateExpenses();
  }

  static List<Student> get students {
    _ensureInitialized();
    return _students;
  }

  static List<Attendance> get attendance {
    _ensureInitialized();
    return _attendance;
  }

  static List<Fee> get fees {
    _ensureInitialized();
    return _fees;
  }

  static List<Performance> get performances {
    _ensureInitialized();
    return _performances;
  }

  static List<MatchRecord> get matches {
    _ensureInitialized();
    return _matches;
  }

  static List<Expense> get expenses {
    _ensureInitialized();
    return _expenses;
  }

  static List<Map<String, dynamic>> get recentActivities {
    _ensureInitialized();
    return [
      {'action': 'New Student Registered', 'details': 'Ahmed Ali joined Morning Batch'},
      {'action': 'Fee Payment Received', 'details': 'Rs.2,500 received from Bilal Hassan'},
      {'action': 'Match Scheduled', 'details': 'vs United Cricket Club on 25 Jul'},
      {'action': 'Attendance Marked', 'details': '15 Present, 2 Absent today'},
      {'action': 'Performance Updated', 'details': 'Rating updated for 5 students'},
    ];
  }

  static List<Map<String, dynamic>> get feeDueList {
    _ensureInitialized();
    return _fees
        .where((f) => f.status == 'Pending')
        .map((f) => {
              'studentId': f.studentId,
              'monthlyFee': f.monthlyFee,
              'month': f.month,
              'dueDate': f.dueDate.toIso8601String(),
            })
        .toList();
  }

  static double get totalFeeCollected {
    _ensureInitialized();
    return _fees.fold(0.0, (sum, f) => sum + f.paidAmount);
  }

  static double get totalPendingFees {
    _ensureInitialized();
    return _fees
        .where((f) => f.status == 'Pending')
        .fold(0.0, (sum, f) => sum + f.balance);
  }

  static double get totalExpensesAmount {
    _ensureInitialized();
    return _expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  static void reset() {
    _initialized = false;
  }

  static void _generateStudents() {
    final now = DateTime.now();
    _students = [
      Student(
        id: 'STU001', fullName: 'Ahmed Ali Khan', fatherName: 'Mohammad Ali Khan',
        mobileNumber: '0300-1234567', whatsappNumber: '0300-1234567',
        dateOfBirth: DateTime(2012, 3, 15), age: 14, gender: 'Male',
        address: 'House 12, Block A, Gulshan-e-Maymar, Karachi',
        joinDate: DateTime(now.year, 1, 10), batch: 'Morning',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0301-9876543', bloodGroup: 'A+',
        playingRole: 'Batsman', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU002', fullName: 'Bilal Hassan', fatherName: 'Farooq Hassan',
        mobileNumber: '0301-2345678', whatsappNumber: null,
        dateOfBirth: DateTime(2011, 7, 22), age: 15, gender: 'Male',
        address: 'Flat 5, Block C, DHA Phase 6, Karachi',
        joinDate: DateTime(now.year, 2, 5), batch: 'Morning',
        skillLevel: 'Advanced', monthlyFee: 3000,
        emergencyContact: '0302-8765432', bloodGroup: 'B+',
        playingRole: 'Bowler', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU003', fullName: 'Usman Tariq', fatherName: 'Tariq Mehmood',
        mobileNumber: '0302-3456789', whatsappNumber: '0302-3456789',
        dateOfBirth: DateTime(2013, 11, 5), age: 12, gender: 'Male',
        address: 'House 3, Street 7, Garden Town, Lahore',
        joinDate: DateTime(now.year, 1, 15), batch: 'Morning',
        skillLevel: 'Beginner', monthlyFee: 2000,
        emergencyContact: '0303-7654321', bloodGroup: 'AB+',
        playingRole: 'All-rounder', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU004', fullName: 'Zainab Fatima', fatherName: 'Hussain Ahmed',
        mobileNumber: '0303-4567890', whatsappNumber: '0303-4567890',
        dateOfBirth: DateTime(2012, 5, 18), age: 14, gender: 'Female',
        address: 'House 8, Sector F, Model Town, Lahore',
        joinDate: DateTime(now.year, 3, 1), batch: 'Evening',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0304-6543210', bloodGroup: 'O+',
        playingRole: 'Batsman', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU005', fullName: 'Hamza Akram', fatherName: 'Akram Saeed',
        mobileNumber: '0304-5678901', whatsappNumber: null,
        dateOfBirth: DateTime(2011, 1, 30), age: 15, gender: 'Male',
        address: 'House 15, Block B, Satellite Town, Rawalpindi',
        joinDate: DateTime(now.year, 1, 20), batch: 'Morning',
        skillLevel: 'Advanced', monthlyFee: 3000,
        emergencyContact: '0305-5432109', bloodGroup: 'A-',
        playingRole: 'Wicket Keeper', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU006', fullName: 'Sana Mirza', fatherName: 'Mirza Baig',
        mobileNumber: '0305-6789012', whatsappNumber: '0305-6789012',
        dateOfBirth: DateTime(2013, 9, 12), age: 12, gender: 'Female',
        address: 'House 21, Street 3, F-7/4, Islamabad',
        joinDate: DateTime(now.year, 2, 10), batch: 'Evening',
        skillLevel: 'Beginner', monthlyFee: 2000,
        emergencyContact: '0306-4321098', bloodGroup: 'B-',
        playingRole: 'Bowler', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU007', fullName: 'Abdullah Raza', fatherName: 'Raza Haider',
        mobileNumber: '0306-7890123', whatsappNumber: '0306-7890123',
        dateOfBirth: DateTime(2010, 4, 8), age: 16, gender: 'Male',
        address: 'House 10, Block D, PECHS, Karachi',
        joinDate: DateTime(now.year - 1, 9, 5), batch: 'Morning',
        skillLevel: 'Professional', monthlyFee: 4000,
        emergencyContact: '0307-3210987', bloodGroup: 'O+',
        playingRole: 'Batsman', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU008', fullName: 'Fatima Noor', fatherName: 'Noor Ahmed',
        mobileNumber: '0307-8901234', whatsappNumber: null,
        dateOfBirth: DateTime(2012, 12, 25), age: 13, gender: 'Female',
        address: 'House 5, Street 2, Gulberg III, Lahore',
        joinDate: DateTime(now.year, 3, 15), batch: 'Evening',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0308-2109876', bloodGroup: 'AB-',
        playingRole: 'All-rounder', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU009', fullName: 'Rohan Pervaiz', fatherName: 'Pervaiz Iqbal',
        mobileNumber: '0308-9012345', whatsappNumber: '0308-9012345',
        dateOfBirth: DateTime(2011, 8, 14), age: 15, gender: 'Male',
        address: 'House 18, Sector G, North Nazimabad, Karachi',
        joinDate: DateTime(now.year, 1, 5), batch: 'Morning',
        skillLevel: 'Advanced', monthlyFee: 3000,
        emergencyContact: '0309-1098765', bloodGroup: 'A+',
        playingRole: 'Bowler', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU010', fullName: 'Ayesha Kamal', fatherName: 'Kamal Hussain',
        mobileNumber: '0309-0123456', whatsappNumber: null,
        dateOfBirth: DateTime(2013, 6, 3), age: 13, gender: 'Female',
        address: 'House 7, Block E, University Town, Peshawar',
        joinDate: DateTime(now.year, 2, 20), batch: 'Evening',
        skillLevel: 'Beginner', monthlyFee: 2000,
        emergencyContact: '0310-9876543', bloodGroup: 'O-',
        playingRole: 'Batsman', isActive: false, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU011', fullName: 'Zubair Ahmed', fatherName: 'Ahmed Nawaz',
        mobileNumber: '0311-1239876', whatsappNumber: '0311-1239876',
        dateOfBirth: DateTime(2012, 2, 28), age: 14, gender: 'Male',
        address: 'House 14, Block C, Gulshan-e-Jamal, Karachi',
        joinDate: DateTime(now.year, 1, 12), batch: 'Morning',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0312-7891234', bloodGroup: 'B+',
        playingRole: 'Wicket Keeper', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU012', fullName: 'Mahnoor Sheikh', fatherName: 'Sheikh Rashid',
        mobileNumber: '0312-2345678', whatsappNumber: '0312-2345678',
        dateOfBirth: DateTime(2014, 10, 19), age: 11, gender: 'Female',
        address: 'House 2, Street 5, Phase 8, DHA, Karachi',
        joinDate: DateTime(now.year, 3, 5), batch: 'Evening',
        skillLevel: 'Beginner', monthlyFee: 2000,
        emergencyContact: '0313-6782345', bloodGroup: 'A+',
        playingRole: 'Bowler', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU013', fullName: 'Salman Farooqi', fatherName: 'Farooqi Ahmed',
        mobileNumber: '0313-3456789', whatsappNumber: null,
        dateOfBirth: DateTime(2010, 11, 7), age: 15, gender: 'Male',
        address: 'House 9, Block A, Gulshan-e-Ravi, Lahore',
        joinDate: DateTime(now.year - 1, 8, 1), batch: 'Morning',
        skillLevel: 'Professional', monthlyFee: 4000,
        emergencyContact: '0314-5678901', bloodGroup: 'AB+',
        playingRole: 'All-rounder', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU014', fullName: 'Hira Batool', fatherName: 'Batool Hussain',
        mobileNumber: '0314-4567890', whatsappNumber: '0314-4567890',
        dateOfBirth: DateTime(2013, 4, 22), age: 13, gender: 'Female',
        address: 'House 11, Street 8, G-11/2, Islamabad',
        joinDate: DateTime(now.year, 2, 28), batch: 'Evening',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0315-4567890', bloodGroup: 'O+',
        playingRole: 'Batsman', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU015', fullName: 'Taha Siddiqui', fatherName: 'Siddiqui Anwar',
        mobileNumber: '0315-5678901', whatsappNumber: '0315-5678901',
        dateOfBirth: DateTime(2011, 6, 9), age: 15, gender: 'Male',
        address: 'House 20, Block F, Johar Town, Lahore',
        joinDate: DateTime(now.year, 1, 8), batch: 'Morning',
        skillLevel: 'Advanced', monthlyFee: 3000,
        emergencyContact: '0316-3456789', bloodGroup: 'B-',
        playingRole: 'Bowler', isActive: true, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU016', fullName: 'Areeba Malik', fatherName: 'Malik Nadeem',
        mobileNumber: '0316-6789012', whatsappNumber: null,
        dateOfBirth: DateTime(2014, 1, 15), age: 12, gender: 'Female',
        address: 'House 4, Block B, Askari 10, Lahore',
        joinDate: DateTime(now.year, 3, 10), batch: 'Evening',
        skillLevel: 'Beginner', monthlyFee: 2000,
        emergencyContact: '0317-2345678', bloodGroup: 'A-',
        playingRole: 'Wicket Keeper', isActive: true, academy: 1, coach: 2,
      ),
      Student(
        id: 'STU017', fullName: 'Imran Ghani', fatherName: 'Ghani Abbas',
        mobileNumber: '0317-7890123', whatsappNumber: '0317-7890123',
        dateOfBirth: DateTime(2010, 9, 30), age: 15, gender: 'Male',
        address: 'House 16, Street 4, Clifton Block 3, Karachi',
        joinDate: DateTime(now.year - 1, 11, 1), batch: 'Morning',
        skillLevel: 'Professional', monthlyFee: 4000,
        emergencyContact: '0318-1234567', bloodGroup: 'O+',
        playingRole: 'All-rounder', isActive: false, academy: 1, coach: 1,
      ),
      Student(
        id: 'STU018', fullName: 'Komal Rizvi', fatherName: 'Rizvi Jaffar',
        mobileNumber: '0318-8901234', whatsappNumber: '0318-8901234',
        dateOfBirth: DateTime(2012, 8, 11), age: 13, gender: 'Female',
        address: 'House 6, Block D, Bahria Town, Rawalpindi',
        joinDate: DateTime(now.year, 2, 15), batch: 'Evening',
        skillLevel: 'Intermediate', monthlyFee: 2500,
        emergencyContact: '0319-5678901', bloodGroup: 'AB+',
        playingRole: 'Batsman', isActive: true, academy: 1, coach: 2,
      ),
    ];
  }

  static void _generateAttendance() {
    final now = DateTime.now();
    const statuses = ['Present', 'Present', 'Present', 'Present', 'Present', 'Absent', 'Late'];
    _attendance = [];
    for (int day = -6; day <= 0; day++) {
      final date = DateTime(now.year, now.month, now.day + day);
      for (final student in _students) {
        if (!student.isActive) continue;
        final status = statuses[day.abs() % statuses.length];
        _attendance.add(Attendance(
          id: 'ATT${student.id}_${day + 6}',
          studentId: student.id,
          date: date,
          status: status,
        ));
      }
    }
  }

  static void _generateFees() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July'];
    _fees = [];
    int i = 0;
    for (final student in _students) {
      if (!student.isActive) continue;
      for (int m = 0; m < 3; m++) {
        final monthIdx = ((now.month - 1 - m) % 12 + 12) % 12;
        final isPaid = i % 3 != 0;
        final partial = i % 5 == 0;
        _fees.add(Fee(
          id: 'FEE${student.id}_$m',
          studentId: student.id,
          month: months[monthIdx],
          monthlyFee: student.monthlyFee,
          paidAmount: isPaid ? (partial ? student.monthlyFee * 0.5 : student.monthlyFee) : 0,
          balance: isPaid ? (partial ? student.monthlyFee * 0.5 : 0) : student.monthlyFee,
          dueDate: DateTime(now.year, monthIdx + 1, 10),
          paymentDate: isPaid ? DateTime(now.year, monthIdx + 1, 5) : null,
          paymentMethod: isPaid ? (i % 2 == 0 ? 'Cash' : 'Bank Transfer') : '',
          receiptNumber: isPaid ? 'RCP-${now.year}-${(i * 3 + m).toString().padLeft(4, '0')}' : null,
          status: isPaid ? (partial ? 'Partial' : 'Paid') : 'Pending',
        ));
      }
      i++;
    }
  }

  static void _generatePerformances() {
    final now = DateTime.now();
    _performances = [];
    for (final student in _students) {
      if (!student.isActive) continue;
      for (int m = 0; m < 2; m++) {
        final date = DateTime(now.year, now.month - m, 15);
        final batting = (student.fullName.hashCode.abs() % 4) + 6;
        final bowling = (student.fullName.hashCode.abs() ~/ 10 % 4) + 6;
        final fielding = (student.fullName.hashCode.abs() ~/ 100 % 4) + 6;
        final fitness = (student.fullName.hashCode.abs() ~/ 1000 % 4) + 6;
        final discipline = (student.fullName.hashCode.abs() ~/ 10000 % 4) + 7;
        final overall = (batting + bowling + fielding + fitness + discipline) / 5;
        _performances.add(Performance(
          id: 'PERF${student.id}_$m',
          studentId: student.id,
          date: date,
          battingRating: batting.clamp(1, 10),
          bowlingRating: bowling.clamp(1, 10),
          fieldingRating: fielding.clamp(1, 10),
          fitnessRating: fitness.clamp(1, 10),
          disciplineRating: discipline.clamp(1, 10),
          coachRemarks: m == 0 ? (_getRemark(overall)) : null,
          overallRating: double.parse(overall.toStringAsFixed(1)),
        ));
      }
    }
  }

  static String _getRemark(double rating) {
    if (rating >= 8.5) return 'Excellent progress. Keep it up!';
    if (rating >= 7.0) return 'Good performance. Room for improvement.';
    if (rating >= 5.0) return 'Average. Needs more practice.';
    return 'Needs significant improvement. Focus on basics.';
  }

  static void _generateMatches() {
    final now = DateTime.now();
    _matches = [
      MatchRecord(
        id: 'MCH001', matchDate: DateTime(now.year, now.month, now.day - 15),
        opponent: 'United Cricket Club', venue: 'National Stadium, Karachi',
        runs: 180, wickets: 6, catches: 3, strikeRate: 85.5, economy: 4.2,
        result: 'Win', isManOfTheMatch: true,
      ),
      MatchRecord(
        id: 'MCH002', matchDate: DateTime(now.year, now.month, now.day - 8),
        opponent: 'Rising Stars Academy', venue: 'Gaddafi Stadium, Lahore',
        runs: 145, wickets: 2, catches: 1, strikeRate: 72.0, economy: 5.8,
        result: 'Loss', isManOfTheMatch: false,
      ),
      MatchRecord(
        id: 'MCH003', matchDate: DateTime(now.year, now.month, now.day - 2),
        opponent: 'City Cricket Club', venue: 'Rawalpindi Cricket Stadium',
        runs: 210, wickets: 4, catches: 2, strikeRate: 95.2, economy: 3.5,
        result: 'Win', isManOfTheMatch: true,
      ),
      MatchRecord(
        id: 'MCH004', matchDate: DateTime(now.year, now.month, now.day + 5),
        opponent: 'Defence Cricket Academy', venue: 'DHA Cricket Ground, Lahore',
        runs: 0, wickets: 0, catches: 0, strikeRate: 0, economy: 0,
        result: 'Draw', isManOfTheMatch: false,
      ),
    ];
  }

  static void _generateExpenses() {
    final now = DateTime.now();
    _expenses = [
      Expense(
        id: 'EXP001', title: 'Cricket Balls (Pack of 12)', category: 'Equipment',
        amount: 4500, date: DateTime(now.year, now.month, 2),
        notes: 'Purchased from Sports Mart', status: 'Approved',
      ),
      Expense(
        id: 'EXP002', title: 'Ground Maintenance - July', category: 'Maintenance',
        amount: 8000, date: DateTime(now.year, now.month, 5),
        notes: 'Monthly ground upkeep', status: 'Approved',
      ),
      Expense(
        id: 'EXP003', title: 'Coach Salary - Head Coach', category: 'Salary',
        amount: 25000, date: DateTime(now.year, now.month, 1),
        notes: 'Monthly salary for Head Coach', status: 'Approved',
      ),
      Expense(
        id: 'EXP004', title: 'Electricity Bill', category: 'Utilities',
        amount: 3200, date: DateTime(now.year, now.month, 10),
        notes: 'June electricity bill', status: 'Approved',
      ),
      Expense(
        id: 'EXP005', title: 'Tournament Registration Fee', category: 'Tournament',
        amount: 10000, date: DateTime(now.year, now.month, 12),
        notes: 'Inter-Academy Championship registration', status: 'Pending',
      ),
      Expense(
        id: 'EXP006', title: 'Transport - Away Match', category: 'Transport',
        amount: 3500, date: DateTime(now.year, now.month, 15),
        notes: 'Bus rental for away match vs LRCA', status: 'Approved',
      ),
      Expense(
        id: 'EXP007', title: 'First Aid Kit', category: 'Medical',
        amount: 1500, date: DateTime(now.year, now.month, 8),
        notes: 'Replenished medical supplies', status: 'Approved',
      ),
      Expense(
        id: 'EXP008', title: 'Water Cooler Maintenance', category: 'Other',
        amount: 2000, date: DateTime(now.year, now.month, 18),
        notes: 'Repair of water dispenser', status: 'Approved',
      ),
    ];
  }
}
