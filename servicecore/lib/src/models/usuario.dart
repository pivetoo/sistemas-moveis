class Usuario {
  final int id;
  final String nome;
  final String login;
  final String tipoUsuario;

  const Usuario({
    required this.id,
    required this.nome,
    required this.login,
    required this.tipoUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      login: json['login'] ?? '',
      tipoUsuario: json['tipoUsuario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'login': login,
      'tipoUsuario': tipoUsuario,
    };
  }
}