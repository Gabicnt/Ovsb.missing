/// Tipos de dias especiais
enum TipoDiaEspecial {
  feriado,
  recesso,
  semAula,
  importante,
}

/// Modelo que representa um dia especial (feriado, recesso, importante, etc)
class DiaEspecial {
  final int id;
  final int periodoId;
  final String data; // yyyy-MM-dd
  final String tipo; // 'feriado', 'recesso', 'sem_aula', 'importante'
  final String descricao;

  const DiaEspecial({
    required this.id,
    required this.periodoId,
    required this.data,
    required this.tipo,
    required this.descricao,
  });

  /// Cria DiaEspecial a partir de Map (do banco de dados)
  factory DiaEspecial.fromMap(Map<String, dynamic> map) {
    return DiaEspecial(
      id: map['id'] as int,
      periodoId: map['periodo_id'] as int,
      data: map['data'] as String,
      tipo: map['tipo'] as String,
      descricao: map['descricao'] as String,
    );
  }

  /// Converte DiaEspecial para Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodo_id': periodoId,
      'data': data,
      'tipo': tipo,
      'descricao': descricao,
    };
  }

  /// Cria cópia com alterações
  DiaEspecial copyWith({
    int? id,
    int? periodoId,
    String? data,
    String? tipo,
    String? descricao,
  }) {
    return DiaEspecial(
      id: id ?? this.id,
      periodoId: periodoId ?? this.periodoId,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
    );
  }

  /// Verifica se é um dia sem aula (feriado, recesso ou sem_aula)
  bool get isDiaSemAula =>
      tipo == 'feriado' || tipo == 'recesso' || tipo == 'sem_aula';

  /// Verifica se é um dia importante
  bool get isDiaImportante => tipo == 'importante';

  /// Retorna emoji representativo do tipo
  String get emoji {
    switch (tipo) {
      case 'feriado':
        return '🎉';
      case 'recesso':
        return '🏖️';
      case 'sem_aula':
        return '🚫';
      case 'importante':
        return '⚠️';
      default:
        return '📅';
    }
  }

  /// Retorna label legível do tipo
  String get tipoLabel {
    switch (tipo) {
      case 'feriado':
        return 'Feriado';
      case 'recesso':
        return 'Recesso';
      case 'sem_aula':
        return 'Sem aula';
      case 'importante':
        return 'Importante';
      default:
        return tipo;
    }
  }

  @override
  String toString() {
    return 'DiaEspecial(id: $id, data: $data, tipo: $tipo, descricao: $descricao)';
  }
}
