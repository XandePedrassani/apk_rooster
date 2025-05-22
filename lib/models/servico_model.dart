import 'package:rooster/models/servico_produto_model.dart';
import 'package:rooster/models/usuario.dart';
import 'package:rooster/models/status_model.dart';
import 'cliente_model.dart';

class Servico {
  int? id;
  DateTime dtMovimento;
  DateTime dtEntrega;
  String? observacao;
  Cliente cliente;
  Usuario usuario;
  StatusModel status;
  List<ServicoProduto> produtos;

  Servico({
    this.id,
    required this.dtMovimento,
    required this.dtEntrega,
    this.observacao,
    required this.cliente,
    required this.usuario,
    required this.status,
    this.produtos = const [],
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    // Verifica se o status vem como objeto ou como string
    StatusModel statusObj;
    if (json['status'] is Map<String, dynamic>) {
      statusObj = StatusModel.fromJson(json['status']);
    } else {
      // Fallback para compatibilidade com API que ainda retorna string
      statusObj = StatusModel(
        id: 0, 
        nome: json['status'] ?? 'pendente',
        ordem: json['status'] == 'pronto' ? 2 : (json['status'] == 'entregue' ? 3 : 1),
        cor: null
      );
    }
    
    return Servico(
      id: json['id'],
      dtMovimento: DateTime.parse(json['dtMovimento']),
      dtEntrega: DateTime.parse(json['dtEntrega']),
      observacao: json['observacao'],
      cliente: Cliente.fromJson(json['cliente']),
      usuario: Usuario.fromJson(json['usuario']),
      status: statusObj,
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
    'statusId': status.id,
    'produtos': produtos.map((e) => e.toJson()).toList(),
  };
}
