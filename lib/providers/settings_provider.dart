import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../utils/constantes.dart';

/// Provider para configurações do app
class SettingsProvider extends ChangeNotifier {
  bool _notificacoesAtivas = true;
  int _horarioNotificacao = 8; // Hora do dia (0-23)
  bool _resumoSemanal = true;
  bool _primeiroAcesso = true;
  bool _temaEscuro = false;

  bool get notificacoesAtivas => _notificacoesAtivas;
  int get horarioNotificacao => _horarioNotificacao;
  bool get resumoSemanal => _resumoSemanal;
  bool get primeiroAcesso => _primeiroAcesso;
  bool get temaEscuro => _temaEscuro;

  /// Carrega configurações do banco
  Future<void> loadSettings() async {
    try {
      _notificacoesAtivas = await _getBoolConfig(AppConstants.prefNotificacoesAtivas, true);
      _horarioNotificacao = await _getIntConfig(AppConstants.prefHorarioNotificacao, 8);
      _resumoSemanal = await _getBoolConfig(AppConstants.prefResumoSemanal, true);
      _primeiroAcesso = await _getBoolConfig(AppConstants.prefPrimeiroAcesso, true);
      _temaEscuro = await _getBoolConfig(AppConstants.prefTemaEscuro, false);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar configurações: $e');
    }
  }

  /// Salva uma configuração string
  Future<void> _setConfig(String chave, String valor) async {
    await DatabaseService.instance.setConfig(chave, valor);
  }

  /// Lê uma configuração bool
  Future<bool> _getBoolConfig(String chave, bool defaultValue) async {
    final valor = await DatabaseService.instance.getConfig(chave);
    if (valor == null) return defaultValue;
    return valor == '1' || valor == 'true';
  }

  /// Lê uma configuração int
  Future<int> _getIntConfig(String chave, int defaultValue) async {
    final valor = await DatabaseService.instance.getConfig(chave);
    if (valor == null) return defaultValue;
    return int.tryParse(valor) ?? defaultValue;
  }

  /// Define se notificações estão ativas
  Future<void> setNotificacoesAtivas(bool value) async {
    _notificacoesAtivas = value;
    await _setConfig(AppConstants.prefNotificacoesAtivas, value ? '1' : '0');
    notifyListeners();
  }

  /// Define horário de notificação
  Future<void> setHorarioNotificacao(int hora) async {
    _horarioNotificacao = hora;
    await _setConfig(AppConstants.prefHorarioNotificacao, hora.toString());
    notifyListeners();
  }

  /// Define se resumo semanal está ativo
  Future<void> setResumoSemanal(bool value) async {
    _resumoSemanal = value;
    await _setConfig(AppConstants.prefResumoSemanal, value ? '1' : '0');
    notifyListeners();
  }

  /// Define se é primeiro acesso
  Future<void> setPrimeiroAcesso(bool value) async {
    _primeiroAcesso = value;
    await _setConfig(AppConstants.prefPrimeiroAcesso, value ? '1' : '0');
    notifyListeners();
  }

  /// Define tema escuro
  Future<void> setTemaEscuro(bool value) async {
    _temaEscuro = value;
    await _setConfig(AppConstants.prefTemaEscuro, value ? '1' : '0');
    notifyListeners();
  }

  /// Reseta todas as configurações
  Future<void> resetSettings() async {
    _notificacoesAtivas = true;
    _horarioNotificacao = 8;
    _resumoSemanal = true;
    _primeiroAcesso = true;
    _temaEscuro = false;
    notifyListeners();
  }
}
