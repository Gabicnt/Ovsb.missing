import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constantes.dart';
import 'database_service.dart';

/// Serviço para buscar feriados da BrasilAPI
class FeriadosService {
  FeriadosService._();
  static final FeriadosService instance = FeriadosService._();

  /// Busca feriados do ano, primeiro do cache, depois da API
  Future<List<Feriado>> getFeriados(int ano) async {
    // Tentar do cache primeiro
    final cached = await _getFeriadosCache(ano);
    if (cached.isNotEmpty) {
      return cached;
    }

    // Buscar da API
    try {
      final feriados = await _fetchFeriadosApi(ano);
      // Salvar no cache
      await _cacheFeriados(ano, feriados);
      return feriados;
    } catch (e) {
      print('Erro ao buscar feriados da API: $e');
      return [];
    }
  }

  /// Busca feriados da BrasilAPI
  Future<List<Feriado>> _fetchFeriadosApi(int ano) async {
    final url = '${AppConstants.brasilApiBaseUrl}${AppConstants.feriadosEndpoint}/$ano';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((f) => Feriado.fromJson(f)).toList();
    } else {
      throw Exception('Falha ao buscar feriados: ${response.statusCode}');
    }
  }

  /// Busca feriados do cache local
  Future<List<Feriado>> _getFeriadosCache(int ano) async {
    final cached = await DatabaseService.instance.getFeriadosCache(ano);
    return cached.map((f) => Feriado(
      date: f['data'] as String,
      name: f['nome'] as String,
      type: 'national',
    )).toList();
  }

  /// Salva feriados no cache local
  Future<void> _cacheFeriados(int ano, List<Feriado> feriados) async {
    final data = feriados.map((f) => {
      'date': f.date,
      'name': f.name,
    }).toList();
    await DatabaseService.instance.cacheFeriados(ano, data);
  }

  /// Força atualização dos feriados da API
  Future<List<Feriado>> refreshFeriados(int ano) async {
    final feriados = await _fetchFeriadosApi(ano);
    await _cacheFeriados(ano, feriados);
    return feriados;
  }
}

/// Modelo de feriado
class Feriado {
  final String date; // yyyy-MM-dd
  final String name;
  final String type;

  const Feriado({
    required this.date,
    required this.name,
    required this.type,
  });

  factory Feriado.fromJson(Map<String, dynamic> json) {
    return Feriado(
      date: json['date'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'national',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'name': name,
      'type': type,
    };
  }
}
