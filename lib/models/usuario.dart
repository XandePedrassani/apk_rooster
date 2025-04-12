class Usuario {
  final int? id;
  final String nome;
  final String senha;
  final String email;

  Usuario({
    this.id,
    required this.nome,
    required this.senha,
    required this.email,
  });
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'senha': senha,
      'email': email,
    };
  }
}