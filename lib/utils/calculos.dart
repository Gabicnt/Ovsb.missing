import '../models/periodo.dart';
import '../models/dia_especial.dart';
import '../models/falta.dart';
import '../models/evento.dart';

/// Utilitários para cálculos de faltas e frequência
class CalculosFaltas {
  CalculosFaltas._();

  /// Retorna lista de datas (yyyy-MM-dd) que são dias letivos válidos
  static List<String> getDiasLetivos(Periodo periodo, List<DiaEspecial> diasEspeciais) {
    final start = DateTime.parse(periodo.dataInicio);
    final end = DateTime.parse(periodo.dataFim);
    final List<String> diasLetivos = [];

    // Criar set de dias sem aula para lookup rápido
    final diasSemAula = diasEspeciais
        .where((d) =>
            d.periodoId == periodo.id &&
            (d.tipo == 'feriado' || d.tipo == 'recesso' || d.tipo == 'sem_aula'))
        .map((d) => d.data)
        .toSet();

    // Iterar por cada dia do período
    DateTime current = start;
    while (!current.isAfter(end)) {
      final dateStr = _formatDate(current);
      final weekday = current.weekday; // 1 = Monday, 7 = Sunday

      // Verificar se é dia letivo
      bool isDiaLetivo = true;

      // Sábado (weekday == 6)
      if (weekday == 6 && !periodo.incluiSabado) {
        isDiaLetivo = false;
      }

      // Domingo (weekday == 7)
      if (weekday == 7 && !periodo.incluiDomingo) {
        isDiaLetivo = false;
      }

      // Dia sem aula (feriado, recesso, etc)
      if (diasSemAula.contains(dateStr)) {
        isDiaLetivo = false;
      }

      if (isDiaLetivo) {
        diasLetivos.add(dateStr);
      }

      current = current.add(const Duration(days: 1));
    }

    return diasLetivos;
  }

  /// Calcula o número máximo de faltas permitidas
  static int getFaltasPermitidas(int totalDiasLetivos, double frequenciaMinima) {
    return (totalDiasLetivos * (1 - frequenciaMinima)).floor();
  }

  /// Calcula a margem de segurança em número absoluto
  static int getMargemAbsoluta(Periodo periodo, int faltasPermitidas) {
    if (!periodo.margemAtiva) return 0;
    
    if (periodo.margemTipo == 'absoluta') {
      return periodo.margemValor.toInt();
    }
    
    // Percentual
    return (faltasPermitidas * (periodo.margemValor / 100)).ceil();
  }

  /// Calcula o saldo disponível para faltas (considerando margem)
  static int getSaldoDisponivel(int faltasPermitidas, int faltasUsadas, int margem) {
    final saldo = faltasPermitidas - faltasUsadas - margem;
    return saldo > 0 ? saldo : 0;
  }

  /// Conta faltas usadas para um período
  static int getFaltasUsadas(List<Falta> faltas, int periodoId) {
    return faltas.where((f) => f.periodoId == periodoId).length;
  }

  /// Calcula a frequência atual em percentual
  static double getFrequenciaAtual(int totalDiasLetivos, int faltasUsadas) {
    if (totalDiasLetivos == 0) return 100.0;
    final presencas = totalDiasLetivos - faltasUsadas;
    return (presencas / totalDiasLetivos) * 100;
  }

  /// Verifica se um dia é importante (prova, trabalho, etc)
  static bool isDiaImportante(
    String data,
    List<Evento> eventos,
    List<DiaEspecial> diasEspeciais,
    int periodoId,
  ) {
    // Verificar em eventos
    final isImportanteEvento = eventos.any(
      (e) => e.periodoId == periodoId && e.data == data && e.tipo == 'importante',
    );

    // Verificar em dias especiais
    final isImportanteDia = diasEspeciais.any(
      (d) => d.periodoId == periodoId && d.data == data && d.tipo == 'importante',
    );

    return isImportanteEvento || isImportanteDia;
  }

