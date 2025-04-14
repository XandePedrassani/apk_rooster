import 'package:flutter/material.dart';
import '../../models/servico_produto_model.dart';

class ProdutosListSection extends StatelessWidget {
  final List<ServicoProduto> produtosAdicionados;
  final VoidCallback onAdicionarProduto;
  final ValueChanged<ServicoProduto> onRemoverProduto;

  ProdutosListSection({
    required this.produtosAdicionados,
    required this.onAdicionarProduto,
    required this.onRemoverProduto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Produtos adicionados:', style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onAdicionarProduto,
            ),
          ],
        ),
        ...produtosAdicionados.map((sp) => ListTile(
          title: Text('${sp.produto.nome} - ${sp.quantidade}x'),
          subtitle: Text('R\$ ${sp.precoUnitario.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onRemoverProduto(sp),
          ),
        )),
      ],
    );
  }
}
