import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';
import '../models/permission_model.dart';
import '../models/user_role_model.dart';
import '../models/role_permission_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<List<RoleModel>> getRoles();
  Future<RoleModel> createRole(String name, String description);
  Future<List<PermissionModel>> getPermissions();
  Future<PermissionModel> createPermission(String name, String description);
  
  Future<List<UserRoleModel>> getUserRoles();
  Future<UserRoleModel> assignRoleToUser(String userId, String roleId);
  Future<bool> removeRoleFromUser(String userRoleId);

  Future<List<RolePermissionModel>> getRolePermissions();
  Future<RolePermissionModel> assignPermissionToRole(String roleId, String permissionId);
  Future<bool> removePermissionFromRole(String rolePermissionId);

  Future<bool> deleteRole(String roleId);
  Future<bool> deletePermission(String permissionId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioClient client;

  AccountRemoteDataSourceImpl(this.client);

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await client.get(ApiConstants.users);
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    final response = await client.get(ApiConstants.roles);
    final List<dynamic> data = response.data;
    return data.map((json) => RoleModel.fromJson(json)).toList();
  }

  @override
  Future<RoleModel> createRole(String name, String description) async {
    final response = await client.post(
      ApiConstants.roles,
      data: {'name': name, 'description': description},
    );
    return RoleModel.fromJson(response.data);
  }

  @override
  Future<List<PermissionModel>> getPermissions() async {
    final response = await client.get(ApiConstants.permissions);
    final List<dynamic> data = response.data;
    return data.map((json) => PermissionModel.fromJson(json)).toList();
  }

  @override
  Future<PermissionModel> createPermission(String name, String description) async {
    final response = await client.post(
      ApiConstants.permissions,
      data: {'name': name, 'description': description},
    );
    return PermissionModel.fromJson(response.data);
  }

  @override
  Future<List<UserRoleModel>> getUserRoles() async {
    final response = await client.get(ApiConstants.userRoles);
    final List<dynamic> data = response.data;
    return data.map((json) => UserRoleModel.fromJson(json)).toList();
  }

  @override
  Future<UserRoleModel> assignRoleToUser(String userId, String roleId) async {
    final response = await client.post(
      ApiConstants.userRoles,
      data: {'userId': userId, 'roleId': roleId},
    );
    return UserRoleModel.fromJson(response.data);
  }

  @override
  Future<bool> removeRoleFromUser(String userRoleId) async {
    final response = await client.delete('${ApiConstants.userRoles}/$userRoleId');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<List<RolePermissionModel>> getRolePermissions() async {
    final response = await client.get(ApiConstants.rolePermissions);
    final List<dynamic> data = response.data;
    return data.map((json) => RolePermissionModel.fromJson(json)).toList();
  }

  @override
  Future<RolePermissionModel> assignPermissionToRole(String roleId, String permissionId) async {
    final response = await client.post(
      ApiConstants.rolePermissions,
      data: {'roleId': roleId, 'permissionId': permissionId},
    );
    return RolePermissionModel.fromJson(response.data);
  }

  @override
  Future<bool> removePermissionFromRole(String rolePermissionId) async {
    final response = await client.delete('${ApiConstants.rolePermissions}/$rolePermissionId');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deleteRole(String roleId) async {
    final response = await client.delete('${ApiConstants.roles}/$roleId');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> deletePermission(String permissionId) async {
    final response = await client.delete('${ApiConstants.permissions}/$permissionId');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
