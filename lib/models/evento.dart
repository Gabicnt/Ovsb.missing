/// Tipos de evento
enum TipoEvento {
  importante, // Não pode faltar (prova, trabalho)
  ausenciaForcada, // Já sabe que vai faltar (consulta médica)
  atividade, // Apenas lembrete, não afeta faltas
}

/// Modelo que representa um evento no calendário
class Evento {
  final int id;
  final int periodoId;
  final String data; // yyyy-MM-dd
  final String tipo; // 'importante', 'ausencia_forcada', 'atividade'
  final String descricao;
  final bool notificar;
  final String? antecedenciaNotificacao; // '1_dia', 'mesmo_dia', '2_dias'

  const Evento({
    required this.id,
    required this.periodoId,
    required this.data,
    required this.tipo,
    required this.descricao,
    this.notificar = true,
    this.antecedenciaNotificacao,
  });

  /// Cria Evento a partir de Map (do banco de dados)
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'] as int,
      periodoId: map['periodo_id'] as int,
      data: map['data'] as String,
      tipo: map['tipo'] as String,
      descricao: map['descricao'] as String,
      notificar: (map['notificar'] as int?) == 1,
      antecedenciaNotificacao: map['antecedencia_notificacao'] as String?,
    );
  }

  /// Converte Evento para Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodo_id': periodoId,
      'data': data,
      'tipo': tipo,
      'descricao': descricao,
      'notificar': notificar ? 1 : 0,
      'antecedencia_notificacao': antecedenciaNotificacao,
    };
  }

  /// Cria cópia com alterações
  Evento copyWith({
    int? id,
    int? periodoId,
    String? data,
    String? tipo,
    String? descricao,
    bool? notificar,
    String? antecedenciaNotificacao,
  }) {
    return Evento(
      id: id ?? this.id,
      periodoId: periodoId ?? this.periodoId,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      notificar: notificar ?? this.notificar,
      antecedenciaNotificacao: antecedenciaNotificacao ?? this.antecedenciaNotificacao,
    );
  }

  /// Verifica se é um dia importante (bloqueia sugestões)
  bool get isImportante => tipo == 'importante';

  /// Verifica se é uma ausência forçada (desconta falta)
  bool get isAusenciaForcada => tipo == 'ausencia_forcada';

  /// Verifica se é apenas uma atividade/lembrete
  bool get isAtividade => tipo == 'atividade';

  /// Retorna emoji representativo do tipo
  String get emoji {
    switch (tipo) {
      case 'importante':
        return '⚠️';
      case 'ausencia_forcada':
        return '📋';
      case 'atividade':
        return '🔔';
      default:
        return '📅';
    }
  }

  /// Retorna label legível do tipo
  String get tipoLabel {
    switch (tipo) {
      case 'importante':
        return 'Não posso faltar';
      case 'ausencia_forcada':
        return 'Ausência forçada';
      case 'atividade':
        return 'Atividade';
      default:
        return tipo;
    }
  }

  /// Retorna descrição curta do tipo
  String get tipoDescricao {
    switch (tipo) {
      case 'importante':
        return 'Bloqueia sugestões neste dia';
      case 'ausencia_forcada':
        return 'Desconta da cota de faltas';
      case 'atividade':
        return 'Apenas um lembrete no calendário';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'Evento(id: $id, data: $data, tipo: $tipo, descricao: $descricao)';
  }
}
