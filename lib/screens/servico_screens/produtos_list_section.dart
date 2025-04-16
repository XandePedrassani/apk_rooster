import 'package:flutter/material.dart';
import '../../models/servico_produto_model.dart';

class ProdutosListSection extends StatelessWidget {
  final List<ServicoProduto> produtosAdicionados;
  final VoidCallback onAdicionarProduto;
  final ValueChanged<ServicoProduto> onRemoverProduto;
  final ValueChanged<ServicoProduto> onEditarProduto;

  ProdutosListSection({
    required this.produtosAdicionados,
    required this.onAdicionarProduto,
    required this.onRemoverProduto,
    required this.onEditarProduto,
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
        ...produtosAdicionados.map((sp) {
          final total = sp.quantidade * sp.precoUnitario;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text('${sp.produto.nome} (${sp.quantidade}x)'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preço unitário: R\$ ${sp.precoUnitario.toStringAsFixed(2)}'),
                  Text('Total: R\$ ${total.toStringAsFixed(2)}'),
                  if (sp.observacao != null && sp.observacao!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Obs: ${sp.observacao}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => onEditarProduto(sp),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => onRemoverProduto(sp),
                  ),
                ],
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
            'Total geral: R\$ ${produtosAdicionados.fold(0.0, (total, sp) => total + (sp.quantidade * sp.precoUnitario)).toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
