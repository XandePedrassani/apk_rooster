import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rooster/models/produto_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/produto_service.dart';

class ProdutoScreen extends StatefulWidget {
  final Produto? produto;

  ProdutoScreen({this.produto});

  @override
  _ProdutoScreenState createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _codBarrasController;
  late TextEditingController _custoController;
  late TextEditingController _caracteristicasController;
  late TextEditingController _marcaController;
  bool _status = true;
  Uint8List? _imagemBytes;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _precoController = TextEditingController(
        text: widget.produto?.preco.toStringAsFixed(2) ?? '');
    _codBarrasController =
        TextEditingController(text: widget.produto?.codBarras ?? '');
    _custoController = TextEditingController(
        text: widget.produto?.custo?.toStringAsFixed(2) ?? '');
    _caracteristicasController =
        TextEditingController(text: widget.produto?.caracteristicas ?? '');
    _marcaController =
        TextEditingController(text: widget.produto?.marca ?? '');
    _status = widget.produto?.status ?? true;
    _imagemBytes = widget.produto?.foto != null
        ? Uint8List.fromList(widget.produto!.foto!)
        : null;
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Usar o método do pickedFile diretamente
      setState(() {
        _imagemBytes = bytes;
      });
    }
  }

  void _salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      final produto = Produto(
        id: widget.produto?.id,
        nome: _nomeController.text,
        preco: double.tryParse(_precoController.text) ?? 0.0,
        codBarras: _codBarrasController.text,
        custo: double.tryParse(_custoController.text),
        caracteristicas: _caracteristicasController.text,
        foto: _imagemBytes,
        status: _status,
        marca: _marcaController.text,
      );

      try {
        if (widget.produto == null) {
          await ProdutoService().createProduto(produto);
        } else {
          await ProdutoService().updateProduto(produto);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _codBarrasController.dispose();
    _custoController.dispose();
    _caracteristicasController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                value!.isEmpty ? 'Nome é obrigatório' : null,
              ),
              TextFormField(
                controller: _precoController,
                decoration: InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Preço é obrigatório' : null,
              ),
              TextFormField(
                controller: _codBarrasController,
                decoration: InputDecoration(labelText: 'Código de Barras'),
              ),
              TextFormField(
                controller: _custoController,
                decoration: InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _caracteristicasController,
                decoration: InputDecoration(labelText: 'Características'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(labelText: 'Marca'),
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('Ativo'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              SizedBox(height: 10),
              _imagemBytes != null
                  ? Column(
                children: [
                  Image.memory(_imagemBytes!, height: 120),
                  TextButton(
                    onPressed: _selecionarImagem,
                    child: Text('Trocar Imagem'),
                  ),
                ],
              )
                  : TextButton(
                onPressed: _selecionarImagem,
                child: Text('Selecionar Imagem'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarProduto,
                child: Text(widget.produto == null ? 'Cadastrar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
