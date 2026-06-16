import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../utils/cores.dart';

/// Card principal mostrando saldo de faltas - TEMA AUTOMÁTICO
class CardSaldo extends StatelessWidget {
  final int saldo;
  final int faltasPermitidas;
  final int faltasUsadas;
  final int margem;

  const CardSaldo({
    super.key,
    required this.saldo,
    required this.faltasPermitidas,
    required this.faltasUsadas,
    required this.margem,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMargemAtingida = saldo <= 0;
    final progressPercent = faltasPermitidas > 0
        ? (faltasUsadas / faltasPermitidas).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lado esquerdo - informações principais
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você ainda pode faltar',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$saldo',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isMargemAtingida ? colors.tertiary : colors.primary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      saldo == 1 ? 'dia' : 'dias',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'de $faltasPermitidas permitidas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Barra de progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation(
                      isMargemAtingida ? colors.tertiary : colors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$faltasUsadas usadas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$faltasPermitidas máx.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Lado direito - indicador de margem
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isMargemAtingida ? colors.secondary : colors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMargemAtingida ? colors.secondary : colors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  PhosphorIconsRegular.shield,
                  size: 20,
                  color: isMargemAtingida ? colors.buttonText : colors.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$margem',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'margem',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
