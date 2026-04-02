class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String userType;
  final String? photo;
  final String? address;
  final String status;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.userType,
    this.photo,
    this.address,
    required this.status,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      userType: json['userType'] ?? 'driver',
      photo: json['photo'],
      address: json['address'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? photo,
    String? address,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone,
      email: email ?? this.email,
      userType: userType,
      photo: photo ?? this.photo,
      address: address ?? this.address,
      status: status,
      createdAt: createdAt,
    );
  }
}
