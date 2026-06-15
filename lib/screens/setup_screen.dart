import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/periodo.dart';
import '../providers/periodo_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/cores.dart';
import '../utils/constantes.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form data
  final _nomeController = TextEditingController();
  DateTime _dataInicio = DateTime(DateTime.now().year, 2, 1);
  DateTime _dataFim = DateTime(DateTime.now().year, 6, 30);
  double _frequenciaMinima = 75;
  bool _incluiSabado = false;
  bool _incluiDomingo = false;
  String _margemTipo = 'percentual';
  double _margemValor = 10;
  bool _margemAtiva = true;

  @override
  void initState() {
    super.initState();
    _nomeController.text = '${DateTime.now().year} - 1º Semestre';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KindleColors.offWhite,
      body: SafeArea(
        child: _currentStep < 3 
            ? _buildTutorialPage() 
            : _buildSetupForm(),
      ),
    );
  }

  /// Páginas de tutorial
  Widget _buildTutorialPage() {
    final pages = [
      _TutorialContent(
        icon: PhosphorIconsBold.book,
        title: 'Controle suas faltas',
        description: 'Saiba exatamente quantas faltas ainda pode ter sem comprometer sua frequência mínima.',
      ),
      _TutorialContent(
        icon: PhosphorIconsBold.shield,
        title: 'Margem de segurança',
        description: 'Reserve faltas para imprevistos. O sistema garante que você nunca fique no limite.',
      ),
      _TutorialContent(
        icon: PhosphorIconsBold.sparkle,
        title: 'Sugestões inteligentes',
        description: 'O FaltaControl sugere os melhores dias para descansar, respeitando provas e eventos.',
      ),
    ];

    final page = pages[_currentStep];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: KindleColors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 36,
              color: KindleColors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: KindleColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == _currentStep ? KindleColors.black : KindleColors.light,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _currentStep++);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentStep == 2 ? 'Configurar período' : 'Próximo'),
                  const SizedBox(width: 8),
                  PhosphorIcon(PhosphorIconsRegular.caretRight, size: 18),
                ],
              ),
            ),
          ),
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() => _currentStep--);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 16),
                  const SizedBox(width: 4),
                  const Text('Voltar'),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Formulário de configuração
  Widget _buildSetupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Configurar Período',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Nome do período
          Text('Nome do período', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              hintText: 'Ex: 2026 - 1º Semestre',
            ),
          ),
          const SizedBox(height: 20),

          // Datas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Início', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    _DateButton(
                      date: _dataInicio,
                      onTap: () => _selectDate(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Término', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    _DateButton(
                      date: _dataFim,
                      onTap: () => _selectDate(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Frequência mínima
          Text('Frequência mínima (%)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _frequenciaMinima,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() => _frequenciaMinima = value);
                  },
                ),
              ),
              Text(
                '${_frequenciaMinima.toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dias letivos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KindleColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KindleColors.light),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dias letivos incluem:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                _CheckItem(
                  label: 'Sábados',
                  value: _incluiSabado,
                  onChanged: (v) => setState(() => _incluiSabado = v!),
                ),
                const SizedBox(height: 8),
                _CheckItem(
                  label: 'Domingos',
                  value: _incluiDomingo,
                  onChanged: (v) => setState(() => _incluiDomingo = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Margem de segurança
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KindleColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KindleColors.light),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PhosphorIcon(PhosphorIconsRegular.shield, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Margem de segurança',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Switch(
                      value: _margemAtiva,
                      onChanged: (v) => setState(() => _margemAtiva = v),
                    ),
                  ],
                ),
                if (_margemAtiva) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          label: 'Percentual',
                          isSelected: _margemTipo == 'percentual',
                          onTap: () => setState(() => _margemTipo = 'percentual'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TypeButton(
                          label: 'Absoluta',
                          isSelected: _margemTipo == 'absoluta',
                          onTap: () => setState(() => _margemTipo = 'absoluta'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CounterButton(
                        icon: PhosphorIconsRegular.minus,
                        onTap: () {
                          if (_margemValor > 0) {
                            setState(() => _margemValor--);
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_margemValor.toInt()}${_margemTipo == 'percentual' ? '%' : ''}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _CounterButton(
                        icon: PhosphorIconsRegular.plus,
                        onTap: () {
                          setState(() => _margemValor++);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KindleColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KindleColors.light),
            ),
            child: Row(
              children: [
                PhosphorIcon(PhosphorIconsRegular.lightbulb, size: 20, color: KindleColors.dark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Os feriados nacionais serão carregados automaticamente da BrasilAPI ao salvar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botão salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: KindleColors.white,
                      ),
                    )
                  : const Text('Salvar e começar'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? _dataInicio : _dataFim;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do período')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final periodo = Periodo(
        id: 0,
        nome: _nomeController.text.trim(),
        dataInicio: _formatDate(_dataInicio),
        dataFim: _formatDate(_dataFim),
        frequenciaMinima: _frequenciaMinima / 100,
        incluiSabado: _incluiSabado,
        incluiDomingo: _incluiDomingo,
        margemTipo: _margemTipo,
        margemValor: _margemValor,
        margemAtiva: _margemAtiva,
      );

      final provider = context.read<PeriodoProvider>();
      await provider.savePeriodo(periodo);

      // Carregar feriados
      final startYear = _dataInicio.year;
      final endYear = _dataFim.year;
      await provider.carregarFeriados(startYear);
      if (endYear != startYear) {
        await provider.carregarFeriados(endYear);
      }

      // Marcar primeiro acesso como concluído
      await context.read<SettingsProvider>().setPrimeiroAcesso(false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Conteúdo de tutorial
class _TutorialContent {
  final IconData icon;
  final String title;
  final String description;

  _TutorialContent({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Botão de data
class _DateButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: KindleColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: KindleColors.light),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// Checkbox item
class _CheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

/// Botão de tipo
class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KindleColors.black : KindleColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? KindleColors.black : KindleColors.light,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? KindleColors.white : KindleColors.dark,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão de contador
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: KindleColors.light),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
