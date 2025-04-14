import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';

class ClienteDropdownField extends StatefulWidget {
  final List<Cliente> clientes;
  final Cliente? clienteSelecionado;
  final ValueChanged<Cliente?> onClienteSelecionado;
  final Future<Cliente?> Function() onNovoClienteCadastrado;

  const ClienteDropdownField({
    required this.clientes,
    required this.clienteSelecionado,
    required this.onClienteSelecionado,
    required this.onNovoClienteCadastrado,
    Key? key,
  }) : super(key: key);

  @override
  _ClienteDropdownFieldState createState() => _ClienteDropdownFieldState();
}

class _ClienteDropdownFieldState extends State<ClienteDropdownField> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Future<void> _mostrarDialogoPesquisa(BuildContext context) async {
    List<Cliente> clientesFiltrados = widget.clientes;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pesquisar Cliente'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        clientesFiltrados = widget.clientes
                            .where((cliente) => cliente.nome
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: clientesFiltrados.length,
                        itemBuilder: (context, index) {
                          final cliente = clientesFiltrados[index];
                          return ListTile(
                            title: Text(cliente.nome),
                            onTap: () {
                              widget.onClienteSelecionado(cliente);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Cadastrar novo cliente',
                  onPressed: () async {
                    Navigator.pop(context);
                    await _cadastrarNovoCliente(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cadastrarNovoCliente(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final novoCliente = await widget.onNovoClienteCadastrado();
      if (novoCliente != null) {
        widget.onClienteSelecionado(novoCliente);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${novoCliente.nome} cadastrado e selecionado!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _isLoading ? null : () => _mostrarDialogoPesquisa(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.search),
                  ),
                  child: Text(
                    widget.clienteSelecionado?.nome ?? 'Selecione um cliente',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.clienteSelecionado == null
                          ? Theme.of(context).hintColor
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Cadastrar novo cliente',
                onPressed: () => _cadastrarNovoCliente(context),
              ),
          ],
        ),
        if (widget.clienteSelecionado != null && !_isLoading)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onClienteSelecionado(null),
              child: const Text('Limpar seleção'),
            ),
          ),
      ],
    );
  }
}