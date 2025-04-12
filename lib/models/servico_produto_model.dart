import 'package:rooster/models/produto_model.dart';

class ServicoProduto {
  int? id;
  Produto produto;
  int quantidade;
  double precoUnitario;
  String? observacao;
  int sequencia;

  ServicoProduto({
    this.id,
    required this.produto,
    required this.quantidade,
    required this.precoUnitario,
    this.observacao,
    required this.sequencia,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'produto': produto.toJson(),
    'quantidade': quantidade,
    'precoUnitario': precoUnitario,
    'observacao': observacao,
    'sequencia': sequencia,
  };
}
