class Usuario {
  final int? id;
  final String? nome;
  final String? senha;
  final String? email;

  Usuario({
    this.id,
    this.nome,
    this.senha,
    this.email,
  });
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'senha': senha,
      'email': email,
    };
  }
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
        id: json['id'],
        nome: json['nome'],
        senha: json['senha'],
        email: json['email']
    );
  }
}