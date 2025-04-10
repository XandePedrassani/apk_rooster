class Cliente {
  final int? id;
  final String nome;
  final String contato;
  final DateTime dataNascimento;
  final DateTime dataCadastro;
  final String cpfcnpj;
  final String endereco;
  final String email;

  Cliente({
    this.id,
    required this.nome,
    required this.contato,
    required this.dataNascimento,
    required this.dataCadastro,
    required this.cpfcnpj,
    required this.endereco,
    required this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      contato: json['contato'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      dataCadastro: DateTime.parse(json['dataCadastro']),
      cpfcnpj: json['cpfcnpj'],
      endereco: json['endereco'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'contato': contato,
      'dataNascimento': dataNascimento.toIso8601String(),
      'dataCadastro': dataCadastro.toIso8601String(),
      'cpfcnpj': cpfcnpj,
      'endereco': endereco,
      'email': email,
    };
  }
}
