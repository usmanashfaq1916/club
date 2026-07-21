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
  final bool isActive;

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
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'fatherName': fatherName,
    'mobileNumber': mobileNumber,
    'whatsappNumber': whatsappNumber,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'age': age,
    'gender': gender,
    'address': address,
    'joinDate': joinDate.toIso8601String(),
    'batch': batch,
    'skillLevel': skillLevel,
    'monthlyFee': monthlyFee,
    'emergencyContact': emergencyContact,
    'bloodGroup': bloodGroup,
    'photoUrl': photoUrl,
    'isActive': isActive,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id'] ?? '',
    fullName: map['fullName'] ?? '',
    fatherName: map['fatherName'] ?? '',
    mobileNumber: map['mobileNumber'] ?? '',
    whatsappNumber: map['whatsappNumber'],
    dateOfBirth: DateTime.parse(map['dateOfBirth']),
    age: map['age'] ?? 0,
    gender: map['gender'] ?? '',
    address: map['address'] ?? '',
    joinDate: DateTime.parse(map['joinDate']),
    batch: map['batch'] ?? '',
    skillLevel: map['skillLevel'] ?? '',
    monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
    emergencyContact: map['emergencyContact'] ?? '',
    bloodGroup: map['bloodGroup'] ?? '',
    photoUrl: map['photoUrl'],
    isActive: map['isActive'] ?? true,
  );
}
