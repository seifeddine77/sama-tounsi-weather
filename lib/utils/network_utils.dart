import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Utilitaires pour la gestion réseau
class NetworkUtils {
  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() => _instance;
  NetworkUtils._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _networkStatusController;
  
  Stream<bool> get networkStatusStream {
    _networkStatusController ??= StreamController<bool>.broadcast();
    return _networkStatusController!.stream;
  }

  /// Vérifie la connectivité réseau
  Future<bool> isConnected() async {
    try {
      if (kIsWeb) {
        // Pour le web, on vérifie différemment
        return true; // Le navigateur gère la connectivité
      }
      
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la connectivité: $e');
      return false;
    }
  }

  /// Vérifie la connexion Internet réelle (pas seulement le WiFi/données)
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Surveille les changements de connectivité
  void startMonitoring() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;
      _networkStatusController?.add(isConnected);
      
      if (!isConnected) {
        debugPrint('⚠️ Connexion réseau perdue');
      } else {
        debugPrint('✅ Connexion réseau rétablie');
      }
    });
  }

  /// Arrête la surveillance
  void stopMonitoring() {
    _networkStatusController?.close();
    _networkStatusController = null;
  }

  /// Retry une fonction avec backoff exponentiel
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() function,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await function();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        
        debugPrint('Tentative $attempt/$maxAttempts échouée. Nouvelle tentative dans ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= 2; // Backoff exponentiel
      }
    }

    throw Exception('Échec après $maxAttempts tentatives');
  }

  /// Wrapper pour les requêtes HTTP avec gestion d'erreur
  static Future<T> executeWithNetworkCheck<T>({
    required Future<T> Function() request,
    required T Function() onOffline,
  }) async {
    final networkUtils = NetworkUtils();
    
    if (!await networkUtils.isConnected()) {
      debugPrint('📵 Mode hors ligne - utilisation des données en cache');
      return onOffline();
    }

    try {
      return await request();
    } on SocketException {
      debugPrint('❌ Erreur réseau - basculement vers le cache');
      return onOffline();
    } on TimeoutException {
      debugPrint('⏱️ Timeout réseau - basculement vers le cache');
      return onOffline();
    }
  }
}
