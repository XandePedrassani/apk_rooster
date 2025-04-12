class Cliente {
  final int? id;
  final String nome;
  final String contato;
  final DateTime? dataNascimento;
  final DateTime dataCadastro;
  final String? cpfcnpj;
  final String? endereco;
  final String? email;

  Cliente({
    this.id,
    required this.nome,
    required this.contato,
    this.dataNascimento,
    required this.dataCadastro,
    this.cpfcnpj,
    this.endereco,
    this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      contato: json['contato'] as String,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.tryParse(json['dataNascimento'])
          : null,
      dataCadastro: DateTime.parse(json['dataCadastro']),
      cpfcnpj: json['cpfcnpj'] as String?,
      endereco: json['endereco'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'contato': contato,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'dataCadastro': dataCadastro.toIso8601String(),
      'cpfcnpj': cpfcnpj,
      'endereco': endereco,
      'email': email,
    };
  }
}