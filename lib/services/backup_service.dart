import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';

/// Serviço de backup e restauração
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  /// Cria backup local e retorna o caminho do arquivo
  Future<String> createBackup() async {
    final data = await DatabaseService.instance.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final fileName = 'faltacontrol-backup-$timestamp.json';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(jsonString);
    
    return file.path;
  }

  /// Compartilha o backup
  Future<void> shareBackup() async {
    final filePath = await createBackup();
    await Share.shareXFiles([XFile(filePath)], text: 'Backup do FaltaControl');
  }

  /// Restaura backup de arquivo selecionado
  Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      await DatabaseService.instance.importAllData(data);
      
      return true;
    } catch (e) {
      print('Erro ao restaurar backup: $e');
      return false;
    }
  }

  /// Restaura backup de uma string JSON
  Future<bool> restoreFromJson(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      await DatabaseService.instance.importAllData(data);
      return true;
    } catch (e) {
      print('Erro ao restaurar backup: $e');
      return false;
    }
  }

  /// Lista backups locais existentes
  Future<List<FileSystemEntity>> listLocalBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((f) => f.path.contains('faltacontrol-backup') && f.path.endsWith('.json'))
        .toList();
    
    files.sort((a, b) => b.path.compareTo(a.path)); // Mais recente primeiro
    
    return files;
  }

  /// Deleta backup local
  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
