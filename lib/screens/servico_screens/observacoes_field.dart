import 'package:flutter/material.dart';

class ObservacoesField extends StatelessWidget {
  final TextEditingController obsController;

  ObservacoesField({
    required this.obsController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: obsController,
      maxLines: 3,
      decoration: InputDecoration(labelText: 'Observações'),
    );
  }
}
