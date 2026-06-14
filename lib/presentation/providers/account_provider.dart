import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/role_permission.dart';
import '../../domain/repositories/account_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountRepository _repository;

  AccountProvider(this._repository);

  List<User> _users = [];
  List<Role> _roles = [];
  List<Permission> _permissions = [];
  List<UserRole> _userRoles = [];
  List<RolePermission> _rolePermissions = [];

  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<Role> get roles => _roles;
  List<Permission> get permissions => _permissions;
  List<UserRole> get userRoles => _userRoles;
  List<RolePermission> get rolePermissions => _rolePermissions;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getUsers(),
        _repository.getRoles(),
        _repository.getPermissions(),
        _repository.getUserRoles(),
        _repository.getRolePermissions(),
      ]);

      _users = results[0] as List<User>;
      _roles = results[1] as List<Role>;
      _permissions = results[2] as List<Permission>;
      _userRoles = results[3] as List<UserRole>;
      _rolePermissions = results[4] as List<RolePermission>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRole(String name, String description) async {
    try {
      final role = await _repository.createRole(name, description);
      _roles.add(role);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createPermission(String name, String description) async {
    try {
      final permission = await _repository.createPermission(name, description);
      _permissions.add(permission);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> assignRoleToUser(String userId, String roleId) async {
    try {
      final userRole = await _repository.assignRoleToUser(userId, roleId);
      _userRoles.add(userRole);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeRoleFromUser(String userId, String roleId) async {
    try {
      final userRole = _userRoles.firstWhere(
        (ur) => ur.userId == userId && ur.roleId == roleId,
      );
      final success = await _repository.removeRoleFromUser(userRole.id);
      if (success) {
        _userRoles.remove(userRole);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> assignPermissionToRole(String roleId, String permissionId) async {
    try {
      final rolePermission = await _repository.assignPermissionToRole(roleId, permissionId);
      _rolePermissions.add(rolePermission);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removePermissionFromRole(String roleId, String permissionId) async {
    try {
      final rolePermission = _rolePermissions.firstWhere(
        (rp) => rp.roleId == roleId && rp.permissionId == permissionId,
      );
      final success = await _repository.removePermissionFromRole(rolePermission.id);
      if (success) {
        _rolePermissions.remove(rolePermission);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRole(String roleId) async {
    try {
      final success = await _repository.deleteRole(roleId);
      if (success) {
        _roles.removeWhere((r) => r.id == roleId);
        _userRoles.removeWhere((ur) => ur.roleId == roleId);
        _rolePermissions.removeWhere((rp) => rp.roleId == roleId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePermission(String permissionId) async {
    try {
      final success = await _repository.deletePermission(permissionId);
      if (success) {
        _permissions.removeWhere((p) => p.id == permissionId);
        _rolePermissions.removeWhere((rp) => rp.permissionId == permissionId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
