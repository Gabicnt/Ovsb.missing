import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/periodo_provider.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';
import '../utils/cores.dart';
import 'setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.x, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Período
          _SettingsItem(
            icon: PhosphorIconsRegular.flag,
            title: 'Período letivo',
            subtitle: 'Editar datas, frequência mínima',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
          ),
          const SizedBox(height: 8),

          // Aparência
          _SettingsItem(
            icon: PhosphorIconsRegular.palette,
            title: 'Aparência',
            subtitle: 'Tema automático (segue o sistema)',
            onTap: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isDark 
                    ? '🌙 Modo escuro ativo (automático)' 
                    : '☀️ Modo claro ativo (automático)'),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Notificações
          _SettingsItem(
            icon: PhosphorIconsRegular.bell,
            title: 'Notificações',
            subtitle: 'Configurar lembretes e alertas',
            onTap: () => _showNotificationSettings(context),
          ),
          const SizedBox(height: 24),

          // Seção Dados
          Text(
            'DADOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: KindleColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KindleColors.light),
            ),
            child: Column(
              children: [
                _SettingsListItem(
                  icon: PhosphorIconsRegular.downloadSimple,
                  title: 'Exportar backup',
                  subtitle: 'Salvar dados em arquivo JSON',
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsListItem(
                  icon: PhosphorIconsRegular.uploadSimple,
                  title: 'Restaurar backup',
                  subtitle: 'Carregar dados de arquivo JSON',
                  onTap: () => _importBackup(context),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsListItem(
                  icon: PhosphorIconsRegular.trash,
                  title: 'Apagar todos os dados',
                  subtitle: 'Resetar o aplicativo',
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

        // Sobre
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KindleColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KindleColors.light),
          ),
          child: Row(
            children: [
              PhosphorIcon(PhosphorIconsRegular.info, size: 20, color: KindleColors.dark),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre o OvsbMissing',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Versão 1.0 · Estilo Kindle',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Créditos
        Builder(
          builder: (context) {
            final colors = context.colors;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  PhosphorIcon(PhosphorIconsRegular.code, size: 32, color: colors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Desenvolvido por',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@BeaGabi.cnt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _openUrl('https://github.com/Gabicnt'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.buttonBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(PhosphorIconsRegular.githubLogo, size: 18, color: colors.buttonText),
                          const SizedBox(width: 8),
                          Text(
                            'GitHub',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colors.buttonText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Aviso
        Text(
          'Seus dados são armazenados localmente no dispositivo.\nNenhuma informação é enviada a servidores externos.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: KindleColors.medium,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Notificações ativas'),
                  subtitle: const Text('Receber lembretes e alertas'),
                  value: settings.notificacoesAtivas,
                  onChanged: (v) => settings.setNotificacoesAtivas(v),
                ),
                SwitchListTile(
                  title: const Text('Resumo semanal'),
                  subtitle: const Text('Receber resumo toda segunda-feira'),
                  value: settings.resumoSemanal,
                  onChanged: (v) => settings.setResumoSemanal(v),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Horário de notificação'),
                  subtitle: Text('${settings.horarioNotificacao}:00'),
                  trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: settings.horarioNotificacao, minute: 0),
                    );
                    if (time != null) {
                      settings.setHorarioNotificacao(time.hour);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      await BackupService.instance.shareBackup();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup exportado com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final success = await BackupService.instance.restoreBackup();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restaurado com sucesso')),
        );
        // Recarregar dados
        await context.read<PeriodoProvider>().loadPeriodo();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao restaurar: $e')),
      );
    }
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Esta ação não pode ser desfeita. Todos os seus períodos, faltas e eventos serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.instance.clearAllData();
              await context.read<PeriodoProvider>().clear();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KindleColors.dark,
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}

/// Item de configuração (card)
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KindleColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KindleColors.light),
        ),
        child: Row(
          children: [
            PhosphorIcon(icon, size: 20, color: KindleColors.dark),
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
          ],
        ),
      ),
    );
  }
}

/// Item de lista dentro de container
class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            PhosphorIcon(icon, size: 20, color: KindleColors.dark),
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
          ],
        ),
      ),
    );
  }
}
