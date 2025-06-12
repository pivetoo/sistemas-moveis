import 'dart:convert';
import '../models/ordem_servico.dart';
import '../services/services.dart';

class OrdemServicoRepository {
  Future<List<OrdemServico>> buscarMinhasOrdens() async {
    try {
      final response = await ApiService.get('ordemservico/minhas-ordens');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => OrdemServico.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Erro ao buscar ordens de serviço';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao buscar ordens de serviço');
    }
  }

  Future<Map<String, dynamic>> buscarOrdensComFiltros([Map<String, String>? filtros]) async {
    try {
      final params = {
        'page': '1',
        'pageSize': '50',
        ...?filtros,
      };

      final response = await ApiService.get('ordemservico/minhas-ordens-filtradas', params: params);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['ordens'] != null) {
          final ordens = (data['ordens'] as List<dynamic>)
              .map((json) => OrdemServico.fromJson(json))
              .toList();
          data['ordens'] = ordens;
        }

        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Erro ao aplicar filtros';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao aplicar filtros');
    }
  }

  Future<OrdemServico> buscarOrdemPorId(int id) async {
    try {
      final response = await ApiService.get('ordemservico/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrdemServico.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Erro ao buscar ordem de serviço';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao buscar ordem de serviço');
    }
  }

  Future<OrdemServico> concluirOrdem(int id) async {
    try {
      final response = await ApiService.patch('ordemservico/$id/concluir');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrdemServico.fromJson(data);
      } else {
        await _handleErrorResponse(response);
        throw Exception('Erro inesperado');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao concluir ordem de serviço');
    }
  }

  Future<OrdemServico> atualizarStatusOrdem(int id, int novoStatus) async {
    try {
      final response = await ApiService.patch(
        'ordemservico/$id',
        body: {'status': novoStatus},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrdemServico.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Erro ao atualizar ordem de serviço';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao atualizar ordem de serviço');
    }
  }

  Future<OrdemServico> iniciarAtendimento(int id) async {
    try {
      final response = await ApiService.patch('ordemservico/$id/iniciar-atendimento');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrdemServico.fromJson(data);
      } else {
        await _handleErrorResponse(response);
        throw Exception('Erro inesperado');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao iniciar atendimento');
    }
  }

  Future<void> _handleErrorResponse(response) async {
    try {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'];

      switch (response.statusCode) {
        case 400:
          throw Exception(errorMessage ?? 'Requisição inválida');
        case 401:
          throw Exception('Sessão expirada');
        case 403:
          throw Exception('Você não tem permissão para realizar esta ação');
        case 404:
          throw Exception('Ordem de serviço não encontrada');
        case 500:
          throw Exception(errorMessage ?? 'Erro interno do servidor');
        default:
          throw Exception(errorMessage ?? 'Erro desconhecido');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro na comunicação com o servidor');
    }
  }
}

final ordemServicoRepository = OrdemServicoRepository();