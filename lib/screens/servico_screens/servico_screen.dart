import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../models/produto_model.dart';
import '../../models/servico_model.dart';
import '../../models/servico_produto_model.dart';
import '../../models/usuario.dart';
import '../../services/cliente_service.dart';
import '../../services/produto_service.dart';
import '../../services/servico_service.dart';
import '../../services/whatsapp_service.dart';
import '../cliente_screens/cliente_screen.dart';
import 'adicionar_produto_dialog.dart';
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
    final novoProduto = await mostrarAdicionarProdutoDialog(
      context: context,
      produtosDisponiveis: _produtos,
    );

    if (novoProduto != null) {
      setState(() {
        novoProduto.sequencia = _produtosAdicionados.length + 1;
        _produtosAdicionados.add(novoProduto);
      });
    }
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

    try {
      await ServicoService().organizaSequenciaProd(novoServico);
      if (widget.servico == null) {
        await ServicoService().criarServico(novoServico);
      } else {
        await ServicoService().atualizarServico(novoServico);
      }

      if (!mounted) return; // Verifique se o widget ainda está na árvore

      if (_status == 'pendente') {
        bool? desejaImprimir = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('O serviço foi salvo com sucesso!'),
              content: Text('Deseja imprimir agora?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Não'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Sim'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        // Se o usuário quiser imprimir, chama a função de imprimir
        if (desejaImprimir == true) {
          final service = ServicoService();

          final sucesso = await service.imprimirServico(novoServico.id!);

          if (sucesso && mounted) {
            print('Impressão enviada com sucesso!');
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impressão enviada com sucesso!')));
          } else if (mounted) {
            print('Falha ao enviar impressão.');
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao imprimir.')));
          }
        }
      } else if (novoServico.status != widget.servico?.status && (novoServico.status == 'pronto' || novoServico.status == 'pendente pagamento')) {
        bool? desejaEnviar = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Status atualizado com sucesso'),
              content: Text('Deseja avisar o cliente pelo WhatsApp?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Sim'),
                ),
              ],
            );
          },
        );

        if (desejaEnviar == true && mounted) {
          WhatsAppService.enviarMensagemServico(context, novoServico);
        }
      }

      if (mounted) {
        Navigator.pop(context); // Seguro chamar, pois estamos verificando se o widget ainda está montado
      }
    } catch (e) {
      print('Erro ao salvar o serviço: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar o serviço: $e')));
      }
    }
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
                onEditarProduto: (sp) async {
                  final editado = await mostrarAdicionarProdutoDialog(
                    context: context,
                    produtosDisponiveis: _produtos,
                    servicoProdutoExistente: sp, // precisa adaptar a função pra aceitar isso
                  );
                  if (editado != null) {
                    setState(() {
                      final index = _produtosAdicionados.indexOf(sp);
                      _produtosAdicionados[index] = editado;
                    });
                  }
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
