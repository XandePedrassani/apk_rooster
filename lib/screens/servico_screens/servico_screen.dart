import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../models/produto_model.dart';
import '../../models/servico_model.dart';
import '../../models/servico_produto_model.dart';
import '../../models/usuario.dart';
import '../../services/cliente_service.dart';
import '../../services/produto_service.dart';
import '../../services/servico_service.dart';
import '../cliente_screens/cliente_screen.dart';
import 'cliente_dropdown_field.dart';
import 'status_dropdown_field.dart';
import 'data_entrega_picker.dart';
import 'observacoes_field.dart';
import 'produtos_list_section.dart';

class ServicoScreen extends StatefulWidget {
  final Servico? servico;

  ServicoScreen({this.servico});

  @override
  _ServicoScreenState createState() => _ServicoScreenState();
}

class _ServicoScreenState extends State<ServicoScreen> {
  final _formKey = GlobalKey<FormState>();

  Cliente? _clienteSelecionado;
  String _status = 'pendente';
  DateTime _dtEntrega = DateTime.now();
  TextEditingController _obsController = TextEditingController();

  List<ServicoProduto> _produtosAdicionados = [];
  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _carregarClientesEProdutos();

    if (widget.servico != null) {
      _clienteSelecionado = widget.servico!.cliente;
      _status = widget.servico!.status;
      _dtEntrega = widget.servico!.dtEntrega;
      _obsController.text = widget.servico!.observacao ?? '';
      _produtosAdicionados = List.from(widget.servico!.produtos);
    }
  }

  Future<void> _carregarClientesEProdutos() async {
    final clientes = await ClienteService().getClientes();
    final produtos = await ProdutoService().getProdutos();
    setState(() {
      _clientes = clientes;
      _produtos = produtos;
    });
  }

  void _adicionarProduto() async {
    Produto? produtoSelecionado;
    int quantidade = 1;
    double preco = 0.00;
    TextEditingController precoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adicionar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Produto>(
              items: _produtos
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.nome),
              ))
                  .toList(),
              onChanged: (value) {
                produtoSelecionado = value;
                precoController.text = value?.preco.toStringAsFixed(2) ?? '';
              },
              decoration: InputDecoration(labelText: 'Produto'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade'),
              initialValue: '1',
              onChanged: (val) => quantidade = int.tryParse(val) ?? 1,
            ),
            TextFormField(
              controller: precoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Preço Unitário'),
              onChanged: (val) => preco = double.parse(val),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Adicionar'),
            onPressed: () {
              if (produtoSelecionado != null) {
                setState(() {
                  _produtosAdicionados.add(ServicoProduto(
                    produto: produtoSelecionado!,
                    quantidade: quantidade,
                    precoUnitario: preco,
                    sequencia: _produtosAdicionados.length + 1,
                  ));
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _salvarServico() async {
    if (!_formKey.currentState!.validate() || _clienteSelecionado == null) return;

    final novoServico = Servico(
      id: widget.servico?.id,
      dtMovimento: DateTime.now(),
      dtEntrega: _dtEntrega,
      cliente: _clienteSelecionado!,
      status: _status,
      observacao: _obsController.text,
      produtos: _produtosAdicionados,
      usuario: Usuario(id: 1, nome: "Alexandre"),
    );

    if (widget.servico == null) {
      await ServicoService().criarServico(novoServico);
    } else {
      await ServicoService().atualizarServico(novoServico);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.servico == null ? 'Novo Serviço' : 'Editar Serviço')),
      body: _clientes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClienteDropdownField(
                  clientes: _clientes,
                  clienteSelecionado: _clienteSelecionado,
                  onClienteSelecionado: (val) => setState(() => _clienteSelecionado = val),
                  onNovoClienteCadastrado: () async {
                    final novoCliente = await Navigator.push<Cliente>(
                      context,
                      MaterialPageRoute(builder: (context) => ClienteScreen()),
                    );
                    _clientes.add(novoCliente!);
                    return novoCliente;
                  },
                ),
                SizedBox(height: 10),
                StatusDropdownField(
                  status: _status,
                  onStatusChanged: (val) => setState(() => _status = val!),
                ),
                SizedBox(height: 10),
                DataEntregaPicker(
                  dataEntrega: _dtEntrega,
                  onDataEntregaChanged: (val) => setState(() => _dtEntrega = val),
                ),
                ObservacoesField(
                  obsController: _obsController,
                ),
                Divider(),
                ProdutosListSection(
                  produtosAdicionados: _produtosAdicionados,
                  onAdicionarProduto: _adicionarProduto,
                  onRemoverProduto: (sp) {
                    setState(() => _produtosAdicionados.remove(sp));
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarServico,
                  child: Text('Salvar'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
