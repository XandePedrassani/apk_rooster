import 'package:flutter/material.dart';

import '../../models/servico_model.dart';
import '../../services/whatsapp_service.dart';

class StatusDropdownField extends StatelessWidget {
  final String? status;
  final ValueChanged<String?> onStatusChanged;
  final Servico? servico;
  final bool enabled;

  const StatusDropdownField({
    required this.status,
    required this.onStatusChanged,
    this.servico,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showStatusSelection(context) : null,
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
            Text(
              status != null
                  ? status![0].toUpperCase() + status!.substring(1)
                  : 'Selecione o status',
              style: TextStyle(
                fontSize: 16,
                color: status == null
                    ? Theme.of(context).hintColor
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelection(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height * 2,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'pendente',
          child: Text('Pendente'),
        ),
        const PopupMenuItem<String>(
          value: 'pronto',
          child: Text('Pronto'),
        ),
        const PopupMenuItem<String>(
          value: 'pendente pagamento',
          child: Text('Pendente Pagamento'),
        ),
      ],
    ).then((value) async {
      if (value != null) {
        onStatusChanged(value);
      }
    });
  }

}