import 'package:flutter/foundation.dart';
import '../models/evento.dart';
import '../services/database_service.dart';

/// Provider para gerenciar eventos
class EventosProvider extends ChangeNotifier {
  List<Evento> _eventos = [];
  bool _isLoading = false;
  int? _currentPeriodoId;

  List<Evento> get eventos => _eventos;
  bool get isLoading => _isLoading;

  /// Carrega eventos de um período
  Future<void> loadEventos(int periodoId) async {
    _isLoading = true;
    _currentPeriodoId = periodoId;
    notifyListeners();

    try {
      final eventosData = await DatabaseService.instance.getEventos(periodoId);
      _eventos = eventosData.map((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona um evento
  Future<Evento?> addEvento({
    required int periodoId,
    required String data,
    required String tipo,
    required String descricao,
    bool notificar = true,
    String? antecedenciaNotificacao,
  }) async {
    try {
      final evento = Evento(
        id: 0,
        periodoId: periodoId,
        data: data,
        tipo: tipo,
        descricao: descricao,
        notificar: notificar,
        antecedenciaNotificacao: antecedenciaNotificacao,
      );

      final map = evento.toMap();
      map.remove('id');
      final id = await DatabaseService.instance.insertEvento(map);

      final novoEvento = evento.copyWith(id: id);
      _eventos.add(novoEvento);
      _eventos.sort((a, b) => a.data.compareTo(b.data));
      notifyListeners();

      return novoEvento;
    } catch (e) {
      print('Erro ao adicionar evento: $e');
      return null;
    }
  }

  /// Atualiza um evento
  Future<void> updateEvento(int id, Map<String, dynamic> updates) async {
    try {
      final index = _eventos.indexWhere((e) => e.id == id);
      if (index == -1) return;

      final atual = _eventos[index];
      final atualizado = atual.copyWith(
        data: updates['data'] ?? atual.data,
        tipo: updates['tipo'] ?? atual.tipo,
        descricao: updates['descricao'] ?? atual.descricao,
        notificar: updates['notificar'] ?? atual.notificar,
        antecedenciaNotificacao: updates['antecedenciaNotificacao'] ?? atual.antecedenciaNotificacao,
      );

      await DatabaseService.instance.updateEvento(id, atualizado.toMap());
      _eventos[index] = atualizado;
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar evento: $e');
    }
  }

  /// Remove um evento
  Future<void> removeEvento(int id) async {
    try {
      await DatabaseService.instance.deleteEvento(id);
      _eventos.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover evento: $e');
    }
  }

  /// Retorna eventos de uma data
  List<Evento> getEventosByData(String data) {
    return _eventos.where((e) => e.data == data).toList();
  }

  /// Verifica se existe evento importante em uma data
  bool isDiaImportante(String data) {
    return _eventos.any((e) => e.data == data && e.tipo == 'importante');
  }

  /// Retorna próximos eventos importantes
  List<Evento> getProximosEventosImportantes({int limit = 5}) {
    final hoje = DateTime.now().toIso8601String().split('T').first;
    return _eventos
        .where((e) => e.tipo == 'importante' && e.data.compareTo(hoje) >= 0)
        .take(limit)
        .toList();
  }

  /// Retorna eventos futuros
  List<Evento> getEventosFuturos() {
    final hoje = DateTime.now().toIso8601String().split('T').first;
    return _eventos.where((e) => e.data.compareTo(hoje) >= 0).toList();
  }

  /// Retorna set de datas com eventos
  Set<String> get eventosDates => _eventos.map((e) => e.data).toSet();

  /// Retorna set de datas com eventos importantes
  Set<String> get diasImportantesDates =>
      _eventos.where((e) => e.tipo == 'importante').map((e) => e.data).toSet();

  /// Limpa dados
  void clear() {
    _eventos = [];
    _currentPeriodoId = null;
    notifyListeners();
  }
}
