import '../entities/user.dart';
import '../entities/role.dart';
import '../entities/permission.dart';
import '../entities/user_role.dart';
import '../entities/role_permission.dart';

abstract class AccountRepository {
  Future<List<User>> getUsers();
  Future<List<Role>> getRoles();
  Future<Role> createRole(String name, String description);
  Future<List<Permission>> getPermissions();
  Future<Permission> createPermission(String name, String description);
  
  Future<List<UserRole>> getUserRoles();
  Future<UserRole> assignRoleToUser(String userId, String roleId);
  Future<bool> removeRoleFromUser(String userRoleId);

  Future<List<RolePermission>> getRolePermissions();
  Future<RolePermission> assignPermissionToRole(String roleId, String permissionId);
  Future<bool> removePermissionFromRole(String rolePermissionId);

  Future<bool> deleteRole(String roleId);
  Future<bool> deletePermission(String permissionId);
}
