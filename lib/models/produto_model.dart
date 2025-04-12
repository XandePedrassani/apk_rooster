import 'dart:convert';

class Produto {
  int? id;
  String nome;
  double preco;
  String? codBarras;
  double? custo;
  String? caracteristicas;
  List<int>? foto; // foto como bytes
  bool? status;
  String? marca;

  Produto({
    this.id,
    required this.nome,
    required this.preco,
    this.codBarras,
    this.custo,
    this.caracteristicas,
    this.foto,
    this.status,
    this.marca,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      codBarras: json['codBarras'],
      custo: json['custo'] != null ? (json['custo'] as num).toDouble() : null,
      caracteristicas: json['caracteristicas'],
      foto: json['fotoData'] != null ? base64Decode(json['fotoData']) : null,
      status: json['status'],
      marca: json['marca'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'codBarras': codBarras,
      'custo': custo,
      'caracteristicas': caracteristicas,
      'fotoData': foto != null ? base64Encode(foto!) : null,
      'status': status,
      'marca': marca,
    };
  }
}
