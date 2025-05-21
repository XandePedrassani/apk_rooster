import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rooster/models/cliente_model.dart';

import '../config.dart';


class RelatorioService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> getRelatorioServicos(
    DateTime dataInicio,
    DateTime dataFim,
    String? status,
    int? idCliente,
  ) async {
    final queryParams = {
      'dataInicio': dataInicio.toIso8601String().split('T')[0],
      'dataFim': dataFim.toIso8601String().split('T')[0],
    };

    if (status != null && status != 'todos') {
      queryParams['status'] = status;
    }

    if (idCliente != null) {
      queryParams['idCliente'] = idCliente.toString();
    }

    final uri = Uri.parse('$baseUrl/relatorios/servicos').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar relatório de serviços: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getResultadosMensais(int ano, int mes) async {
    final uri = Uri.parse('$baseUrl/relatorios/resultados-mensais').replace(
      queryParameters: {
        'ano': ano.toString(),
        'mes': mes.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar resultados mensais: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getProdutosEstatisticas(
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    final uri = Uri.parse('$baseUrl/relatorios/produtos-estatisticas').replace(
      queryParameters: {
        'dataInicio': dataInicio.toIso8601String().split('T')[0],
        'dataFim': dataFim.toIso8601String().split('T')[0],
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar estatísticas de produtos: ${response.statusCode}');
    }
  }
}
