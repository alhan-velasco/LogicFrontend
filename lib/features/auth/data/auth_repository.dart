import 'dart:convert';

import 'package:http/http.dart' as http;

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
  AuthRepository({required this.baseUrl});

  final String baseUrl;
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  String? get token => _currentUser?.token;
  bool get isAuthenticated => _currentUser != null;

  Future<AuthUser> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUser = AuthUser(
        token: data['token'] as String,
        email: data['email'] as String,
        fullName: data['full_name'] as String,
      );
      return _currentUser!;
    }

    throw _parseError(response);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUser = AuthUser(
        token: data['token'] as String,
        email: data['email'] as String,
        fullName: data['full_name'] as String,
      );
      return _currentUser!;
    }

    throw _parseError(response);
  }

  void logout() {
    _currentUser = null;
  }

  Exception _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) {
        return Exception(detail);
      }
    } catch (_) {}
    return Exception('Error de autenticación (${response.statusCode})');
  }
}
