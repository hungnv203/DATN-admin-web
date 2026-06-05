import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    super.avatarUrl,
    required super.loyaltyPoints,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If backend returns LoyaltyPoint object, extract points
    int points = 0;
    if (json['loyaltyPoint'] != null) {
      points = json['loyaltyPoint']['points'] ?? 0;
    } else if (json['loyaltyPoints'] != null) {
      points = json['loyaltyPoints'];
    }
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      loyaltyPoints: points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'loyaltyPoints': loyaltyPoints,
    };
  }
}
