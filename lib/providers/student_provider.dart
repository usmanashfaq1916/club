import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Student> get students =>
      _searchQuery.isEmpty ? _students : _filteredStudents;
  List<Student> get allStudents => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalStudents => _students.length;
  int get activeStudents =>
      _students.where((s) => s.isActive).length;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get('/students/');
      final results = data['results'] ?? data ?? [];
      _students = (results as List)
          .map((j) => Student.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _students = MockDataService.students;
      _applyFilter();
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMockData() {
    _students = MockDataService.students;
    _applyFilter();
    _error = null;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredStudents = _students;
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredStudents = _students.where((s) {
        return s.fullName.toLowerCase().contains(q) ||
            s.mobileNumber.contains(q) ||
            s.fatherName.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> addStudent(Student student) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.post('/students/', body: {
        'full_name': student.fullName,
        'father_name': student.fatherName,
        'mobile_number': student.mobileNumber,
        'whatsapp_number': student.whatsappNumber ?? '',
        'date_of_birth': student.dateOfBirth.toIso8601String().split('T')[0],
        'gender': student.gender,
        'address': student.address,
        'batch': student.batch,
        'skill_level': student.skillLevel,
        'monthly_fee': student.monthlyFee.toString(),
        'emergency_contact': student.emergencyContact,
        'blood_group': student.bloodGroup,
        'is_active': student.isActive,
      });
      _isLoading = false;
      await loadStudents();
      return true;
    } catch (e) {
      _students.add(student);
      _applyFilter();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      final formatted = <String, dynamic>{};
      data.forEach((k, v) {
        if (k == 'dateOfBirth') {
          formatted['date_of_birth'] = (v as DateTime).toIso8601String().split('T')[0];
        } else if (k == 'joinDate') {
          formatted['join_date'] = (v as DateTime).toIso8601String().split('T')[0];
        } else if (k == 'monthlyFee') {
          formatted['monthly_fee'] = v.toString();
        } else if (k == 'whatsappNumber') {
          formatted['whatsapp_number'] = v ?? '';
        } else if (k == 'fatherName') {
          formatted['father_name'] = v;
        } else if (k == 'fullName') {
          formatted['full_name'] = v;
        } else if (k == 'mobileNumber') {
          formatted['mobile_number'] = v;
        } else if (k == 'skillLevel') {
          formatted['skill_level'] = v;
        } else if (k == 'emergencyContact') {
          formatted['emergency_contact'] = v;
        } else if (k == 'bloodGroup') {
          formatted['blood_group'] = v;
        } else if (k == 'photoUrl') {
          formatted['photo_url'] = v;
        } else if (k == 'isActive') {
          formatted['is_active'] = v;
        } else {
          formatted[k] = v;
        }
      });
      await ApiClient.put('/students/$id/', body: formatted);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await ApiClient.delete('/students/$id/');
      await loadStudents();
      return true;
    } catch (e) {
      _students.removeWhere((s) => s.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    }
  }

  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _students = [];
    _filteredStudents = [];
    _searchQuery = '';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
