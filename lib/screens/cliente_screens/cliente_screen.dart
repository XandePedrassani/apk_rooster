import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';

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
  late TextEditingController _dataNascimentoController;
  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nomeController = TextEditingController(text: widget.cliente!.nome);
      _contatoController = TextEditingController(text: widget.cliente!.contato);
      _cpfcnpjController = TextEditingController(text: widget.cliente!.cpfcnpj);
      _enderecoController = TextEditingController(text: widget.cliente!.endereco);
      _emailController = TextEditingController(text: widget.cliente!.email);
      _dataNascimento = widget.cliente!.dataNascimento;
      _dataNascimentoController = TextEditingController(
        text: _dataNascimento != null
            ? "${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}"
            : '',
      );
    } else {
      _nomeController = TextEditingController();
      _contatoController = TextEditingController();
      _cpfcnpjController = TextEditingController();
      _enderecoController = TextEditingController();
      _emailController = TextEditingController();
      _dataNascimentoController = TextEditingController();
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
          child: SingleChildScrollView(
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
                  decoration: InputDecoration(labelText: 'CPF ou CNPJ')
                ),
                TextFormField(
                  controller: _enderecoController,
                  decoration: InputDecoration(labelText: 'Endereço')
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  readOnly: true,
                  controller: _dataNascimentoController,
                  decoration: InputDecoration(labelText: 'Data de Nascimento'),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _dataNascimento ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _dataNascimento = picked;
                        _dataNascimentoController.text =
                        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final cliente = Cliente(
                        id: widget.cliente?.id,
                        nome: _nomeController.text,
                        contato: _contatoController.text,
                        cpfcnpj: _cpfcnpjController.text,
                        endereco: _enderecoController.text,
                        email: _emailController.text,
                        dataNascimento: _dataNascimento,
                        dataCadastro: DateTime.now(),
                      );

                      try {
                        if (widget.cliente == null) {
                          await ClienteService().createCliente(cliente);
                        } else {
                          await ClienteService().updateCliente(cliente);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar cliente: $e')),
                        );
                      }
                    }
                  },
                  child: Text(widget.cliente == null ? 'Cadastrar' : 'Atualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
