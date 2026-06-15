import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constantes.dart';

/// Serviço de banco de dados SQLite
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de períodos
    await db.execute('''
      CREATE TABLE periodos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        data_inicio TEXT NOT NULL,
        data_fim TEXT NOT NULL,
        frequencia_minima REAL NOT NULL DEFAULT 0.75,
        inclui_sabado INTEGER NOT NULL DEFAULT 0,
        inclui_domingo INTEGER NOT NULL DEFAULT 0,
        margem_tipo TEXT NOT NULL DEFAULT 'percentual',
        margem_valor REAL NOT NULL DEFAULT 10.0,
        margem_ativa INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabela de dias especiais
    await db.execute('''
      CREATE TABLE dias_especiais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        FOREIGN KEY (periodo_id) REFERENCES periodos (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de faltas
    await db.execute('''
      CREATE TABLE faltas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'real',
        sincronizado_calendar INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (periodo_id) REFERENCES periodos (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de eventos
    await db.execute('''
      CREATE TABLE eventos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        notificar INTEGER NOT NULL DEFAULT 1,
        antecedencia_notificacao TEXT,
        FOREIGN KEY (periodo_id) REFERENCES periodos (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de configurações
    await db.execute('''
      CREATE TABLE configuracoes (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    // Tabela de cache de feriados
    await db.execute('''
      CREATE TABLE feriados_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ano INTEGER NOT NULL,
        data TEXT NOT NULL,
        nome TEXT NOT NULL,
        UNIQUE(ano, data)
      )
    ''');

    // Índices para performance
    await db.execute('CREATE INDEX idx_dias_especiais_periodo ON dias_especiais (periodo_id)');
    await db.execute('CREATE INDEX idx_dias_especiais_data ON dias_especiais (data)');
    await db.execute('CREATE INDEX idx_faltas_periodo ON faltas (periodo_id)');
    await db.execute('CREATE INDEX idx_faltas_data ON faltas (data)');
    await db.execute('CREATE INDEX idx_eventos_periodo ON eventos (periodo_id)');
    await db.execute('CREATE INDEX idx_eventos_data ON eventos (data)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Futuras migrações de schema
  }

  // ============ CRUD Períodos ============

  Future<int> insertPeriodo(Map<String, dynamic> periodo) async {
    final db = await database;
    return await db.insert('periodos', periodo);
  }

  Future<Map<String, dynamic>?> getPeriodo(int id) async {
    final db = await database;
    final results = await db.query('periodos', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllPeriodos() async {
    final db = await database;
    return await db.query('periodos', orderBy: 'data_inicio DESC');
  }

  Future<int> updatePeriodo(int id, Map<String, dynamic> periodo) async {
    final db = await database;
    return await db.update('periodos', periodo, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePeriodo(int id) async {
    final db = await database;
    return await db.delete('periodos', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CRUD Dias Especiais ============

  Future<int> insertDiaEspecial(Map<String, dynamic> dia) async {
    final db = await database;
    return await db.insert('dias_especiais', dia);
  }

  Future<List<Map<String, dynamic>>> getDiasEspeciais(int periodoId) async {
    final db = await database;
    return await db.query(
      'dias_especiais',
      where: 'periodo_id = ?',
      whereArgs: [periodoId],
      orderBy: 'data ASC',
    );
  }

  Future<int> deleteDiaEspecial(int id) async {
    final db = await database;
    return await db.delete('dias_especiais', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDiasEspeciaisByTipo(int periodoId, String tipo) async {
    final db = await database;
    return await db.delete(
      'dias_especiais',
      where: 'periodo_id = ? AND tipo = ?',
      whereArgs: [periodoId, tipo],
    );
  }

  // ============ CRUD Faltas ============

  Future<int> insertFalta(Map<String, dynamic> falta) async {
    final db = await database;
    return await db.insert('faltas', falta);
  }

  Future<List<Map<String, dynamic>>> getFaltas(int periodoId) async {
    final db = await database;
    return await db.query(
      'faltas',
      where: 'periodo_id = ?',
      whereArgs: [periodoId],
      orderBy: 'data ASC',
    );
  }

  Future<Map<String, dynamic>?> getFaltaByData(int periodoId, String data) async {
    final db = await database;
    final results = await db.query(
      'faltas',
      where: 'periodo_id = ? AND data = ?',
      whereArgs: [periodoId, data],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteFalta(int id) async {
    final db = await database;
    return await db.delete('faltas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFaltaByData(int periodoId, String data) async {
    final db = await database;
    return await db.delete(
      'faltas',
      where: 'periodo_id = ? AND data = ?',
      whereArgs: [periodoId, data],
    );
  }

  // ============ CRUD Eventos ============

  Future<int> insertEvento(Map<String, dynamic> evento) async {
    final db = await database;
    return await db.insert('eventos', evento);
  }

  Future<List<Map<String, dynamic>>> getEventos(int periodoId) async {
    final db = await database;
    return await db.query(
      'eventos',
      where: 'periodo_id = ?',
      whereArgs: [periodoId],
      orderBy: 'data ASC',
    );
  }

  Future<int> updateEvento(int id, Map<String, dynamic> evento) async {
    final db = await database;
    return await db.update('eventos', evento, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEvento(int id) async {
    final db = await database;
    return await db.delete('eventos', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Configurações ============

  Future<void> setConfig(String chave, String valor) async {
    final db = await database;
    await db.insert(
      'configuracoes',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getConfig(String chave) async {
    final db = await database;
    final results = await db.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );
    return results.isNotEmpty ? results.first['valor'] as String : null;
  }

  // ============ Cache de Feriados ============

  Future<void> cacheFeriados(int ano, List<Map<String, dynamic>> feriados) async {
    final db = await database;
    final batch = db.batch();

    for (final f in feriados) {
      batch.insert(
        'feriados_cache',
        {'ano': ano, 'data': f['date'], 'nome': f['name']},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getFeriadosCache(int ano) async {
    final db = await database;
    return await db.query(
      'feriados_cache',
      where: 'ano = ?',
      whereArgs: [ano],
      orderBy: 'data ASC',
    );
  }

  // ============ Utilitários ============

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('eventos');
    await db.delete('faltas');
    await db.delete('dias_especiais');
    await db.delete('periodos');
    await db.delete('configuracoes');
  }

  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    return {
      'periodos': await db.query('periodos'),
      'dias_especiais': await db.query('dias_especiais'),
      'faltas': await db.query('faltas'),
      'eventos': await db.query('eventos'),
      'configuracoes': await db.query('configuracoes'),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;
    
    // Limpar dados existentes
    await clearAllData();

    // Importar períodos
    if (data['periodos'] != null) {
      for (final p in data['periodos']) {
        await db.insert('periodos', Map<String, dynamic>.from(p));
      }
    }

    // Importar dias especiais
    if (data['dias_especiais'] != null) {
      for (final d in data['dias_especiais']) {
        await db.insert('dias_especiais', Map<String, dynamic>.from(d));
      }
    }

    // Importar faltas
    if (data['faltas'] != null) {
      for (final f in data['faltas']) {
        await db.insert('faltas', Map<String, dynamic>.from(f));
      }
    }

    // Importar eventos
    if (data['eventos'] != null) {
      for (final e in data['eventos']) {
        await db.insert('eventos', Map<String, dynamic>.from(e));
      }
    }

    // Importar configurações
    if (data['configuracoes'] != null) {
      for (final c in data['configuracoes']) {
        await db.insert('configuracoes', Map<String, dynamic>.from(c));
      }
    }
  }
}
