import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Serviço para verificar conectividade
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  final _onlineController = StreamController<bool>.broadcast();
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Inicializa o serviço de conectividade
  Future<void> initialize() async {
    await _checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// Verifica conectividade atual
  Future<bool> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    _onlineController.add(_isOnline);
    return _isOnline;
  }

  /// Callback quando conectividade muda
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    _isOnline = !result.contains(ConnectivityResult.none);
    _onlineController.add(_isOnline);
  }

  /// Verifica se está online
  Future<bool> checkOnline() async {
    return await _checkConnectivity();
  }

  /// Dispõe recursos
  void dispose() {
    _subscription?.cancel();
    _onlineController.close();
  }
}
