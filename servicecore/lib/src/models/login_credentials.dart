class LoginCredentials {
  final String login;
  final String senha;

  LoginCredentials({
    required this.login,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'senha': senha,
    };
  }
}