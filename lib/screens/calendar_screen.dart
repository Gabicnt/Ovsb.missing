import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/periodo_provider.dart';
import '../providers/faltas_provider.dart';
import '../providers/eventos_provider.dart';
import '../utils/cores.dart';
import '../utils/calculos.dart';
import '../utils/constantes.dart';
import '../widgets/bottom_sheet_dia.dart';
import '../widgets/evento_form.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${mesesPortugues[_focusedDay.month - 1]} ${_focusedDay.year}',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 22),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
        ),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIconsRegular.caretRight, size: 22),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
      body: Consumer3<PeriodoProvider, FaltasProvider, EventosProvider>(
        builder: (context, periodoProvider, faltasProvider, eventosProvider, _) {
          final periodo = periodoProvider.periodo;
          if (periodo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final diasEspeciais = periodoProvider.diasEspeciais;
          final faltas = faltasProvider.faltas;
          final eventos = eventosProvider.eventos;

          // Cálculos
          final diasLetivos = CalculosFaltas.getDiasLetivos(periodo, diasEspeciais);
          final diasLetivosSet = diasLetivos.toSet();
          final faltasPermitidas = CalculosFaltas.getFaltasPermitidas(
            diasLetivos.length,
            periodo.frequenciaMinima,
          );
          final faltasUsadas = CalculosFaltas.getFaltasUsadas(faltas, periodo.id);
          final margem = CalculosFaltas.getMargemAbsoluta(periodo, faltasPermitidas);
          final saldo = CalculosFaltas.getSaldoDisponivel(
            faltasPermitidas,
            faltasUsadas,
            margem,
          );
          final isMargemAtingida = saldo <= 0;

          // Sets para lookup
          final faltasDates = faltas.map((f) => f.data).toSet();
          final feriadoDates = diasEspeciais
              .where((d) => d.tipo == 'feriado' || d.tipo == 'recesso' || d.tipo == 'sem_aula')
              .map((d) => d.data)
              .toSet();
          final importanteDates = {
            ...diasEspeciais.where((d) => d.tipo == 'importante').map((d) => d.data),
            ...eventos.where((e) => e.tipo == 'importante').map((e) => e.data),
          };
          final sugestoes = CalculosFaltas.sugerirDiasDescanso(
            periodo,
            diasEspeciais,
            faltas,
            eventos,
            count: 10,
          ).toSet();

          return Column(
            children: [
              // Legenda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(color: KindleColors.white, border: KindleColors.light, label: 'Normal'),
                    _LegendItem(color: KindleColors.black, label: 'Sugerido'),
                    _LegendItem(color: KindleColors.white, border: KindleColors.black, borderWidth: 2, label: 'Importante'),
                    _LegendItem(color: KindleColors.light, label: 'Falta'),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Calendário
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerVisible: false,
                daysOfWeekHeight: 40,
                rowHeight: 48,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: KindleColors.medium,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: KindleColors.medium,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    border: Border.all(color: KindleColors.black, width: 2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: KindleColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: KindleColors.black,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: KindleColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  defaultTextStyle: const TextStyle(color: KindleColors.black),
                  weekendTextStyle: TextStyle(color: KindleColors.medium),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final dateStr = _formatDate(day);
                    return _buildDayCell(
                      day,
                      dateStr,
                      diasLetivosSet,
                      faltasDates,
                      feriadoDates,
                      importanteDates,
                      sugestoes,
                      isMargemAtingida,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final dateStr = _formatDate(day);
                    return _buildDayCell(
                      day,
                      dateStr,
                      diasLetivosSet,
                      faltasDates,
                      feriadoDates,
                      importanteDates,
                      sugestoes,
                      isMargemAtingida,
                      isSelected: true,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final dateStr = _formatDate(day);
                    return _buildDayCell(
                      day,
                      dateStr,
                      diasLetivosSet,
                      faltasDates,
                      feriadoDates,
                      importanteDates,
                      sugestoes,
                      isMargemAtingida,
                      isToday: true,
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showDayBottomSheet(context, selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),

              // Resumo
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: KindleColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KindleColors.light),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faltas restantes com segurança:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$saldo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isMargemAtingida ? KindleColors.medium : KindleColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(context),
        backgroundColor: KindleColors.black,
        child: PhosphorIcon(PhosphorIconsBold.plus, color: KindleColors.white),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    String dateStr,
    Set<String> diasLetivos,
    Set<String> faltasDates,
    Set<String> feriadoDates,
    Set<String> importanteDates,
    Set<String> sugestoes,
    bool isMargemAtingida, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final hasFalta = faltasDates.contains(dateStr);
    final isFeriado = feriadoDates.contains(dateStr);
    final isImportante = importanteDates.contains(dateStr);
    final isSugerido = sugestoes.contains(dateStr);
    final isDiaLetivo = diasLetivos.contains(dateStr);
    final isWeekend = day.weekday == 6 || day.weekday == 7;

    Color bgColor = Colors.transparent;
    Color textColor = KindleColors.black;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (isSelected) {
      bgColor = KindleColors.black;
      textColor = KindleColors.white;
    } else if (hasFalta) {
      bgColor = KindleColors.light;
    } else if (isSugerido && !isMargemAtingida) {
      bgColor = KindleColors.black;
      textColor = KindleColors.white;
    } else if (isSugerido && isMargemAtingida) {
      bgColor = KindleColors.light;
      borderColor = KindleColors.medium;
      borderWidth = 1;
    } else if (isImportante) {
      borderColor = KindleColors.black;
      borderWidth = 2;
    } else if (isFeriado) {
      bgColor = KindleColors.offWhite;
      textColor = KindleColors.medium;
    } else if (isWeekend) {
      textColor = KindleColors.light;
    } else if (isDiaLetivo) {
      borderColor = KindleColors.light;
      borderWidth = 1;
    }

    if (isToday && !isSelected) {
      borderColor = KindleColors.black;
      borderWidth = 2;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (hasFalta)
              Text(
                '✓',
                style: TextStyle(fontSize: 8, color: textColor),
              ),
            if (isImportante && !hasFalta)
              Text(
                '!',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor),
              ),
          ],
        ),
      ),
    );
  }

  void _showDayBottomSheet(BuildContext context, DateTime day) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BottomSheetDia(date: day),
    );
  }

  void _showEventForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventoForm(initialDate: _selectedDay ?? DateTime.now()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Item de legenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? border;
  final double borderWidth;
  final String label;

  const _LegendItem({
    required this.color,
    this.border,
    this.borderWidth = 1,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border != null ? Border.all(color: border!, width: borderWidth) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
