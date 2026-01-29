import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Servicio para verificar el estado de conectividad
class ConnectivityService {
  ConnectivityService() : _connectivity = Connectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _connectivityController.add(_isConnected(results));
      },
    );
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream que emite el estado de conectividad (true = online, false = offline)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Verifica si hay conexión a internet
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) =>
        result != ConnectivityResult.none &&
        result != ConnectivityResult.bluetooth);
    return hasConnection;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
