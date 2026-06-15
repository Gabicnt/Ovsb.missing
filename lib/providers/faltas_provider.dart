import 'package:flutter/foundation.dart';
import '../models/falta.dart';
import '../services/database_service.dart';

/// Provider para gerenciar faltas
class FaltasProvider extends ChangeNotifier {
  List<Falta> _faltas = [];
  bool _isLoading = false;
  int? _currentPeriodoId;

  List<Falta> get faltas => _faltas;
  bool get isLoading => _isLoading;

  /// Carrega faltas de um período
  Future<void> loadFaltas(int periodoId) async {
    _isLoading = true;
    _currentPeriodoId = periodoId;
    notifyListeners();

    try {
      final faltasData = await DatabaseService.instance.getFaltas(periodoId);
      _faltas = faltasData.map((f) => Falta.fromMap(f)).toList();
    } catch (e) {
      print('Erro ao carregar faltas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona uma falta
  Future<void> addFalta({
    required int periodoId,
    required String data,
    required String tipo,
  }) async {
    try {
      // Verificar se já existe falta nesta data
      final existing = await DatabaseService.instance.getFaltaByData(periodoId, data);
      if (existing != null) {
        return; // Já existe
      }

      final falta = Falta(
        id: 0,
        periodoId: periodoId,
        data: data,
        tipo: tipo,
      );

      final map = falta.toMap();
      map.remove('id');
      final id = await DatabaseService.instance.insertFalta(map);

      _faltas.add(falta.copyWith(id: id));
      _faltas.sort((a, b) => a.data.compareTo(b.data));
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar falta: $e');
    }
  }

  /// Remove uma falta por ID
  Future<void> removeFalta(int id) async {
    try {
      await DatabaseService.instance.deleteFalta(id);
      _faltas.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover falta: $e');
    }
  }

  /// Remove falta por data
  Future<void> removeFaltaByData(int periodoId, String data) async {
    try {
      await DatabaseService.instance.deleteFaltaByData(periodoId, data);
      _faltas.removeWhere((f) => f.periodoId == periodoId && f.data == data);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover falta: $e');
    }
  }

  /// Verifica se existe falta em uma data
  bool hasFalta(String data) {
    return _faltas.any((f) => f.data == data);
  }

  /// Retorna falta de uma data específica
  Falta? getFalta(String data) {
    try {
      return _faltas.firstWhere((f) => f.data == data);
    } catch (e) {
      return null;
    }
  }

  /// Conta total de faltas de um período
  int getTotalFaltas(int periodoId) {
    return _faltas.where((f) => f.periodoId == periodoId).length;
  }

  /// Conta faltas reais (já ocorridas)
  int getFaltasReais(int periodoId) {
    return _faltas.where((f) => f.periodoId == periodoId && f.tipo == 'real').length;
  }

  /// Conta faltas planejadas
  int getFaltasPlanejadas(int periodoId) {
    return _faltas.where((f) => f.periodoId == periodoId && f.tipo == 'planejada').length;
  }

  /// Retorna lista de datas com falta
  Set<String> get faltasDates => _faltas.map((f) => f.data).toSet();

  /// Limpa dados
  void clear() {
    _faltas = [];
    _currentPeriodoId = null;
    notifyListeners();
  }
}
