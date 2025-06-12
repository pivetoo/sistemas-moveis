import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://os-control-production.up.railway.app/api';
  static String? _authToken;

  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  static Future<http.Response> get(String endpoint, {Map<String, String>? params}) async {
    Uri uri = Uri.parse('$_baseUrl/$endpoint');

    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }

    try {
      final response = await http.get(uri, headers: _defaultHeaders);
      return response;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.patch(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.put(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.delete(uri, headers: _defaultHeaders);
      return response;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static void clearAuthToken() {
    _authToken = null;
  }
}