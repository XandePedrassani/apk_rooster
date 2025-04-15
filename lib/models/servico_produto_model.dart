import 'package:rooster/models/produto_model.dart';

class ServicoProduto {
  Produto produto;
  int quantidade;
  double precoUnitario;
  String? observacao;
  int sequencia;

  ServicoProduto({
    required this.produto,
    required this.quantidade,
    required this.precoUnitario,
    this.observacao,
    required this.sequencia,
  });

  Map<String, dynamic> toJson() => {
    'produto': produto.toJson(),
    'quantidade': quantidade,
    'precoUnitario': precoUnitario,
    'observacao': observacao,
    'sequencia': sequencia,
  };
  factory ServicoProduto.fromJson(Map<String, dynamic> json) {
    return ServicoProduto(
      produto: Produto.fromJson(json['produto']),
      quantidade: json['quantidade'],
      precoUnitario: (json['precoUnitario'] as num).toDouble(),
      observacao: json['observacao'],
      sequencia: json['sequencia']
    );
  }
}
