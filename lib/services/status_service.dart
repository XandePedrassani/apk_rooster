import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rooster/models/status_model.dart';

import '../config.dart';

class StatusService {
  final String baseUrl = AppConfig.baseUrl;
  
  Future<List<StatusModel>> getAllStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StatusModel.fromJson(json)).toList();
    } else {
      // Fallback para status padrão caso a API ainda não esteja implementada
      return [
        StatusModel(id: 1, nome: 'pendente', ordem: 1, cor: '#FFA500'),
        StatusModel(id: 2, nome: 'pronto', ordem: 2, cor: '#008000'),
        StatusModel(id: 3, nome: 'entregue', ordem: 3, cor: '#0000FF'),
        StatusModel(id: 4, nome: 'pendente pagamento', ordem: 4, cor: '#FF0000'),
      ];
    }
  }
  
  Future<StatusModel?> getStatusById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/status/$id'));
      
      if (response.statusCode == 200) {
        return StatusModel.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar status por ID: $e');
      return null;
    }
  }
  
  Future<StatusModel?> getStatusByNome(String nome) async {
    try {
      final allStatus = await getAllStatus();
      return allStatus.firstWhere(
        (status) => status.nome.toLowerCase() == nome.toLowerCase(),
        orElse: () => allStatus.first
      );
    } catch (e) {
      print('Erro ao buscar status por nome: $e');
      return null;
    }
  }
}
