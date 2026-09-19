import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:datn_web/core/network/auth_token_store.dart';
import 'package:datn_web/core/utils/role_validator.dart';
import 'package:datn_web/data/models/user_model.dart';
import 'package:datn_web/domain/entities/user.dart';
import 'package:datn_web/domain/repositories/auth_repository.dart';
import 'package:datn_web/presentation/providers/auth_provider.dart';

class MockAuthRepository implements AuthRepository {
  User? userToReturn;
  Exception? exceptionToThrow;
  bool logoutCalled = false;

  @override
  Future<User> signIn(String email, String password) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return userToReturn!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    clearAuthToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    return userToReturn;
  }
}

String createTestJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  final signature = base64Url.encode(utf8.encode('signature'));
  return '$header.$body.$signature';
}

void main() {
  setUp(() {
    clearAuthToken();
  });

  group('RoleValidator - Admin Web', () {
    test('allows only admin and staff roles case-insensitively', () {
      expect(RoleValidator.isAllowedAdminWebRole('Admin'), isTrue);
      expect(RoleValidator.isAllowedAdminWebRole('admin'), isTrue);
      expect(RoleValidator.isAllowedAdminWebRole('ADMIN'), isTrue);
      expect(RoleValidator.isAllowedAdminWebRole('Staff'), isTrue);
      expect(RoleValidator.isAllowedAdminWebRole('staff'), isTrue);
      expect(RoleValidator.isAllowedAdminWebRole('STAFF'), isTrue);
    });

    test('rejects customer and other roles', () {
      expect(RoleValidator.isAllowedAdminWebRole('Customer'), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole('customer'), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole('CUSTOMER'), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole(null), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole(''), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole('   '), isFalse);
      expect(RoleValidator.isAllowedAdminWebRole('Other'), isFalse);
    });

    test('extractRoleFromJwt correctly parses standard role claim', () {
      final token = createTestJwt({'role': 'Admin'});
      expect(RoleValidator.extractRoleFromJwt(token), 'Admin');
    });

    test('extractRoleFromJwt parses .NET schema claim type', () {
      final token = createTestJwt({
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': 'Staff',
      });
      expect(RoleValidator.extractRoleFromJwt(token), 'Staff');
    });

    test('extractRoleFromJwt parses roles array', () {
      final token = createTestJwt({
        'roles': ['Manager', 'Staff'],
      });
      expect(RoleValidator.extractRoleFromJwt(token), 'Manager');
    });

    test('extractRoleFromJwt returns null on malformed token', () {
      expect(RoleValidator.extractRoleFromJwt('invalid.token'), isNull);
      expect(RoleValidator.extractRoleFromJwt(null), isNull);
      expect(RoleValidator.extractRoleFromJwt(''), isNull);
    });
  });

  group('UserModel Role Parsing', () {
    test('parses roleName from backend response', () {
      final json = {
        'id': 'u1',
        'email': 'admin@cinema.com',
        'fullName': 'Admin User',
        'phoneNumber': '0123456789',
        'roleName': 'Admin',
        'loyaltyPoints': 0,
      };
      final user = UserModel.fromJson(json);
      expect(user.role, 'Admin');
    });

    test('falls back to JWT role if roleName missing in JSON', () {
      final json = {
        'id': 'u2',
        'email': 'staff@cinema.com',
        'fullName': 'Staff User',
        'phoneNumber': '0987654321',
      };
      final user = UserModel.fromJson(json, 'Staff');
      expect(user.role, 'Staff');
    });
  });

  group('AuthProvider Login Role Enforcement', () {
    test('allows login for Admin role', () async {
      final repo = MockAuthRepository();
      repo.userToReturn = const User(
        id: '1',
        email: 'admin@cinema.com',
        fullName: 'Admin User',
        phoneNumber: '0123456789',
        loyaltyPoints: 0,
        role: 'Admin',
      );
      final provider = AuthProvider(repo);

      final result = await provider.login('admin@cinema.com', 'AdminPass123!');

      expect(result, isTrue);
      expect(provider.currentUser?.role, 'Admin');
      expect(provider.errorMessage, isNull);
    });

    test('allows login for Staff role', () async {
      final repo = MockAuthRepository();
      repo.userToReturn = const User(
        id: '2',
        email: 'staff@cinema.com',
        fullName: 'Staff User',
        phoneNumber: '0123456789',
        loyaltyPoints: 0,
        role: 'Staff',
      );
      final provider = AuthProvider(repo);

      final result = await provider.login('staff@cinema.com', 'StaffPass123!');

      expect(result, isTrue);
      expect(provider.currentUser?.role, 'Staff');
      expect(provider.errorMessage, isNull);
    });

    test('rejects login for Customer role with clear Vietnamese error and clears state', () async {
      final repo = MockAuthRepository();
      repo.userToReturn = const User(
        id: '3',
        email: 'customer@gmail.com',
        fullName: 'Customer User',
        phoneNumber: '0123456789',
        loyaltyPoints: 50,
        role: 'Customer',
      );
      final provider = AuthProvider(repo);

      final result = await provider.login('customer@gmail.com', 'CusPass123!');

      expect(result, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Tài khoản không có quyền truy cập hệ thống quản trị.');
      expect(repo.logoutCalled, isTrue);
    });

    test('rejects login if user role is null or non-admin', () async {
      final repo = MockAuthRepository();
      repo.userToReturn = const User(
        id: '4',
        email: 'guest@gmail.com',
        fullName: 'Guest User',
        phoneNumber: '0123456789',
        loyaltyPoints: 0,
        role: null,
      );
      final provider = AuthProvider(repo);

      final result = await provider.login('guest@gmail.com', 'Pass123!');

      expect(result, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Tài khoản không có quyền truy cập hệ thống quản trị.');
      expect(repo.logoutCalled, isTrue);
    });

    test('clears and rejects token in isAuthenticated if token has customer role', () {
      final customerToken = createTestJwt({'role': 'Customer'});
      writeAuthToken(customerToken);

      final repo = MockAuthRepository();
      final provider = AuthProvider(repo);

      expect(provider.isAuthenticated, isFalse);
      expect(readAuthToken(), isNull);
    });

    test('preserves and accepts token in isAuthenticated if token has admin role', () {
      final adminToken = createTestJwt({'role': 'Admin'});
      writeAuthToken(adminToken);

      final repo = MockAuthRepository();
      final provider = AuthProvider(repo);

      expect(provider.isAuthenticated, isTrue);
      expect(readAuthToken(), adminToken);
    });
  });
}
