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
    // Support both camelCase (legacy) and snake_case (API) field names
    String firstName = json['firstName'] ?? json['first_name'] ?? '';
    String lastName  = json['lastName']  ?? json['last_name']  ?? '';
    // Fall back to splitting full_name if individual parts are missing
    if (firstName.isEmpty && lastName.isEmpty) {
      final full = (json['full_name'] as String? ?? '').trim();
      if (full.isNotEmpty) {
        final parts = full.split(RegExp(r'\s+'));
        firstName = parts[0];
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: firstName,
      lastName: lastName,
      phone: json['phone'] ?? '',
      email: json['email'],
      userType: json['userType'] ?? json['user_type'] ?? 'driver',
      photo: json['photo'],
      address: json['address'] is String ? json['address'] as String : null,
      status: json['status'] ?? 'active',
      createdAt: rawCreatedAt != null ? DateTime.parse(rawCreatedAt) : DateTime.now(),
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
