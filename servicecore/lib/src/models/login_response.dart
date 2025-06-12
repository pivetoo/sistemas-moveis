import 'usuario.dart';

class LoginResponse {
  final String token;
  final Usuario? usuario;
  final String? message;

  LoginResponse({
    required this.token,
    this.usuario,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      usuario: json['usuario'] != null
        ? Usuario.fromJson(json['usuario'])
        : null,
      message: json['message'],
    );
  }
}