  /// Sugere os melhores dias para faltar
  static List<String> sugerirDiasDescanso(
    Periodo periodo,
    List<DiaEspecial> diasEspeciais,
    List<Falta> faltas,
    List<Evento> eventos, {
    int count = 5,
  }) {
    final diasLetivos = getDiasLetivos(periodo, diasEspeciais);
    final faltasPermitidas = getFaltasPermitidas(diasLetivos.length, periodo.frequenciaMinima);
    final faltasUsadas = getFaltasUsadas(faltas, periodo.id);
    final margem = getMargemAbsoluta(periodo, faltasPermitidas);
    final saldo = getSaldoDisponivel(faltasPermitidas, faltasUsadas, margem);

    if (saldo <= 0) return [];

    final today = _formatDate(DateTime.now());
    final faltasDates = faltas
        .where((f) => f.periodoId == periodo.id)
        .map((f) => f.data)
        .toSet();

    // Coletar dias importantes
    final importantDates = <String>{};
    for (final e in eventos) {
      if (e.periodoId == periodo.id && e.tipo == 'importante') {
        importantDates.add(e.data);
      }
    }
    for (final d in diasEspeciais) {
      if (d.periodoId == periodo.id && d.tipo == 'importante') {
        importantDates.add(d.data);
      }
    }

    // Filtrar candidatos (dias letivos futuros sem falta e não importantes)
    final candidates = diasLetivos.where((d) {
      if (d.compareTo(today) <= 0) return false;
      if (faltasDates.contains(d)) return false;
      if (importantDates.contains(d)) return false;
      return true;
    }).toList();

    // Pontuar cada candidato
    final scored = <_ScoredDay>[];
    for (final date in candidates) {
      int score = 100;
      final dateObj = DateTime.parse(date);

      // Penalizar dias próximos de dias importantes
      for (final imp in importantDates) {
        final impDate = DateTime.parse(imp);
        final dist = dateObj.difference(impDate).inDays.abs();
        if (dist <= 1) {
          score -= 50;
        } else if (dist <= 2) {
          score -= 20;
        } else if (dist <= 3) {
          score -= 5;
        }
      }

      // Penalizar dias próximos de outras faltas
      for (final f in faltasDates) {
        final fDate = DateTime.parse(f);
        final dist = dateObj.difference(fDate).inDays.abs();
        if (dist <= 5 && dist > 0) {
          score -= 15;
        }
      }

      // Bonificar segundas e sextas (extensão do fim de semana)
      final weekday = dateObj.weekday;
      if (weekday == 1 || weekday == 5) {
        score += 10;
      }

      // Bonificar dias mais próximos (até 2 semanas)
      final daysFromNow = dateObj.difference(DateTime.now()).inDays;
      if (daysFromNow <= 14) {
        score += 5;
      }

      scored.add(_ScoredDay(date, score));
    }

    // Ordenar por pontuação (maior primeiro)
    scored.sort((a, b) => b.score.compareTo(a.score));

    // Retornar os melhores
    final maxCount = saldo < count ? saldo : count;
    return scored.take(maxCount).map((s) => s.date).toList();
  }

  /// Sugere o próximo melhor dia para faltar
  static String? sugerirProximoDescanso(
    Periodo periodo,
    List<DiaEspecial> diasEspeciais,
    List<Falta> faltas,
    List<Evento> eventos,
  ) {
    final suggestions = sugerirDiasDescanso(
      periodo,
      diasEspeciais,
      faltas,
      eventos,
      count: 1,
    );
    return suggestions.isNotEmpty ? suggestions.first : null;
  }

  /// Formata DateTime para yyyy-MM-dd
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Classe auxiliar para pontuação de dias
class _ScoredDay {
  final String date;
  final int score;

  _ScoredDay(this.date, this.score);
}
