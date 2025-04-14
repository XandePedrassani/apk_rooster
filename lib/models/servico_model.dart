import 'package:rooster/models/servico_produto_model.dart';
import 'package:rooster/models/usuario.dart';
import 'cliente_model.dart';

class Servico {
  int? id;
  DateTime dtMovimento;
  DateTime dtEntrega;
  String? observacao;
  Cliente cliente;
  Usuario usuario;
  String status;
  List<ServicoProduto> produtos;

  Servico({
    this.id,
    required this.dtMovimento,
    required this.dtEntrega,
    this.observacao,
    required this.cliente,
    required this.usuario,
    this.status = 'pendente',
    this.produtos = const [],
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'],
      dtMovimento: DateTime.parse(json['dtMovimento']),
      dtEntrega: DateTime.parse(json['dtEntrega']),
      observacao: json['observacao'],
      cliente: Cliente.fromJson(json['cliente']),
      usuario: Usuario.fromJson(json['usuario']),
      status: json['status'] ?? 'pendente',
      produtos: json['produtos'] != null
          ? (json['produtos'] as List)
          .map((e) => ServicoProduto.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dtMovimento': dtMovimento.toIso8601String(),
    'dtEntrega': dtEntrega.toIso8601String(),
    'observacao': observacao,
    'cliente': cliente.toJson(),
    'usuario': usuario.toJson(),
    'status': status,
    'produtos': produtos.map((e) => e.toJson()).toList(),
  };
}
