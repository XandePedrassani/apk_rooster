import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:rooster/models/servico_model.dart';
import 'package:rooster/models/status_model.dart';
import '../config.dart';

// Modelo para representar uma página de resultados
class PageResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final int number;
  final int size;

  PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.number,
    required this.size,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final List<dynamic> contentJson = json['content'] ?? [];
    return PageResponse(
      content: contentJson.map((item) => fromJson(item)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      number: json['number'] ?? 0,
      size: json['size'] ?? 20,
    );
  }
}

class ServicoService {
  final String baseUrl = AppConfig.baseUrl;

  // Método original (mantido para compatibilidade)
  Future<List<Servico>> getServicos() async {
    final response = await http.get(Uri.parse('$baseUrl/servicos/withProdutos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Servico.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar serviços');
    }
  }

  // Novo método com paginação e filtros
  Future<PageResponse<Servico>> getServicosPaginados({
    required int page,
    required int size,
    int? statusId,
    DateTime? dataEntrega,
    bool filtrarPorEntrega = true,
    String? textoBusca,
    String sort = 'dtEntrega',
  }) async {
    // Construir URL com parâmetros de query
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
    };

    // Adicionar parâmetros opcionais se fornecidos
    if (statusId != null) {
      queryParams['statusId'] = statusId.toString();
    }

    if (dataEntrega != null) {
      // Formatar data como ISO 8601 (YYYY-MM-DD)
      queryParams['dataEntrega'] = '${dataEntrega.year}-${dataEntrega.month.toString().padLeft(2, '0')}-${dataEntrega.day.toString().padLeft(2, '0')}';
    }

    if (textoBusca != null && textoBusca.isNotEmpty) {
      queryParams['textoBusca'] = textoBusca;
    }

    // Adicionar parâmetro para indicar se filtra por data de entrega ou emissão
    queryParams['filtrarPorEntrega'] = filtrarPorEntrega.toString();

    final uri = Uri.parse('$baseUrl/servicos/paginados').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return PageResponse.fromJson(data, Servico.fromJson);
    } else {
      throw Exception('Erro ao carregar serviços paginados: ${response.statusCode}');
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
    // Buscar o status "pronto" pelo nome
    final statusResponse = await http.get(Uri.parse('$baseUrl/status'));
    if (statusResponse.statusCode != 200) {
      throw Exception('Erro ao buscar status');
    }
    final List<dynamic> statusList = jsonDecode(statusResponse.body);
    final prontoStatus = statusList.firstWhere(
      (status) => status['nome'] == 'pronto',
      orElse: () => null
    );
    if (prontoStatus == null) {
      throw Exception('Status "pronto" não encontrado');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/servicos/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statusId': prontoStatus['id']}),
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

  Future<bool> atualizarStatus(int id, StatusModel novoStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/servicos/$id/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statusId': novoStatus.id}),
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
