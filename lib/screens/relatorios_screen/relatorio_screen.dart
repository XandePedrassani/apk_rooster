import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rooster/models/cliente_model.dart';
import 'package:rooster/screens/relatorios_screen/relatorio_servicos_screen.dart';
import 'package:rooster/screens/relatorios_screen/resultados_mensais_screen.dart';
import 'package:rooster/services/cliente_service.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({Key? key}) : super(key: key);

  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final ClienteService _clienteService = ClienteService();
  
  String _tipoRelatorio = 'servicos';
  DateTime _dataInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dataFim = DateTime.now();
  String _status = 'todos';
  Cliente? _clienteSelecionado;
  List<Cliente> _clientes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientes = await _clienteService.getClientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar clientes: $e')),
      );
    }
  }

  Future<void> _selecionarData(bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataInicio : _dataFim,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  void _gerarRelatorio() {
    if (_tipoRelatorio == 'servicos') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RelatorioServicosScreen(
            dataInicio: _dataInicio,
            dataFim: _dataFim,
            status: _status == 'todos' ? null : _status,
            cliente: _clienteSelecionado,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadosMensaisScreen(
            ano: _dataInicio.year,
            mes: _dataInicio.month,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipo de Relatório:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _tipoRelatorio,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'servicos',
                                child: Text('Serviços Executados'),
                              ),
                              DropdownMenuItem(
                                value: 'mensais',
                                child: Text('Resultados Mensais'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _tipoRelatorio = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_tipoRelatorio == 'servicos') ...[
                            const Text(
                              'Período:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selecionarData(true),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Data Inicial',
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM/yyyy').format(_dataInicio),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selecionarData(false),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Data Final',
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM/yyyy').format(_dataFim),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Status:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'todos',
                                  child: Text('Todos'),
                                ),
                                DropdownMenuItem(
                                  value: 'pendente',
                                  child: Text('Pendente'),
                                ),
                                DropdownMenuItem(
                                  value: 'pronto',
                                  child: Text('Pronto'),
                                ),
                                DropdownMenuItem(
                                  value: 'entregue',
                                  child: Text('Entregue'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Cliente (opcional):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Cliente?>(
                              value: _clienteSelecionado,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<Cliente?>(
                                  value: null,
                                  child: Text('Todos'),
                                ),
                                ..._clientes.map((cliente) {
                                  return DropdownMenuItem<Cliente>(
                                    value: cliente,
                                    child: Text(cliente.nome),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _clienteSelecionado = value;
                                });
                              },
                            ),
                          ] else ...[
                            const Text(
                              'Período:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selecionarData(true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Mês/Ano',
                                ),
                                child: Text(
                                  DateFormat('MM/yyyy').format(_dataInicio),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _gerarRelatorio,
                              child: const Text(
                                'GERAR RELATÓRIO',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
