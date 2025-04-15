import 'package:flutter/material.dart';
import '../../models/servico_model.dart';
import '../../services/servico_service.dart';
import 'servico_screen.dart';

class ServicosListScreen extends StatefulWidget {
  @override
  _ServicosListScreenState createState() => _ServicosListScreenState();
}

class _ServicosListScreenState extends State<ServicosListScreen> {
  List<Servico> _servicos = [];
  List<Servico> _filtrados = [];
  TextEditingController _buscaTextoController = TextEditingController();

  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _filtrarPorEntrega = true;
  String _statusSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    final servicos = await ServicoService().getServicos();
    setState(() {
      _servicos = servicos;
      _filtrar(); // já filtra assim que carrega
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
        final correspondeStatus = _statusSelecionado == 'Todos' || servico.status.toLowerCase() == _statusSelecionado.toLowerCase();

        final dataBase = _filtrarPorEntrega ? servico.dtEntrega : servico.dtMovimento;
        final dentroDoPeriodo = (_dataInicio == null || dataBase.isAfter(_dataInicio!.subtract(Duration(days: 1)))) &&
            (_dataFim == null || dataBase.isBefore(_dataFim!.add(Duration(days: 1))));

        return correspondeTexto && correspondeStatus && dentroDoPeriodo;
      }).toList();

      _filtrados.sort((a, b) => a.dtEntrega.compareTo(b.dtEntrega));
    });
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
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

  void _imprimir(Servico servico) {
    // Lógica de impressão aqui
    print('Imprimindo serviço ${servico.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviços')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo único de pesquisa
            TextField(
              controller: _buscaTextoController,
              decoration: InputDecoration(labelText: 'Buscar por ID, Cliente ou Observação'),
              onChanged: (_) => _filtrar(),
            ),
            SizedBox(height: 10),

            // Filtros por data e status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Período (${_filtrarPorEntrega ? 'Entrega' : 'Emissão'})'),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _selecionarData(context, true),
                            child: Text(_dataInicio == null
                                ? 'Início'
                                : '${_dataInicio!.day}/${_dataInicio!.month}/${_dataInicio!.year}'),
                          ),
                          Text(' até '),
                          TextButton(
                            onPressed: () => _selecionarData(context, false),
                            child: Text(_dataFim == null
                                ? 'Fim'
                                : '${_dataFim!.day}/${_dataFim!.month}/${_dataFim!.year}'),
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
                  items: ['Todos', 'Pendente', 'Pronto']
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

            // Lista de serviços
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
