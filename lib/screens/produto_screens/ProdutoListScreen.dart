import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../models/produto_model.dart';
import '../../services/produto_service.dart';
import 'produto_screen.dart';


class ProdutoListScreen extends StatefulWidget {
  @override
  _ProdutoListScreenState createState() => _ProdutoListScreenState();
}

class _ProdutoListScreenState extends State<ProdutoListScreen> {
  List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    try {
      final produtos = await ProdutoService().getProdutos();
      setState(() {
        _produtos = produtos;
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos')),
      );
    }
  }

  void _editarProduto(Produto produto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProdutoScreen(produto: produto)),
    );
    _loadProdutos();
  }

  void _adicionarProduto() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProdutoScreen()),
    );
    _loadProdutos();
  }

  void _excluirProduto(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Excluir Produto'),
        content: Text('Deseja realmente excluir o produto "$nome"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Excluir')),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ProdutoService().deleteProduto(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto excluído com sucesso')),
        );
        _loadProdutos();
      } catch (e) {
        print('Erro ao excluir produto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir produto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProdutos,
          ),
        ],
      ),
      body: _produtos.isEmpty
          ? Center(child: Text('Nenhum produto cadastrado'))
          : ListView.builder(
        itemCount: _produtos.length,
        itemBuilder: (_, index) {
          final produto = _produtos[index];
          return ListTile(
            leading: produto.foto != null && produto.foto!.isNotEmpty
                ? CircleAvatar(backgroundImage: MemoryImage(Uint8List.fromList(produto.foto!)))
                : CircleAvatar(child: Icon(Icons.inventory)),
            title: Text(produto.nome),
            subtitle: Text('Preço: R\$ ${produto.preco.toStringAsFixed(2) ?? '0.00'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _editarProduto(produto),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _excluirProduto(produto.id!, produto.nome),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarProduto,
        child: Icon(Icons.add),
        tooltip: 'Novo Produto',
      ),
    );
  }
}
