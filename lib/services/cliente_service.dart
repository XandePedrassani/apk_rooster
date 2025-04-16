import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/cliente_model.dart';

class ClienteService {
  final String endpoint = "${AppConfig.baseUrl}/clientes";

  Future<List<Cliente>> getClientes() async {
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar clientes');
    }
  }

  Future<Cliente> getClienteById(int id) async {
    final response = await http.get(Uri.parse('$endpoint/$id'));
    if (response.statusCode == 200) {
      return Cliente.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao buscar cliente');
    }
  }

  Future<void> createCliente(Cliente cliente) async {
    final jsonData = cliente.toJson();
    print("JSON a ser enviado: $jsonData"); // Verifique se o JSON está correto

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData), // Certifique-se de que json.encode não está falhando
      );
      print("Resposta da API: ${response.statusCode} - ${response.body}");
      final responseData = json.decode(response.body);
      cliente.id = responseData['id'];
    } catch (e) {
      print("Erro na requisição: $e");
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    final response = await http.put(
      Uri.parse('$endpoint/${cliente.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar cliente');
    }
  }

  Future<void> deleteCliente(int id) async {
    final response = await http.delete(Uri.parse('$endpoint/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao excluir cliente');
    }
  }
}
