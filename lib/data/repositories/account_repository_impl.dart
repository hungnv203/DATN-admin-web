import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/role_permission.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<User>> getUsers() => remoteDataSource.getUsers();

  @override
  Future<List<Role>> getRoles() => remoteDataSource.getRoles();

  @override
  Future<Role> createRole(String name, String description) => remoteDataSource.createRole(name, description);

  @override
  Future<List<Permission>> getPermissions() => remoteDataSource.getPermissions();

  @override
  Future<Permission> createPermission(String name, String description) => remoteDataSource.createPermission(name, description);

  @override
  Future<List<UserRole>> getUserRoles() => remoteDataSource.getUserRoles();

  @override
  Future<UserRole> assignRoleToUser(String userId, String roleId) => remoteDataSource.assignRoleToUser(userId, roleId);

  @override
  Future<bool> removeRoleFromUser(String userRoleId) => remoteDataSource.removeRoleFromUser(userRoleId);

  @override
  Future<List<RolePermission>> getRolePermissions() => remoteDataSource.getRolePermissions();

  @override
  Future<RolePermission> assignPermissionToRole(String roleId, String permissionId) => remoteDataSource.assignPermissionToRole(roleId, permissionId);

  @override
  Future<bool> removePermissionFromRole(String rolePermissionId) => remoteDataSource.removePermissionFromRole(rolePermissionId);

  @override
  Future<bool> deleteRole(String roleId) => remoteDataSource.deleteRole(roleId);

  @override
  Future<bool> deletePermission(String permissionId) => remoteDataSource.deletePermission(permissionId);
}
