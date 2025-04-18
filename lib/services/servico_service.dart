import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rooster/models/servico_model.dart';

import '../config.dart';

class ServicoService {
  final String baseUrl = AppConfig.baseUrl;
  Future<List<Servico>> getServicos() async {
    final response = await http.get(Uri.parse('$baseUrl/servicos/withProdutos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Servico.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar serviços');
    }
  }

  Future<Servico> getServicoPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/servicos/$id'));

    if (response.statusCode == 200) {
      return Servico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao carregar serviço');
    }
  }

  Future<void> criarServico(Servico servico) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servicos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(servico.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao criar serviço');
    }
    final responseData = json.decode(response.body);
    servico.id = responseData['id'];
  }

  Future<void> atualizarServico(Servico servico) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servicos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(servico.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar serviço');
    }
  }

  Future<void> excluirServico(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/servicos/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao excluir serviço');
    }
  }

  Future<void> marcarComoPronto(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servicos/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'pronto'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status do serviço');
    }
  }

  Future<void> deletarServico(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/servicos/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao excluir serviço');
    }
  }
  Future<bool> imprimirServico(int id) async {
    final url = Uri.parse('$baseUrl/impressao/$id');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao imprimir: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro na chamada da API: $e');
      return false;
    }
  }

  Future<bool> atualizarStatus(int id, String novoStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/servicos/$id/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': novoStatus}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao atualizar status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exceção ao atualizar status: $e');
      return false;
    }
  }

  organizaSequenciaProd(Servico novoServico) {
    for (int i = 0; i < novoServico.produtos.length; i++) {
      novoServico.produtos[i].sequencia = i+1;
    }
  }
}
