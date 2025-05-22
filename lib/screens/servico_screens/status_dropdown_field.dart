import 'package:flutter/material.dart';
import 'package:rooster/models/status_model.dart';
import 'package:rooster/services/status_service.dart';

class StatusDropdownField extends StatefulWidget {
  final StatusModel? status;
  final ValueChanged<StatusModel?> onStatusChanged;
  final bool enabled;

  const StatusDropdownField({
    this.status,
    required this.onStatusChanged,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  _StatusDropdownFieldState createState() => _StatusDropdownFieldState();
}

class _StatusDropdownFieldState extends State<StatusDropdownField> {
  final StatusService _statusService = StatusService();
  List<StatusModel> _statusList = [];
  StatusModel? _selectedStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statusList = await _statusService.getAllStatus();
      setState(() {
        _statusList = statusList;
        
        // Definir o status selecionado com base no parâmetro
        if (widget.status != null) {
          _selectedStatus = widget.status;
        } else if (statusList.isNotEmpty) {
          _selectedStatus = statusList.first;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Status',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Carregando status...'),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: widget.enabled ? () => _showStatusSelection(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Status',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (_selectedStatus?.cor != null)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _getColorFromHex(_selectedStatus!.cor!),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  _selectedStatus != null
                      ? _selectedStatus!.nome[0].toUpperCase() + _selectedStatus!.nome.substring(1)
                      : 'Selecione o status',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedStatus == null
                        ? Theme.of(context).hintColor
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelection(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<StatusModel>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height * 2,
      ),
      items: _statusList.map((status) {
        return PopupMenuItem<StatusModel>(
          value: status,
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
        );
      }).toList(),
    ).then((value) async {
      if (value != null) {
        setState(() {
          _selectedStatus = value;
        });
        widget.onStatusChanged(value);
      }
    });
  }
  
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
