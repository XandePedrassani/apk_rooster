import 'package:flutter/material.dart';
import 'package:rooster/models/cliente_model.dart';
import '../../services/cliente_service.dart';
import 'cliente_screen.dart';


class ClienteListScreen extends StatefulWidget {
  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  bool _isLoading = true;
  String _busca = '';
  String _ordenacao = 'nome'; // ou 'dataCadastro'

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    try {
      _clientes = await ClienteService().getClientes();
      _aplicarFiltroOrdenacao();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao carregar clientes'),
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltroOrdenacao() {
    List<Cliente> lista = _clientes.where((cliente) {
      return cliente.nome.toLowerCase().contains(_busca.toLowerCase());
    }).toList();

    lista.sort((a, b) {
      if (_ordenacao == 'nome') {
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      } else {
        return b.dataCadastro.compareTo(a.dataCadastro);
      }
    });

    setState(() => _clientesFiltrados = lista);
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirma a exclusão?'),
        content: Text('Essa ação não poderá ser desfeita.'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Excluir'),
            onPressed: () async {
              Navigator.pop(context);
              await ClienteService().deleteCliente(id);
              await _carregarClientes();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _ordenacao = value;
                _aplicarFiltroOrdenacao();
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'nome', child: Text('Ordenar por Nome')),
              PopupMenuItem(value: 'dataCadastro', child: Text('Mais Recentes')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar cliente pelo nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  _busca = value;
                  _aplicarFiltroOrdenacao();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _clientesFiltrados.isEmpty
                ? Center(child: Text('Nenhum cliente encontrado.'))
                : ListView.builder(
              itemCount: _clientesFiltrados.length,
              itemBuilder: (context, index) {
                final cliente = _clientesFiltrados[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(cliente.nome),
                    subtitle: Text(cliente.email ?? 'E-mail não informado'),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClienteScreen(cliente: cliente),
                            ),
                          ).then((_) => _carregarClientes());
                        } else if (value == 'delete') {
                          _confirmarExclusao(cliente.id!);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClienteScreen(cliente: cliente),
                        ),
                      ).then((_) => _carregarClientes());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClienteScreen()),
          ).then((_) => _carregarClientes());
        },
      ),
    );
  }
}
