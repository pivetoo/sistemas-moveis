class OrdemServico {
  final int id;
  final String titulo;
  final String? descricao;
  final int status;
  final int prioridade;
  final DateTime? dataExecutar;
  final DateTime? dataAbertura;
  final Cliente? cliente;

  const OrdemServico({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.status,
    required this.prioridade,
    this.dataExecutar,
    this.dataAbertura,
    this.cliente,
  });

  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    return OrdemServico(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      status: json['status'] ?? 0,
      prioridade: json['prioridade'] ?? 0,
      dataExecutar: json['dataExecutar'] != null
        ? DateTime.tryParse(json['dataExecutar'])
        : null,
      dataAbertura: json['dataAbertura'] != null
        ? DateTime.tryParse(json['dataAbertura'])
        : null,
      cliente: json['cliente'] != null
        ? Cliente.fromJson(json['cliente'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'prioridade': prioridade,
      'dataExecutar': dataExecutar?.toIso8601String(),
      'dataAbertura': dataAbertura?.toIso8601String(),
      'cliente': cliente?.toJson(),
    };
  }

  String get statusName {
    const statusMap = {
      0: 'Aguardando Atendimento',
      1: 'Em Andamento',
      2: 'Cancelada',
      3: 'Concluída',
      4: 'Exportada',
    };
    return statusMap[status] ?? 'Desconhecido';
  }

  String get prioridadeName {
    const prioridadeMap = {
      0: 'Baixa',
      1: 'Normal',
      2: 'Alta',
      3: 'Urgente',
    };
    return prioridadeMap[prioridade] ?? 'Não definida';
  }
}

class Cliente {
  final int? id;
  final String nome;
  final String? endereco;
  final String? telefone;
  final String? email;

  const Cliente({
    this.id,
    required this.nome,
    this.endereco,
    this.telefone,
    this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'] ?? '',
      endereco: json['endereco'],
      telefone: json['telefone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
      'email': email,
    };
  }
}