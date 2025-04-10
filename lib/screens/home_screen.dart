import 'package:flutter/material.dart';
import 'cliente_screen.dart'; // Tela de cadastro/edição de clientes

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClienteScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Cadastro de Clientes'),
            ),
            SizedBox(height: 20),
            // Adicionar mais botões se necessário (ex: Relatórios, Configurações)
          ],
        ),
      ),
    );
  }
}
