import 'dart:html' as html;
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
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
      data: {
        'email': email,
        'password': password,
      },
    );
    
    final token = response.data['accessToken'];
    if (token != null) {
      html.window.localStorage['auth_token'] = token;
    }
    
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<void> logout() async {
    html.window.localStorage.remove('auth_token');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = html.window.localStorage['auth_token'];
    if (token == null) return null;
    
    // We can decode or fetch user profile, for simplicity fetch via token decoded metadata or fallback
    // In this API, we can fetch all users or have a profile API. Since we don't have a profile API,
    // we can return a cached user info or request info. For now, return null or mock.
    return null;
  }
}
