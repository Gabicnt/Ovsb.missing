/// Constantes globais do aplicativo
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'OvsbMissing';
  static const String appVersion = '1.0.0';
  
  // Credits
  static const String authorName = '@BeaGabi.cnt';
  static const String authorGithub = 'https://github.com/Gabicnt';

  // Database
  static const String databaseName = 'faltacontrol.db';
  static const int databaseVersion = 1;

  // API
  static const String brasilApiBaseUrl = 'https://brasilapi.com.br/api';
  static const String feriadosEndpoint = '/feriados/v1';

  // Defaults
  static const double defaultFrequenciaMinima = 0.75;
  static const double defaultMargemPercentual = 10.0;
  static const int defaultMargemAbsoluta = 2;
  static const bool defaultMargemAtiva = true;
  static const String defaultMargemTipo = 'percentual';

  // Notification IDs
  static const int notificationIdSugestao = 1;
  static const int notificationIdMargem = 2;
  static const int notificationIdDiaImportante = 3;
  static const int notificationIdResumoSemanal = 4;

  // Notification channels
  static const String notificationChannelId = 'ovsbmissing_channel';
  static const String notificationChannelName = 'OvsbMissing';
  static const String notificationChannelDesc = 'Notificações do OvsbMissing';

  // Shared preferences keys
  static const String prefNotificacoesAtivas = 'notificacoes_ativas';
  static const String prefHorarioNotificacao = 'horario_notificacao';
  static const String prefResumoSemanal = 'resumo_semanal';
  static const String prefPrimeiroAcesso = 'primeiro_acesso';
  static const String prefTemaEscuro = 'tema_escuro';

  // Animation durations
  static const Duration animacaoRapida = Duration(milliseconds: 150);
  static const Duration animacaoNormal = Duration(milliseconds: 300);
  static const Duration animacaoLenta = Duration(milliseconds: 500);

  // Layout
  static const double paddingPequeno = 8.0;
  static const double paddingMedio = 16.0;
  static const double paddingGrande = 24.0;
  static const double borderRadiusPequeno = 8.0;
  static const double borderRadiusMedio = 12.0;
  static const double borderRadiusGrande = 16.0;
  static const double alturaBottomNav = 64.0;
  static const double alturaAppBar = 56.0;
  static const double alturaBotao = 48.0;
  static const double tamanhoIcone = 24.0;
}

/// Dias da semana em português (abreviados)
const List<String> diasSemanaAbrev = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

/// Dias da semana em português (completos)
const List<String> diasSemanaCompleto = [
  'Domingo',
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado'
];

/// Meses em português
const List<String> mesesPortugues = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro'
];

/// Meses em português (abreviados)
const List<String> mesesAbrev = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez'
];
