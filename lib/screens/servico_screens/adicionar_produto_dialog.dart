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
    builder: (_) => AlertDialog(
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
                  produtoSelecionado = value;
                  precoController.text =
                      value?.preco.toStringAsFixed(2) ?? '';
                  preco = value?.preco ?? 0.0;
                },
                validator: (value) =>
                value == null ? 'Selecione um produto' : null,
                decoration: InputDecoration(labelText: 'Produto'),
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Quantidade:'),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (quantidade > 1) {
                        quantidade--;
                        quantidadeController.text = quantidade.toString();
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: quantidadeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          quantidade = parsed;
                        }
                      },
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) return 'Qtd inválida';
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      quantidade++;
                      quantidadeController.text = quantidade.toString();
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: precoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Preço Unitário'),
                validator: (val) {
                  final num = double.tryParse(val ?? '');
                  return (num == null || num < 0)
                      ? 'Preço inválido'
                      : null;
                },
                onChanged: (val) => preco = double.tryParse(val) ?? preco,
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
  );
}
