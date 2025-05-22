import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/servico_model.dart';
import '../../models/status_model.dart';
import '../../services/servico_service.dart';
import '../../services/status_service.dart';
import '../../services/whatsapp_service.dart';
import 'servico_screen.dart';

class ServicosListScreen extends StatefulWidget {
  @override
  _ServicosListScreenState createState() => _ServicosListScreenState();
}

class _ServicosListScreenState extends State<ServicosListScreen> {
  List<Servico> _servicos = [];
  List<Servico> _filtrados = [];
  List<StatusModel> _statusList = [];
  TextEditingController _buscaTextoController = TextEditingController();

  DateTime? _dataFiltro;
  bool _filtrarPorEntrega = true;
  StatusModel? _statusSelecionado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Carregar status dinamicamente
      final statusService = StatusService();
      final statusList = await statusService.getAllStatus();
      
      // Carregar serviços
      final servicos = await ServicoService().getServicos();
      
      setState(() {
        _statusList = statusList;
        _servicos = servicos;
        
        // Definir status padrão como "Todos"
        _statusSelecionado = null; // null representa "Todos"
        
        _isLoading = false;
      });
      
      _filtrar();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
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
        
        // Filtro de status dinâmico
        final correspondeStatus = _statusSelecionado == null || 
            (servico.status.id == _statusSelecionado!.id);

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
              _carregarDados();
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
  
  // Método para obter a cor do status
  Color _getStatusColor(Servico servico) {
    if (servico.status.cor != null) {
      return _getColorFromHex(servico.status.cor!);
    }
    
    // Cores padrão para compatibilidade
    switch (servico.status.nome.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'pronto':
        return Colors.green;
      case 'entregue':
        return Colors.blue;
      case 'pendente pagamento':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviços')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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

            // Filtro de status dinâmico
            Row(
              children: [
                Text('Status: '),
                DropdownButton<StatusModel?>(
                  value: _statusSelecionado,
                  items: [
                    DropdownMenuItem<StatusModel?>(
                      child: Text('Todos'),
                      value: null,
                    ),
                    ..._statusList.map((status) => DropdownMenuItem(
                      child: Row(
                        children: [
                          if (status.cor != null)
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _getColorFromHex(status.cor!),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(status.nome[0].toUpperCase() + status.nome.substring(1)),
                        ],
                      ),
                      value: status,
                    )).toList(),
                  ],
                  onChanged: (valor) {
                    setState(() => _statusSelecionado = valor);
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
                          Row(
                            children: [
                              /*Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(servico),
                                  shape: BoxShape.circle,
                                ),
                              ),*/
                              Expanded(
                                child: Text(
                                  '${servico.cliente.nome} | ${servico.status.nome} | Entrega: ${servico.dtEntrega.toLocal().toString().split(" ")[0]}'
                                ),
                              ),
                            ],
                          ),
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
                              _carregarDados();
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
                        ).then((_) => _carregarDados());
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
          _carregarDados();
        },
        child: Icon(Icons.add),
        tooltip: 'Novo Serviço',
      ),
    );
  }
}
