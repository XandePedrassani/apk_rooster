import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rooster/models/cliente_model.dart';
import 'package:rooster/models/status_model.dart';
import 'package:rooster/screens/relatorios_screen/relatorio_servicos_screen.dart';
import 'package:rooster/screens/relatorios_screen/resultados_mensais_screen.dart';
import 'package:rooster/services/cliente_service.dart';
import 'package:rooster/services/status_service.dart';

import '../../services/relatorio_service.dart';

class RelatorioServicosScreen extends StatefulWidget {
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? status;
  final Cliente? cliente;

  const RelatorioServicosScreen({
    Key? key,
    required this.dataInicio,
    required this.dataFim,
    this.status,
    this.cliente,
  }) : super(key: key);

  @override
  _RelatorioServicosScreenState createState() => _RelatorioServicosScreenState();
}

class _RelatorioServicosScreenState extends State<RelatorioServicosScreen> {
  final RelatorioService _relatorioService = RelatorioService();
  final StatusService _statusService = StatusService();
  bool _isLoading = true;
  List<dynamic> _servicos = [];
  int _totalServicos = 0;
  double _valorTotal = 0.0;
  String _errorMessage = '';
  Map<String, StatusModel> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Carregar status para exibição correta
      final statusList = await _statusService.getAllStatus();
      final statusMap = {for (var status in statusList) status.nome: status};
      
      // Carregar relatório
      final resultado = await _relatorioService.getRelatorioServicos(
        widget.dataInicio,
        widget.dataFim,
        widget.status,
        widget.cliente?.id,
      );

      setState(() {
        _servicos = resultado['servicos'];
        _totalServicos = resultado['totalServicos'];
        _valorTotal = resultado['valorTotal']?? 0.0;
        _statusMap = statusMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar relatório: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _compartilharRelatorio() async {
    // Implementação futura para compartilhar/exportar o relatório
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de exportação em desenvolvimento')),
    );
  }
  
  // Método para obter a cor do status
  Color _getStatusColor(String statusNome) {
    final status = _statusMap[statusNome];
    if (status != null && status.cor != null) {
      return _getColorFromHex(status.cor!);
    }
    
    // Cores padrão para compatibilidade
    switch (statusNome.toLowerCase()) {
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
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatoData = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Serviços'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Período: ${formatoData.format(widget.dataInicio)} - ${formatoData.format(widget.dataFim)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Total de serviços: $_totalServicos'),
                          const SizedBox(height: 4),
                          Text(
                            'Valor total: ${formatoMoeda.format(_valorTotal ?? 0.0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _servicos.isEmpty
                          ? const Center(child: Text('Nenhum serviço encontrado no período'))
                          : ListView.builder(
                              itemCount: _servicos.length,
                              itemBuilder: (context, index) {
                                final servico = _servicos[index];
                                final statusNome = servico['status'] is Map 
                                    ? servico['status']['nome'] 
                                    : servico['status'];
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Serviço #${servico['id']} - ${servico['cliente']['nome']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(servico['dtMovimento']))}'),
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(statusNome),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Text('Status: $statusNome'),
                                          ],
                                        ),
                                        Text(
                                          'Valor: ${formatoMoeda.format(servico['valorTotal']?? 0.0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      // Exibir detalhes do serviço
                                      _mostrarDetalhesServico(servico);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL: ${formatoMoeda.format(_valorTotal?? 0.0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _compartilharRelatorio,
                            icon: const Icon(Icons.share),
                            label: const Text('Exportar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  void _mostrarDetalhesServico(dynamic servico) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusNome = servico['status'] is Map 
        ? servico['status']['nome'] 
        : servico['status'];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do Serviço #${servico['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              Text('Cliente: ${servico['cliente']['nome']}'),
              Text('Data de Movimento: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(servico['dtMovimento']))}'),
              Text('Data de Entrega: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(servico['dtEntrega']))}'),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(statusNome),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text('Status: $statusNome'),
                ],
              ),
              Text('Usuário: ${servico['usuario']['nome']}'),
              if (servico['observacao'] != null)
                Text('Observação: ${servico['observacao']}'),
              const SizedBox(height: 16),
              const Text(
                'Produtos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: servico['produtos'].length,
                  itemBuilder: (context, index) {
                    final produto = servico['produtos'][index];
                    final valorTotal = produto['quantidade'] * produto['precoUnitario'];
                    
                    return ListTile(
                      title: Text(produto['produto']['nome']),
                      subtitle: Text(
                        '${produto['quantidade']} x ${formatoMoeda.format(produto['precoUnitario']?? 0.0)}',
                      ),
                      trailing: Text(
                        formatoMoeda.format(valorTotal?? 0.0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Valor Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatoMoeda.format(servico['valorTotal']?? 0.0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
