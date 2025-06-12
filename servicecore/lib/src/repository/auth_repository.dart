import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_credentials.dart';
import '../models/login_response.dart';
import '../services/services.dart';

class AuthRepository {
  static const String _tokenKey = 'authToken';

  Future<LoginResponse> login(LoginCredentials credentials) async {
    try {
      final response = await ApiService.post(
        'usuario/login',
        body: credentials.toJson(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        if (loginResponse.token.isNotEmpty) {
          await setAuthToken(loginResponse.token);
        }

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Login ou senha incorretos');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Dados inválidos';
        throw Exception(errorMessage);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Erro ao fazer login. Tente novamente.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro de conexão. Verifique sua internet e tente novamente.');
    }
  }

  Future<void> setAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      ApiService.setAuthToken(token);
    } catch (error) {
      print('Erro ao salvar token: $error');
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (error) {
      print('Erro ao recuperar token: $error');
      return null;
    }
  }

  Future<void> removeAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      ApiService.clearAuthToken();
    } catch (error) {
      print('Erro ao remover token: $error');
    }
  }

  Future<void> logout() async {
    await removeAuthToken();
  }

  Future<void> initializeAuth() async {
    try {
      final token = await getAuthToken();
      if (token != null) {
        ApiService.setAuthToken(token);
      }
    } catch (error) {
      print('Erro ao inicializar autenticação: $error');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}

final authRepository = AuthRepository();