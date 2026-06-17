import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({required this.baseUrl});

  static const String defaultBaseUrl = 'http://100.31.213.32:8000';

  final String baseUrl;
  String? _authToken;

  void setAuthToken(String? token) => _authToken = token;

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      ...?extraHeaders,
    };
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      return await http
          .get(_uri(path), headers: _buildHeaders(extraHeaders: headers))
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (e) {
      throw ApiException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      return await http
          .post(
            _uri(path),
            headers: _buildHeaders(extraHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (e) {
      throw ApiException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      return await http
          .put(
            _uri(path),
            headers: _buildHeaders(extraHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (e) {
      throw ApiException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      return await http
          .delete(_uri(path), headers: _buildHeaders(extraHeaders: headers))
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (e) {
      throw ApiException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ApiException('No se pudo conectar con el servidor: $e');
    }
  }

  Map<String, dynamic> decodeMap(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<dynamic> decodeList(http.Response response) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  void throwIfNotSuccess(http.Response response, {String? fallbackMessage}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String) {
          throw ApiException(detail, statusCode: response.statusCode);
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
    }

    throw ApiException(
      fallbackMessage ?? 'Error en la petición (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
