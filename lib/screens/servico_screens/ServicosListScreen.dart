import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/servico_model.dart';
import '../../services/servico_service.dart';
import '../../services/whatsapp_service.dart';
import 'servico_screen.dart';
// ... imports permanecem os mesmos

class ServicosListScreen extends StatefulWidget {
  @override
  _ServicosListScreenState createState() => _ServicosListScreenState();
}

class _ServicosListScreenState extends State<ServicosListScreen> {
  List<Servico> _servicos = [];
  List<Servico> _filtrados = [];
  TextEditingController _buscaTextoController = TextEditingController();

  DateTime? _dataFiltro;
  bool _filtrarPorEntrega = true;
  String _statusSelecionado = 'Pendente';

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    final servicos = await ServicoService().getServicos();
    setState(() {
      _servicos = servicos;
      _filtrar();
    });
  }

  void _filtrar() {
    final textoBusca = _buscaTextoController.text.toLowerCase();

    setState(() {
      _filtrados = _servicos.where((servico) {
        final textoId = servico.id.toString();
        final nomeCliente = servico.cliente.nome.toLowerCase();
        final observacao = (servico.observacao ?? '').toLowerCase();
        final textoCompleto = '$textoId $nomeCliente $observacao';

        final correspondeTexto = textoBusca.isEmpty || textoCompleto.contains(textoBusca);
        final correspondeStatus = _statusSelecionado == 'Todos' ||
            servico.status.toLowerCase() == _statusSelecionado.toLowerCase();

        final dataBase = _filtrarPorEntrega ? servico.dtEntrega : servico.dtMovimento;
        final correspondeData = _dataFiltro == null ||
            (dataBase.year == _dataFiltro!.year &&
                dataBase.month == _dataFiltro!.month &&
                dataBase.day == _dataFiltro!.day);

        return correspondeTexto && correspondeStatus && correspondeData;
      }).toList();

      _filtrados.sort((a, b) => a.dtEntrega.compareTo(b.dtEntrega));
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale("pt", "BR"),
    );
    if (picked != null) {
      setState(() {
        _dataFiltro = picked;
      });
      _filtrar();
    }
  }

  void _confirmarExclusao(Servico servico) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o serviço ${servico.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await ServicoService().deletarServico(servico.id!);
              Navigator.pop(context);
              _carregarServicos();
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _imprimir(Servico servico) async {
    final service = ServicoService();

    final sucesso = await service.imprimirServico(servico.id!);

    if (sucesso) {
      print('Impressão enviada com sucesso!');
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impressão enviada com sucesso!')));
    } else {
      print('Falha ao enviar impressão.');
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao imprimir.')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviços')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _buscaTextoController,
              decoration: InputDecoration(labelText: 'Buscar por ID, Cliente ou Observação'),
              onChanged: (_) => _filtrar(),
            ),
            SizedBox(height: 10),

            // Filtro por data única
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data (${_filtrarPorEntrega ? 'Entrega' : 'Emissão'})'),
                      Row(
                        children: [
                          Text(
                            _dataFiltro == null
                                ? 'Nenhuma data selecionada'
                                : '${_dataFiltro!.day}/${_dataFiltro!.month}/${_dataFiltro!.year}',
                          ),
                          IconButton(
                            onPressed: () => _selecionarData(context),
                            icon: Icon(Icons.calendar_month_outlined),
                          ),
                          if (_dataFiltro != null)
                            TextButton(
                              onPressed: () {
                                setState(() => _dataFiltro = null);
                                _filtrar();
                              },
                              child: Text("Limpar"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _filtrarPorEntrega,
                  onChanged: (val) {
                    setState(() => _filtrarPorEntrega = val);
                    _filtrar();
                  },
                ),
                Text(_filtrarPorEntrega ? 'Entrega' : 'Emissão'),
              ],
            ),

            // Filtro de status
            Row(
              children: [
                Text('Status: '),
                DropdownButton<String>(
                  value: _statusSelecionado,
                  items: ['Todos', 'Pendente', 'Pronto', 'Pendente Pagamento']
                      .map((status) => DropdownMenuItem(
                    child: Text(status),
                    value: status,
                  ))
                      .toList(),
                  onChanged: (valor) {
                    setState(() => _statusSelecionado = valor!);
                    _filtrar();
                  },
                ),
              ],
            ),

            Divider(),

            Expanded(
              child: _filtrados.isEmpty
                  ? Center(child: Text('Nenhum serviço encontrado'))
                  : ListView.builder(
                itemCount: _filtrados.length,
                itemBuilder: (_, index) {
                  final servico = _filtrados[index];
                  return Card(
                    child: ListTile(
                      title: Text('Serviço #${servico.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${servico.cliente.nome} | ${servico.status} | Entrega: ${servico.dtEntrega.toLocal().toString().split(" ")[0]}'),
                          SizedBox(height: 4),
                          Text('Observação: ${servico.observacao ?? "Sem observação"}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                            onPressed: () => WhatsAppService.enviarMensagemServico(context, servico),
                          ),
                          IconButton(
                            icon: Icon(Icons.print),
                            onPressed: () => _imprimir(servico),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServicoScreen(servico: servico),
                                ),
                              );
                              _carregarServicos();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmarExclusao(servico),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicoScreen(servico: servico),
                          ),
                        ).then((_) => _carregarServicos());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServicoScreen(),
            ),
          );
          _carregarServicos();
        },
        child: Icon(Icons.add),
        tooltip: 'Novo Serviço',
      ),
    );
  }
}


