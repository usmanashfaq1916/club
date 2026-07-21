class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? photoUrl;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.photoUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'fullName': fullName,
    'role': role,
    'phone': phone,
    'photoUrl': photoUrl,
    'isActive': isActive,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    fullName: map['fullName'] ?? '',
    role: map['role'] ?? '',
    phone: map['phone'],
    photoUrl: map['photoUrl'],
    isActive: map['isActive'] ?? true,
  );
}
