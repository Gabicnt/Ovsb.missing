import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../providers/periodo_provider.dart';
import '../providers/faltas_provider.dart';
import '../providers/eventos_provider.dart';
import '../utils/cores.dart';
import '../utils/calculos.dart';
import '../utils/constantes.dart';
import '../widgets/card_saldo.dart';
import '../widgets/mini_calendario.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final periodoProvider = context.read<PeriodoProvider>();
    await periodoProvider.loadPeriodo();

    if (periodoProvider.periodo != null) {
      final periodoId = periodoProvider.periodo!.id;
      await context.read<FaltasProvider>().loadFaltas(periodoId);
      await context.read<EventosProvider>().loadEventos(periodoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          CalendarScreen(),
          _PeriodoTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: KindleColors.light, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: PhosphorIcon(PhosphorIconsRegular.house, size: 22),
              activeIcon: PhosphorIcon(PhosphorIconsBold.house, size: 22),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(PhosphorIconsRegular.calendar, size: 22),
              activeIcon: PhosphorIcon(PhosphorIconsBold.calendar, size: 22),
              label: 'Calendário',
            ),
            BottomNavigationBarItem(
              icon: PhosphorIcon(PhosphorIconsRegular.book, size: 22),
              activeIcon: PhosphorIcon(PhosphorIconsBold.book, size: 22),
              label: 'Período',
            ),
          ],
        ),
      ),
    );
  }
}

/// Aba Home
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OvsbMissing'),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIconsRegular.gear, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
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
          final frequenciaAtual = CalculosFaltas.getFrequenciaAtual(
            diasLetivos.length,
            faltasUsadas,
          );

          // Próximos eventos importantes
          final proximosEventos = eventosProvider.getProximosEventosImportantes(limit: 5);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de saldo
                CardSaldo(
                  saldo: saldo,
                  faltasPermitidas: faltasPermitidas,
                  faltasUsadas: faltasUsadas,
                  margem: margem,
                ),
                const SizedBox(height: 16),

                // Botão sugerir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSugerir(context),
                    icon: PhosphorIcon(PhosphorIconsRegular.sparkle, size: 18),
                    label: const Text('Sugerir próximo descanso'),
                  ),
                ),
                const SizedBox(height: 24),

                // Estatísticas rápidas
                Row(
                  children: [
                    _StatCard(
                      valor: '${frequenciaAtual.toStringAsFixed(1)}%',
                      label: 'Frequência',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      valor: '${diasLetivos.length}',
                      label: 'Dias letivos',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      valor: '${_diasRestantes(periodo)}',
                      label: 'Dias restantes',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Próximos compromissos
                Text(
                  'Próximos compromissos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (proximosEventos.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: KindleColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: KindleColors.light),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Nenhum dia importante adicionado',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: KindleColors.medium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adicione provas e entregas no calendário',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: proximosEventos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final evento = proximosEventos[index];
                        final data = DateTime.parse(evento.data);
                        return _EventoCard(evento: evento, data: data);
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Mini calendário
                const MiniCalendario(),
              ],
            ),
          );
        },
      ),
    );
  }

  int _diasRestantes(periodo) {
    final fim = DateTime.parse(periodo.dataFim);
    final hoje = DateTime.now();
    return fim.difference(hoje).inDays.clamp(0, 9999);
  }

  void _handleSugerir(BuildContext context) {
    final periodoProvider = context.read<PeriodoProvider>();
    final faltasProvider = context.read<FaltasProvider>();
    final eventosProvider = context.read<EventosProvider>();

    final periodo = periodoProvider.periodo;
    if (periodo == null) return;

    final sugestao = CalculosFaltas.sugerirProximoDescanso(
      periodo,
      periodoProvider.diasEspeciais,
      faltasProvider.faltas,
      eventosProvider.eventos,
    );

    if (sugestao != null) {
      // Navegar para o calendário com a data selecionada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dia sugerido: $sugestao'),
          backgroundColor: KindleColors.black,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum dia disponível para sugestão'),
          backgroundColor: KindleColors.dark,
        ),
      );
    }
  }
}

/// Card de estatística
class _StatCard extends StatelessWidget {
  final String valor;
  final String label;

  const _StatCard({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: KindleColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KindleColors.light),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de evento
class _EventoCard extends StatelessWidget {
  final dynamic evento;
  final DateTime data;

  const _EventoCard({required this.evento, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KindleColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KindleColors.light),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data.day.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            mesesAbrev[data.month - 1],
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            evento.descricao,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: KindleColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aba Período (placeholder - será implementada em periodo_screen.dart)
class _PeriodoTab extends StatelessWidget {
  const _PeriodoTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Período')),
      body: const Center(child: Text('Tela de Período')),
    );
  }
}
