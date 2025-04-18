import 'package:flutter/material.dart';
import 'package:rooster/screens/produto_screens/ProdutoListScreen.dart';
import 'package:rooster/screens/servico_screens/ServicosListScreen.dart';
import 'package:rooster/screens/cliente_screens/ClienteListScreen.dart';
import 'package:rooster/screens/config_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina da Moda'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMenuButton(
            context,
            label: 'Serviços',
            icon: Icons.build,
            color: Colors.orange,
            destination: ServicosListScreen(),
          ),
          _buildMenuButton(
            context,
            label: 'Clientes',
            icon: Icons.person,
            color: Colors.teal,
            destination: ClienteListScreen(),
          ),
          _buildMenuButton(
            context,
            label: 'Produtos',
            icon: Icons.shopping_bag,
            color: Colors.deepPurple,
            destination: ProdutoListScreen(),
          ),
          const SizedBox(height: 20),
          _buildConfigButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required Widget destination,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.grey),
        tooltip: 'Configurações',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConfigScreen()),
          );
        },
      ),
    );
  }
}
