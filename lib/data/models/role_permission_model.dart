import '../../domain/entities/role_permission.dart';

class RolePermissionModel extends RolePermission {
  const RolePermissionModel({
    required super.id,
    required super.roleId,
    required super.permissionId,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      id: json['id'] ?? '',
      roleId: json['roleId'] ?? '',
      permissionId: json['permissionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'permissionId': permissionId,
    };
  }
}
