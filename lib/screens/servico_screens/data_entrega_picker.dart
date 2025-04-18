import 'package:flutter/material.dart';

class DataEntregaPicker extends StatelessWidget {
  final DateTime dataEntrega;
  final ValueChanged<DateTime> onDataEntregaChanged;

  const DataEntregaPicker({
    required this.dataEntrega,
    required this.onDataEntregaChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime hoje = DateTime.now();
        final DateTime initialDate = dataEntrega.isBefore(hoje) ? hoje : dataEntrega;

        final picked = await showDatePicker(
          context: context,
          initialDate: dataEntrega,
          firstDate: DateTime(2023),
          lastDate: DateTime(2100),
          locale: const Locale("pt", "BR"),
        );
        if (picked != null && picked != dataEntrega) {
          onDataEntregaChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data de Entrega',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${dataEntrega.toLocal().day.toString().padLeft(2, '0')}/'
                  '${dataEntrega.toLocal().month.toString().padLeft(2, '0')}/'
                  '${dataEntrega.toLocal().year}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}