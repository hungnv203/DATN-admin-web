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

      _users = List<User>.from(results[0] as Iterable);
      _roles = List<Role>.from(results[1] as Iterable);
      _permissions = List<Permission>.from(results[2] as Iterable);
      _userRoles = List<UserRole>.from(results[3] as Iterable);
      _rolePermissions = List<RolePermission>.from(results[4] as Iterable);
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

  Future<void> assignMultiplePermissionsToRole(String roleId, List<String> permissionIds) async {
    try {
      for (int i = 0; i < permissionIds.length; i += 5) {
        final chunk = permissionIds.sublist(i, i + 5 > permissionIds.length ? permissionIds.length : i + 5);
        final futures = chunk.map((pid) => _repository.assignPermissionToRole(roleId, pid));
        final results = await Future.wait(futures);
        _rolePermissions.addAll(results);
      }
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

  Future<void> removeMultiplePermissionsFromRole(String roleId, List<String> permissionIds) async {
    try {
      for (int i = 0; i < permissionIds.length; i += 5) {
        final chunk = permissionIds.sublist(i, i + 5 > permissionIds.length ? permissionIds.length : i + 5);
        final futures = chunk.map((pid) {
          final rp = _rolePermissions.firstWhere((rp) => rp.roleId == roleId && rp.permissionId == pid);
          return _repository.removePermissionFromRole(rp.id).then((success) => success ? rp : null);
        });
        final results = await Future.wait(futures);
        for (var rp in results) {
          if (rp != null) _rolePermissions.remove(rp);
        }
      }
      notifyListeners();
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
