import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/faltas_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/periodo_provider.dart';
import '../utils/cores.dart';
import '../utils/constantes.dart';

/// Mini calendário do mês atual na Home - TEMA AUTOMÁTICO
class MiniCalendario extends StatelessWidget {
  const MiniCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Consumer3<PeriodoProvider, FaltasProvider, EventosProvider>(
      builder: (context, periodoProvider, faltasProvider, eventosProvider, _) {
        final faltasDates = faltasProvider.faltasDates;
        final feriadoDates = periodoProvider.diasEspeciais
            .where((d) => d.tipo == 'feriado' || d.tipo == 'recesso' || d.tipo == 'sem_aula')
            .map((d) => d.data)
            .toSet();
        final importanteDates = {
          ...periodoProvider.diasEspeciais.where((d) => d.tipo == 'importante').map((d) => d.data),
          ...eventosProvider.eventos.where((e) => e.tipo == 'importante').map((e) => e.data),
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${mesesPortugues[now.month - 1].toUpperCase()} ${now.year}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Cabeçalho dos dias
              Row(
                children: diasSemanaAbrev.map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        d[0],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Grid de dias
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 42, // 6 semanas
                itemBuilder: (context, index) {
                  final dayOffset = index - firstWeekday;
                  
                  if (dayOffset < 0 || dayOffset >= lastDayOfMonth.day) {
                    return const SizedBox();
                  }

                  final day = dayOffset + 1;
                  final date = DateTime(now.year, now.month, day);
                  final dateStr = _formatDate(date);
                  final isToday = day == now.day;
                  final hasFalta = faltasDates.contains(dateStr);
                  final isFeriado = feriadoDates.contains(dateStr);
                  final isImportante = importanteDates.contains(dateStr);

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: colors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: hasFalta ? FontWeight.bold : FontWeight.normal,
                              color: isFeriado
                                  ? colors.tertiary
                                  : isImportante
                                      ? colors.primary
                                      : colors.secondary,
                              decoration: hasFalta ? TextDecoration.underline : null,
                            ),
                          ),
                          if (isFeriado && !hasFalta)
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (isImportante && !hasFalta)
                            Text(
                              '!',
                              style: TextStyle(
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Texto de dica
              Center(
                child: Text(
                  'Toque para ver calendário completo →',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
