class StatusModel {
  final int id;
  final String nome;
  final int ordem;
  final String? cor;

  StatusModel({
    required this.id,
    required this.nome,
    required this.ordem,
    this.cor,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      nome: json['nome'],
      ordem: json['ordem'],
      cor: json['cor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ordem': ordem,
      'cor': cor,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StatusModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => nome; // ajuda no debug
}
