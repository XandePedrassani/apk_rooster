import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../models/produto_model.dart';

class ProdutoService {
  final String baseUrl = 'http://localhost:8080/produtos';

  Future<List<Produto>> getProdutos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((json) => Produto.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar produtos');
    }
  }

  Future<void> createProduto(Produto produto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produto.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao criar produto');
    }
  }

  Future<void> updateProduto(Produto produto) async {
    final url = '$baseUrl/${produto.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar produto');
    }
  }

  Future<void> deleteProduto(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao excluir produto');
    }
  }
}
