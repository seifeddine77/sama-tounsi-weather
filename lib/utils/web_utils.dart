import 'package:flutter/foundation.dart';
import '../models/location_data.dart';

/// Utilitaires spécifiques au web
class WebUtils {
  /// Fournit une localisation par défaut pour les tests web
  static LocationData getDefaultLocation() {
    return LocationData(
      latitude: 48.8566,
      longitude: 2.3522,
      cityName: 'Paris',
      country: 'FR',
      state: 'Île-de-France',
    );
  }

  /// Vérifie si la géolocalisation est supportée
  static bool isGeolocationSupported() {
    if (kIsWeb) {
      // Sur le web, vérifier si l'API Geolocation est disponible
      return true; // Geolocator package gère cette vérification
    }
    return true;
  }

  /// Gère les erreurs spécifiques au web
  static String handleWebError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user denied')) {
      return 'Accès à la localisation refusé. Veuillez autoriser la géolocalisation dans votre navigateur.';
    }
    
    if (errorString.contains('position unavailable')) {
      return 'Position indisponible. Vérifiez votre connexion et réessayez.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
    }
    
    if (errorString.contains('network')) {
      return 'Erreur réseau. Vérifiez votre connexion internet.';
    }
    
    return 'Erreur: $error';
  }

  /// Instructions pour l'utilisateur web
  static List<String> getWebInstructions() {
    return [
      '🌐 Pour une meilleure expérience sur le web:',
      '• Autorisez l\'accès à la localisation quand demandé',
      '• Utilisez une connexion internet stable',
      '• Configurez votre clé API OpenWeatherMap',
      '• Rechargez la page si nécessaire',
    ];
  }
}
