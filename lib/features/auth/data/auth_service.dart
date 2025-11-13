import '../../../core/api/api_client.dart';
import '../domain/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/Auth/login',
      data: {'email': email, 'password': password},
    );

    final token = response.data['token'] as String;
    final user = User.fromJson(response.data['user']);

    await _apiClient.setToken(token);

    return LoginResponse(token: token, user: user);
  }

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiClient.post(
      '/Auth/register',
      data: {'email': email, 'password': password, 'fullName': fullName},
    );

    final token = response.data['token'] as String;
    final user = User.fromJson(response.data['user']);

    await _apiClient.setToken(token);

    return RegisterResponse(token: token, user: user);
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  bool get isAuthenticated => _apiClient.isAuthenticated;
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});
}

class RegisterResponse {
  final String token;
  final User user;

  RegisterResponse({required this.token, required this.user});
}
