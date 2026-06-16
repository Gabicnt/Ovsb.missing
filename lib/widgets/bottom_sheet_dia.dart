import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/periodo_provider.dart';
import '../providers/faltas_provider.dart';
import '../providers/eventos_provider.dart';
import '../utils/cores.dart';
import '../utils/calculos.dart';

/// Bottom sheet para interação com um dia do calendário - TEMA AUTOMÁTICO
class BottomSheetDia extends StatelessWidget {
  final DateTime date;

  const BottomSheetDia({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStr = _formatDate(date);
    final dateFormatted = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(date);

    return Consumer3<PeriodoProvider, FaltasProvider, EventosProvider>(
      builder: (context, periodoProvider, faltasProvider, eventosProvider, _) {
        final periodo = periodoProvider.periodo;
        if (periodo == null) {
          return const SizedBox.shrink();
        }

        final existingFalta = faltasProvider.getFalta(dateStr);
        final isFeriado = periodoProvider.isFeriado(dateStr);
        final isImportante = periodoProvider.isDiaImportante(dateStr) ||
            eventosProvider.isDiaImportante(dateStr);

        // Calcular saldo
        final diasLetivos = CalculosFaltas.getDiasLetivos(periodo, periodoProvider.diasEspeciais);
        final faltasPermitidas = CalculosFaltas.getFaltasPermitidas(
          diasLetivos.length,
          periodo.frequenciaMinima,
        );
        final faltasUsadas = CalculosFaltas.getFaltasUsadas(faltasProvider.faltas, periodo.id);
        final margem = CalculosFaltas.getMargemAbsoluta(periodo, faltasPermitidas);
        final saldo = CalculosFaltas.getSaldoDisponivel(faltasPermitidas, faltasUsadas, margem);

        String statusText = 'Disponível para descanso';
        if (existingFalta != null) {
          statusText = existingFalta.tipo == 'planejada' ? 'Falta planejada' : 'Falta registrada';
        } else if (isFeriado) {
          statusText = 'Feriado / Sem aula';
        } else if (isImportante) {
          statusText = 'Dia importante – não falte!';
        } else if (saldo <= 0) {
          statusText = 'Margem de segurança atingida';
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data e status
              Text(
                dateFormatted,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Ações
              if (existingFalta == null && !isFeriado) ...[
                _ActionButton(
                  icon: PhosphorIconsRegular.check,
                  label: 'Marcar falta planejada',
                  colors: colors,
                  onTap: () => _marcarFalta(context, 'planejada', saldo),
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: PhosphorIconsRegular.calendar,
                  label: 'Registrar falta realizada',
                  colors: colors,
                  onTap: () => _marcarFalta(context, 'real', saldo),
                ),
              ],

              if (existingFalta != null) ...[
                _ActionButton(
                  icon: PhosphorIconsRegular.trash,
                  label: 'Desmarcar falta',
                  colors: colors,
                  onTap: () {
                    context.read<FaltasProvider>().removeFalta(existingFalta.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Falta removida')),
                    );
                  },
                ),
              ],

              const SizedBox(height: 8),
              _ActionButton(
                icon: PhosphorIconsRegular.flag,
                label: 'Adicionar evento',
                colors: colors,
                isSecondary: true,
                onTap: () {
                  Navigator.pop(context);
                  // Abrir formulário de evento
                },
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _marcarFalta(BuildContext context, String tipo, int saldo) {
    final periodoProvider = context.read<PeriodoProvider>();
    final faltasProvider = context.read<FaltasProvider>();
    final periodo = periodoProvider.periodo;

    if (periodo == null) return;

    if (saldo <= 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
            'Você está usando sua margem de segurança. Restarão 0 faltas de reserva. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmarFalta(context, faltasProvider, periodo.id, tipo);
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } else {
      _confirmarFalta(context, faltasProvider, periodo.id, tipo);
    }
  }

  void _confirmarFalta(
    BuildContext context,
    FaltasProvider provider,
    int periodoId,
    String tipo,
  ) {
    provider.addFalta(
      periodoId: periodoId,
      data: _formatDate(date),
      tipo: tipo,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tipo == 'planejada' ? 'Falta planejada' : 'Falta registrada'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Botão de ação - TEMA AUTOMÁTICO
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AppColors colors;
  final bool isSecondary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colors,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              icon, 
              size: 20, 
              color: isSecondary ? colors.secondary : colors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSecondary ? colors.secondary : colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
