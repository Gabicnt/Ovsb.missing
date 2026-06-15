/// Tipos de falta
enum TipoFalta {
  real, // Falta já ocorrida
  planejada, // Falta planejada para o futuro
}

/// Modelo que representa uma falta
class Falta {
  final int id;
  final int periodoId;
  final String data; // yyyy-MM-dd
  final String tipo; // 'real' ou 'planejada'
  final bool sincronizadoCalendar;

  const Falta({
    required this.id,
    required this.periodoId,
    required this.data,
    required this.tipo,
    this.sincronizadoCalendar = false,
  });

  /// Cria Falta a partir de Map (do banco de dados)
  factory Falta.fromMap(Map<String, dynamic> map) {
    return Falta(
      id: map['id'] as int,
      periodoId: map['periodo_id'] as int,
      data: map['data'] as String,
      tipo: map['tipo'] as String,
      sincronizadoCalendar: (map['sincronizado_calendar'] as int?) == 1,
    );
  }

  /// Converte Falta para Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodo_id': periodoId,
      'data': data,
      'tipo': tipo,
      'sincronizado_calendar': sincronizadoCalendar ? 1 : 0,
    };
  }

  /// Cria cópia com alterações
  Falta copyWith({
    int? id,
    int? periodoId,
    String? data,
    String? tipo,
    bool? sincronizadoCalendar,
  }) {
    return Falta(
      id: id ?? this.id,
      periodoId: periodoId ?? this.periodoId,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      sincronizadoCalendar: sincronizadoCalendar ?? this.sincronizadoCalendar,
    );
  }

  /// Verifica se é uma falta já ocorrida
  bool get isReal => tipo == 'real';

  /// Verifica se é uma falta planejada
  bool get isPlanejada => tipo == 'planejada';

  /// Retorna label legível do tipo
  String get tipoLabel => isPlanejada ? 'Planejada' : 'Realizada';

  /// Retorna emoji representativo
  String get emoji => isPlanejada ? '📅' : '✓';

  @override
  String toString() {
    return 'Falta(id: $id, data: $data, tipo: $tipo)';
  }
}
