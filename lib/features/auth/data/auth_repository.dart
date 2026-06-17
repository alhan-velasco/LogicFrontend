import 'package:logistica_app/core/network/api_service.dart';

class AuthUser {
  const AuthUser({
    required this.token,
    required this.email,
    required this.fullName,
  });

  final String token;
  final String email;
  final String fullName;
}

class AuthRepository {
  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  String? get token => _currentUser?.token;
  bool get isAuthenticated => _currentUser != null;

  Future<AuthUser> login(String email, String password) async {
    final response = await _apiService.post(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al iniciar sesión',
    );

    final data = _apiService.decodeMap(response);
    _currentUser = AuthUser(
      token: data['token'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
    );
    _apiService.setAuthToken(_currentUser!.token);
    return _currentUser!;
  }

  Future<AuthUser> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await _apiService.post(
      '/api/auth/register',
      body: {
        'email': email,
        'password': password,
        'full_name': name,
      },
    );

    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al registrar usuario',
    );

    final data = _apiService.decodeMap(response);
    _currentUser = AuthUser(
      token: data['token'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
    );
    _apiService.setAuthToken(_currentUser!.token);
    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
    _apiService.setAuthToken(null);
  }
}
