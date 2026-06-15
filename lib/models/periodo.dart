/// Modelo que representa um período letivo
class Periodo {
  final int id;
  final String nome;
  final String dataInicio; // yyyy-MM-dd
  final String dataFim; // yyyy-MM-dd
  final double frequenciaMinima; // 0.75 = 75%
  final bool incluiSabado;
  final bool incluiDomingo;
  final String margemTipo; // 'percentual' ou 'absoluta'
  final double margemValor;
  final bool margemAtiva;

  const Periodo({
    required this.id,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    this.frequenciaMinima = 0.75,
    this.incluiSabado = false,
    this.incluiDomingo = false,
    this.margemTipo = 'percentual',
    this.margemValor = 10.0,
    this.margemAtiva = true,
  });

  /// Cria Periodo a partir de Map (do banco de dados)
  factory Periodo.fromMap(Map<String, dynamic> map) {
    return Periodo(
      id: map['id'] as int,
      nome: map['nome'] as String,
      dataInicio: map['data_inicio'] as String,
      dataFim: map['data_fim'] as String,
      frequenciaMinima: (map['frequencia_minima'] as num).toDouble(),
      incluiSabado: (map['inclui_sabado'] as int) == 1,
      incluiDomingo: (map['inclui_domingo'] as int) == 1,
      margemTipo: map['margem_tipo'] as String,
      margemValor: (map['margem_valor'] as num).toDouble(),
      margemAtiva: (map['margem_ativa'] as int) == 1,
    );
  }

  /// Converte Periodo para Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'frequencia_minima': frequenciaMinima,
      'inclui_sabado': incluiSabado ? 1 : 0,
      'inclui_domingo': incluiDomingo ? 1 : 0,
      'margem_tipo': margemTipo,
      'margem_valor': margemValor,
      'margem_ativa': margemAtiva ? 1 : 0,
    };
  }

  /// Cria cópia com alterações
  Periodo copyWith({
    int? id,
    String? nome,
    String? dataInicio,
    String? dataFim,
    double? frequenciaMinima,
    bool? incluiSabado,
    bool? incluiDomingo,
    String? margemTipo,
    double? margemValor,
    bool? margemAtiva,
  }) {
    return Periodo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      frequenciaMinima: frequenciaMinima ?? this.frequenciaMinima,
      incluiSabado: incluiSabado ?? this.incluiSabado,
      incluiDomingo: incluiDomingo ?? this.incluiDomingo,
      margemTipo: margemTipo ?? this.margemTipo,
      margemValor: margemValor ?? this.margemValor,
      margemAtiva: margemAtiva ?? this.margemAtiva,
    );
  }

  @override
  String toString() {
    return 'Periodo(id: $id, nome: $nome, dataInicio: $dataInicio, dataFim: $dataFim)';
  }
}
