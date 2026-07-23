class Student {
  final String id;
  final String fullName;
  final String fatherName;
  final String mobileNumber;
  final String? whatsappNumber;
  final DateTime dateOfBirth;
  final int age;
  final String gender;
  final String address;
  final DateTime joinDate;
  final String batch;
  final String skillLevel;
  final double monthlyFee;
  final String emergencyContact;
  final String bloodGroup;
  final String? photoUrl;
  final String playingRole;
  final bool isActive;
  final int? academy;
  final int? coach;
  final int? parent;
  final double scholarshipPercentage;

  Student({
    required this.id,
    required this.fullName,
    required this.fatherName,
    required this.mobileNumber,
    this.whatsappNumber,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.address,
    required this.joinDate,
    required this.batch,
    required this.skillLevel,
    required this.monthlyFee,
    required this.emergencyContact,
    required this.bloodGroup,
    this.photoUrl,
    this.playingRole = '',
    this.isActive = true,
    this.academy,
    this.coach,
    this.parent,
    this.scholarshipPercentage = 0,
  });

  Map<String, dynamic> toMap() => {
    'full_name': fullName,
    'father_name': fatherName,
    'mobile_number': mobileNumber,
    'whatsapp_number': whatsappNumber ?? '',
    'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
    'gender': gender,
    'address': address,
    'batch': batch,
    'skill_level': skillLevel,
    'monthly_fee': monthlyFee.toString(),
    'emergency_contact': emergencyContact,
    'blood_group': bloodGroup,
    'playing_role': playingRole,
    'scholarship_percentage': scholarshipPercentage.toString(),
    'is_active': isActive,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id']?.toString() ?? '',
    fullName: map['full_name'] ?? '',
    fatherName: map['father_name'] ?? '',
    mobileNumber: map['mobile_number'] ?? '',
    whatsappNumber: map['whatsapp_number'],
    dateOfBirth: DateTime.parse(map['date_of_birth']),
    age: map['age'] ?? 0,
    gender: map['gender'] ?? '',
    address: map['address'] ?? '',
    joinDate: DateTime.parse(map['join_date'] ?? map['created_at']),
    batch: map['batch'] ?? '',
    skillLevel: map['skill_level'] ?? '',
    monthlyFee: (map['monthly_fee'] ?? 0).toDouble(),
    emergencyContact: map['emergency_contact'] ?? '',
    bloodGroup: map['blood_group'] ?? '',
    photoUrl: map['photo'],
    playingRole: map['playing_role'] ?? '',
    scholarshipPercentage: (map['scholarship_percentage'] ?? 0).toDouble(),
    isActive: map['is_active'] ?? true,
    academy: map['academy'],
    coach: map['coach'],
    parent: map['parent'],
  );
}
