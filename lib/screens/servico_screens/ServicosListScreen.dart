import 'dart:async';

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
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  final statusService = StatusService();

  // Controlador de scroll para detectar quando chegou ao final da lista
  ScrollController _scrollController = ScrollController();
  
  // Timer para debounce na busca
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _inicializarTela();

    _carregarDados();
    
    // Adicionar listener para detectar quando o usuário chega ao final da lista
    _scrollController.addListener(_scrollListener);
    
    // Adicionar listener para debounce na busca
    _buscaTextoController.addListener(_onSearchChanged);
  }

  Future<void> _inicializarTela() async {
    _statusSelecionado = await statusService.getStatusByOrdem(1);
  }
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _buscaTextoController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  // Método para debounce na busca
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetAndReload();
    });
  }
  
  // Método para detectar quando chegou ao final da lista
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading && !_isLoadingMore && _hasMoreData) {
      _carregarMaisDados();
    }
  }

  // Método para resetar e recarregar dados
  void _resetAndReload() {
    setState(() {
      _currentPage = 0;
      _servicos = [];
      _filtrados = [];
      _hasMoreData = true;
    });
    _carregarDados();
  }

  // Método para carregar dados iniciais
  Future<void> _carregarDados() async {
    if (!_hasMoreData) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final statusList = await statusService.getAllStatus();
      
      // Carregar serviços com paginação
      final servicosPage = await ServicoService().getServicosPaginados(
        page: _currentPage,
        size: _pageSize,
        statusId: _statusSelecionado?.id,
        dataEntrega: _dataFiltro,
        filtrarPorEntrega: _filtrarPorEntrega,
        textoBusca: _buscaTextoController.text
      );
      
      setState(() {
        _statusList = statusList;
        
        // Adicionar novos serviços à lista existente
        _servicos.addAll(servicosPage.content);
        
        // Verificar se há mais páginas
        _hasMoreData = !servicosPage.last;
        
        // Incrementar página atual
        _currentPage++;
        
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
  
  // Método para carregar mais dados (próxima página)
  Future<void> _carregarMaisDados() async {
    if (!_hasMoreData || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      // Carregar próxima página de serviços
      final servicosPage = await ServicoService().getServicosPaginados(
        page: _currentPage,
        size: _pageSize,
        statusId: _statusSelecionado?.id,
        dataEntrega: _dataFiltro,
        filtrarPorEntrega: _filtrarPorEntrega,
        textoBusca: _buscaTextoController.text
      );
      
      setState(() {
        // Adicionar novos serviços à lista existente
        _servicos.addAll(servicosPage.content);
        
        // Verificar se há mais páginas
        _hasMoreData = !servicosPage.last;
        
        // Incrementar página atual
        _currentPage++;
        
        _isLoadingMore = false;
      });
      
      _filtrar();
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar mais dados: $e')),
      );
    }
  }

  // Método para filtrar serviços localmente (após carregados)
  void _filtrar() {
    setState(() {
      _filtrados = _servicos;
      
      // Ordenar por data de entrega
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
      _resetAndReload();
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
              _resetAndReload();
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
    } else {
      print('Falha ao enviar impressão.');
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
      body: _isLoading && _servicos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _resetAndReload();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Campo de busca
                    TextField(
                      controller: _buscaTextoController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por ID, Cliente ou Observação',
                        suffixIcon: _buscaTextoController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _buscaTextoController.clear();
                                  _resetAndReload();
                                },
                              )
                            : null,
                      ),
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
                                        _resetAndReload();
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
                            _resetAndReload();
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
                            _resetAndReload();
                          },
                        ),
                      ],
                    ),
                    
                    // Chips para filtros ativos
                    if (_statusSelecionado != null || _dataFiltro != null || _buscaTextoController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            if (_statusSelecionado != null)
                              Chip(
                                label: Text(_statusSelecionado!.nome),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() => _statusSelecionado = null);
                                  _resetAndReload();
                                },
                              ),
                            if (_dataFiltro != null)
                              Chip(
                                label: Text('${_dataFiltro!.day}/${_dataFiltro!.month}/${_dataFiltro!.year}'),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() => _dataFiltro = null);
                                  _resetAndReload();
                                },
                              ),
                          ],
                        ),
                      ),
                    
                    Divider(),
                    
                    // Lista de serviços
                    Expanded(
                      child: _filtrados.isEmpty && !_isLoading
                          ? Center(child: Text('Nenhum serviço encontrado'))
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _filtrados.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (_, index) {
                                // Mostrar indicador de carregamento no final da lista
                                if (index >= _filtrados.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                final servico = _filtrados[index];
                                return Card(
                                  child: ListTile(
                                    title: Text('Serviço #${servico.id}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(servico),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Text(servico.status.nome),
                                          ],
                                        ),
                                        Text('Cliente: ${servico.cliente.nome}'),
                                        Text('Entrega: ${servico.dtEntrega.day}/${servico.dtEntrega.month}/${servico.dtEntrega.year}'),
                                        if (servico.observacao != null && servico.observacao!.isNotEmpty)
                                          Text('Obs: ${servico.observacao}'),
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
                                            _resetAndReload();
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => _confirmarExclusao(servico),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ServicoScreen(servico: servico),
                                        ),
                                      );
                                      _resetAndReload();
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServicoScreen(),
            ),
          );
          _resetAndReload();
        },
      ),
    );
  }
}
