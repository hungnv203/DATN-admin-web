import 'package:flutter/material.dart';
import '../../core/network/auth_token_store.dart';
import '../../core/utils/role_validator.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this.repository);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated {
    final token = readAuthToken();
    if (token == null || token.isEmpty) return false;
    final role = RoleValidator.extractRoleFromJwt(token);
    if (role != null && !RoleValidator.isAllowedAdminWebRole(role)) {
      clearAuthToken();
      return false;
    }
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await repository.signIn(email, password);
      if (!RoleValidator.isAllowedAdminWebRole(user.role)) {
        await logout();
        _isLoading = false;
        _errorMessage = 'Tài khoản không có quyền truy cập hệ thống quản trị.';
        notifyListeners();
        return false;
      }
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}

