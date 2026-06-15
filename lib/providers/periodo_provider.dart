import 'package:flutter/foundation.dart';
import '../models/periodo.dart';
import '../models/dia_especial.dart';
import '../services/database_service.dart';
import '../services/feriados_service.dart';

/// Provider para gerenciar o período letivo atual
class PeriodoProvider extends ChangeNotifier {
  Periodo? _periodo;
  List<DiaEspecial> _diasEspeciais = [];
  bool _isLoading = false;

  Periodo? get periodo => _periodo;
  List<DiaEspecial> get diasEspeciais => _diasEspeciais;
  bool get isLoading => _isLoading;

  /// Carrega o período atual do banco
  Future<void> loadPeriodo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final periodos = await DatabaseService.instance.getAllPeriodos();
      if (periodos.isNotEmpty) {
        _periodo = Periodo.fromMap(periodos.first);
        await _loadDiasEspeciais();
      }
    } catch (e) {
      print('Erro ao carregar período: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega dias especiais do período atual
  Future<void> _loadDiasEspeciais() async {
    if (_periodo == null) return;

    try {
      final dias = await DatabaseService.instance.getDiasEspeciais(_periodo!.id);
      _diasEspeciais = dias.map((d) => DiaEspecial.fromMap(d)).toList();
    } catch (e) {
      print('Erro ao carregar dias especiais: $e');
    }
  }

  /// Cria ou atualiza período
  Future<void> savePeriodo(Periodo periodo) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (periodo.id == 0) {
        // Novo período
        final map = periodo.toMap();
        map.remove('id');
        final id = await DatabaseService.instance.insertPeriodo(map);
        _periodo = periodo.copyWith(id: id);
      } else {
        // Atualizar existente
        await DatabaseService.instance.updatePeriodo(periodo.id, periodo.toMap());
        _periodo = periodo;
      }

      // Recarregar dias especiais
      await _loadDiasEspeciais();
    } catch (e) {
      print('Erro ao salvar período: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Atualiza apenas alguns campos do período
  Future<void> updatePeriodo(Map<String, dynamic> updates) async {
    if (_periodo == null) return;

    final updatedPeriodo = _periodo!.copyWith(
      nome: updates['nome'] ?? _periodo!.nome,
      dataInicio: updates['dataInicio'] ?? _periodo!.dataInicio,
      dataFim: updates['dataFim'] ?? _periodo!.dataFim,
      frequenciaMinima: updates['frequenciaMinima'] ?? _periodo!.frequenciaMinima,
      incluiSabado: updates['incluiSabado'] ?? _periodo!.incluiSabado,
      incluiDomingo: updates['incluiDomingo'] ?? _periodo!.incluiDomingo,
      margemTipo: updates['margemTipo'] ?? _periodo!.margemTipo,
      margemValor: updates['margemValor'] ?? _periodo!.margemValor,
      margemAtiva: updates['margemAtiva'] ?? _periodo!.margemAtiva,
    );

    await savePeriodo(updatedPeriodo);
  }

  /// Busca e adiciona feriados do ano
  Future<void> carregarFeriados(int ano) async {
    if (_periodo == null) return;

    try {
      final feriados = await FeriadosService.instance.getFeriados(ano);
      
      // Remover feriados antigos deste ano
      await DatabaseService.instance.deleteDiasEspeciaisByTipo(_periodo!.id, 'feriado');

      // Adicionar novos feriados
      for (final f in feriados) {
        final dia = DiaEspecial(
          id: 0,
          periodoId: _periodo!.id,
          data: f.date,
          tipo: 'feriado',
          descricao: f.name,
        );
        final map = dia.toMap();
        map.remove('id');
        await DatabaseService.instance.insertDiaEspecial(map);
      }

      await _loadDiasEspeciais();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar feriados: $e');
    }
  }

  /// Adiciona dia especial
  Future<void> addDiaEspecial(DiaEspecial dia) async {
    if (_periodo == null) return;

    try {
      final map = dia.copyWith(periodoId: _periodo!.id).toMap();
      map.remove('id');
      await DatabaseService.instance.insertDiaEspecial(map);
      await _loadDiasEspeciais();
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar dia especial: $e');
    }
  }

  /// Remove dia especial
  Future<void> removeDiaEspecial(int id) async {
    try {
      await DatabaseService.instance.deleteDiaEspecial(id);
      await _loadDiasEspeciais();
      notifyListeners();
    } catch (e) {
      print('Erro ao remover dia especial: $e');
    }
  }

  /// Verifica se uma data é feriado
  bool isFeriado(String data) {
    return _diasEspeciais.any(
      (d) => d.data == data && (d.tipo == 'feriado' || d.tipo == 'recesso' || d.tipo == 'sem_aula'),
    );
  }

  /// Verifica se uma data é dia importante
  bool isDiaImportante(String data) {
    return _diasEspeciais.any((d) => d.data == data && d.tipo == 'importante');
  }

  /// Retorna descrição de um dia especial
  String? getDescricaoDia(String data) {
    final dia = _diasEspeciais.firstWhere(
      (d) => d.data == data,
      orElse: () => const DiaEspecial(id: 0, periodoId: 0, data: '', tipo: '', descricao: ''),
    );
    return dia.descricao.isNotEmpty ? dia.descricao : null;
  }

  /// Limpa todos os dados
  Future<void> clear() async {
    _periodo = null;
    _diasEspeciais = [];
    notifyListeners();
  }
}
