import '../../core/constants/api_constants.dart';
import '../../core/network/auth_token_store.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/role_validator.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await client.post(
      ApiConstants.signIn,
      data: {'email': email, 'password': password},
    );

    final token = response.data['accessToken'] as String?;
    final userRaw = response.data['user'] as Map<String, dynamic>? ?? {};
    final tokenRole = RoleValidator.extractRoleFromJwt(token);
    final user = UserModel.fromJson(userRaw, tokenRole);

    if (!RoleValidator.isAllowedAdminWebRole(user.role)) {
      clearAuthToken();
      throw Exception('Tài khoản không có quyền truy cập hệ thống quản trị.');
    }

    if (token != null) {
      writeAuthToken(token);
    }

    return user;
  }

  @override
  Future<void> logout() async {
    clearAuthToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = readAuthToken();
    if (token == null) return null;

    final role = RoleValidator.extractRoleFromJwt(token);
    if (!RoleValidator.isAllowedAdminWebRole(role)) {
      clearAuthToken();
      return null;
    }

    return null;
  }
}

