import '../../domain/entities/user_role.dart';

class UserRoleModel extends UserRole {
  const UserRoleModel({
    required super.id,
    required super.userId,
    required super.roleId,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      roleId: json['roleId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roleId': roleId,
    };
  }
}
