import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('base_url');
    if (savedUrl != null) {
      _urlController.text = savedUrl;
      AppConfig.setBaseUrl(savedUrl);
    }
  }

  Future<void> _saveUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newUrl = _urlController.text.trim();
    await prefs.setString('base_url', newUrl);
    AppConfig.setBaseUrl(newUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL base salva com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurar URL")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "URL Base da API",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUrl,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
