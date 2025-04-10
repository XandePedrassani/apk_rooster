import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteScreen extends StatefulWidget {
  final Cliente? cliente;

  ClienteScreen({this.cliente});

  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _contatoController;
  late TextEditingController _cpfcnpjController;
  late TextEditingController _enderecoController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Preenche os campos com dados do cliente (se houver)
    if (widget.cliente != null) {
      _nomeController = TextEditingController(text: widget.cliente!.nome);
      _contatoController = TextEditingController(text: widget.cliente!.contato);
      _cpfcnpjController = TextEditingController(text: widget.cliente!.cpfcnpj);
      _enderecoController = TextEditingController(text: widget.cliente!.endereco);
      _emailController = TextEditingController(text: widget.cliente!.email);
    } else {
      _nomeController = TextEditingController();
      _contatoController = TextEditingController();
      _cpfcnpjController = TextEditingController();
      _enderecoController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Nome é obrigatório' : null,
              ),
              TextFormField(
                controller: _contatoController,
                decoration: InputDecoration(labelText: 'Contato'),
                validator: (value) => value!.isEmpty ? 'Contato é obrigatório' : null,
              ),
              TextFormField(
                controller: _cpfcnpjController,
                decoration: InputDecoration(labelText: 'CPF ou CNPJ'),
                validator: (value) => value!.isEmpty ? 'CPF/CNPJ é obrigatório' : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: 'Endereço'),
                validator: (value) => value!.isEmpty ? 'Endereço é obrigatório' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email é obrigatório' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final cliente = Cliente(
                      nome: _nomeController.text,
                      contato: _contatoController.text,
                      cpfcnpj: _cpfcnpjController.text,
                      endereco: _enderecoController.text,
                      email: _emailController.text,
                      dataNascimento: DateTime.now(), // Aqui você pode adaptar para data de nascimento
                      dataCadastro: DateTime.now(),
                    );

                    if (widget.cliente == null) {
                      ClienteService().createCliente(cliente);
                    } else {
                      ClienteService().updateCliente(cliente);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.cliente == null ? 'Cadastrar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
