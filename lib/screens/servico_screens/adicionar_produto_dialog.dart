import 'package:flutter/material.dart';
import '../../models/produto_model.dart';
import '../../models/servico_produto_model.dart';

Future<ServicoProduto?> mostrarAdicionarProdutoDialog({
  required BuildContext context,
  required List<Produto> produtosDisponiveis,
  ServicoProduto? servicoProdutoExistente,
}) async {
  Produto? produtoSelecionado = servicoProdutoExistente?.produto;
  int quantidade = servicoProdutoExistente?.quantidade ?? 1;
  double preco = servicoProdutoExistente?.precoUnitario ?? 0.0;
  String observacao = servicoProdutoExistente?.observacao ?? '';

  final precoController = TextEditingController(text: preco.toStringAsFixed(2));
  final observacaoController = TextEditingController(text: observacao);
  final quantidadeController = TextEditingController(text: quantidade.toString());

  final formKey = GlobalKey<FormState>();

  return await showDialog<ServicoProduto>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(servicoProdutoExistente == null ? 'Adicionar Produto' : 'Editar Produto'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Produto>(
                  value: produtoSelecionado,
                  items: produtosDisponiveis
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.nome),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      produtoSelecionado = value;
                      preco = value?.preco ?? 0.0;
                      precoController.text = preco.toStringAsFixed(2);
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Selecione um produto' : null,
                  decoration: InputDecoration(labelText: 'Produto'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: quantidadeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (quantidade > 1) {
                              setState(() {
                                quantidade--;
                                quantidadeController.text = quantidade.toString();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantidade++;
                              quantidadeController.text = quantidade.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      setState(() {
                        quantidade = parsed;
                      });
                    }
                  },
                  validator: (val) {
                    final parsed = int.tryParse(val ?? '');
                    if (parsed == null || parsed <= 0) return 'Qtd inválida';
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: precoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Preço Unitário',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              preco = (preco - 1).clamp(0, double.infinity);
                              precoController.text = preco.toStringAsFixed(2);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              preco += 1;
                              precoController.text = preco.toStringAsFixed(2);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  validator: (val) {
                    final num = double.tryParse(val ?? '');
                    return (num == null || num < 0) ? 'Preço inválido' : null;
                  },
                  onChanged: (val) {
                    setState(() {
                      preco = double.tryParse(val) ?? preco;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: observacaoController,
                  decoration: InputDecoration(labelText: 'Observação'),
                  maxLines: 2,
                  onChanged: (val) => observacao = val,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(servicoProdutoExistente == null ? 'Adicionar' : 'Salvar'),
            onPressed: () {
              quantidade = int.tryParse(quantidadeController.text) ?? 1;
              if (formKey.currentState!.validate() && produtoSelecionado != null) {
                Navigator.pop(
                  context,
                  ServicoProduto(
                    produto: produtoSelecionado!,
                    quantidade: quantidade,
                    precoUnitario: preco,
                    sequencia: servicoProdutoExistente?.sequencia ?? 0,
                    observacao: observacaoController.text,
                  ),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}
