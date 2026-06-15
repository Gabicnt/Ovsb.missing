import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/periodo_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/faltas_provider.dart';
import '../models/dia_especial.dart';
import '../utils/cores.dart';

/// Formulário para adicionar/editar evento - TEMA AUTOMÁTICO
class EventoForm extends StatefulWidget {
  final DateTime initialDate;

  const EventoForm({super.key, required this.initialDate});

  @override
  State<EventoForm> createState() => _EventoFormState();
}

class _EventoFormState extends State<EventoForm> {
  late DateTime _data;
  String _tipo = 'importante';
  final _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = widget.initialDate;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Novo evento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: PhosphorIcon(PhosphorIconsRegular.x, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Data
          Text('Data', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tipo de evento
          Text('Tipo de evento', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _TipoOption(
            emoji: '⚠️',
            title: 'Não posso faltar',
            subtitle: 'Bloqueia sugestões neste dia',
            isSelected: _tipo == 'importante',
            colors: colors,
            onTap: () => setState(() => _tipo = 'importante'),
          ),
          const SizedBox(height: 8),
          _TipoOption(
            emoji: '📋',
            title: 'Ausência forçada',
            subtitle: 'Desconta da cota de faltas',
            isSelected: _tipo == 'ausencia_forcada',
            colors: colors,
            onTap: () => setState(() => _tipo = 'ausencia_forcada'),
          ),
          const SizedBox(height: 8),
          _TipoOption(
            emoji: '🔔',
            title: 'Atividade / Lembrete',
            subtitle: 'Apenas um lembrete no calendário',
            isSelected: _tipo == 'atividade',
            colors: colors,
            onTap: () => setState(() => _tipo = 'atividade'),
          ),
          const SizedBox(height: 16),

          // Descrição
          Text('Descrição', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              hintText: 'Ex.: Prova de Cálculo',
            ),
          ),
          const SizedBox(height: 24),

          // Botão salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSave,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _data = picked);
    }
  }

  void _handleSave() {
    final descricao = _descricaoController.text.trim();
    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma descrição')),
      );
      return;
    }

    final periodoProvider = context.read<PeriodoProvider>();
    final eventosProvider = context.read<EventosProvider>();
    final faltasProvider = context.read<FaltasProvider>();
    final periodo = periodoProvider.periodo;

    if (periodo == null) return;

    final dateStr = _formatDate(_data);

    // Se for dia importante, adicionar como dia especial também
    if (_tipo == 'importante') {
      periodoProvider.addDiaEspecial(
        DiaEspecial(
          id: 0,
          periodoId: periodo.id,
          data: dateStr,
          tipo: 'importante',
          descricao: descricao,
        ),
      );
    }

    // Se for ausência forçada, adicionar como falta planejada
    if (_tipo == 'ausencia_forcada') {
      faltasProvider.addFalta(
        periodoId: periodo.id,
        data: dateStr,
        tipo: 'planejada',
      );
    }

    // Adicionar evento
    eventosProvider.addEvento(
      periodoId: periodo.id,
      data: dateStr,
      tipo: _tipo,
      descricao: descricao,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento adicionado')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Opção de tipo de evento - TEMA AUTOMÁTICO
class _TipoOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _TipoOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              PhosphorIcon(
                PhosphorIconsBold.checkCircle,
                size: 20,
                color: colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
