import 'package:flutter/material.dart';

/// Constantes de l'application
class AppConstants {
  // Couleurs du thème
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Dégradés pour différentes conditions météo
  static const LinearGradient sunnyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFFFFD700)],
  );
  
  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF708090), Color(0xFFD3D3D3)],
  );
  
  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C3E50), Color(0xFF4A6741)],
  );
  
  static const LinearGradient snowyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE6E6FA), Color(0xFFFFFFFF)],
  );
  
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF191970), Color(0xFF000080)],
  );
  
  // Tailles et espacements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Durées d'animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Clés de stockage local
  static const String favoriteCitiesKey = 'favorite_cities';
  static const String lastLocationKey = 'last_location';
  static const String themeKey = 'theme_mode';
  static const String lastWeatherDataKey = 'last_weather_data';
  
  // Messages d'erreur
  static const String networkError = 'Erreur de connexion réseau';
  static const String locationError = 'Impossible d\'obtenir la localisation';
  static const String apiError = 'Erreur lors de la récupération des données météo';
  static const String permissionError = 'Permission de localisation refusée';
  
  // Formats de date
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dayFormat = 'EEEE';
  
  // Icônes météo personnalisées (mapping avec les codes OpenWeatherMap)
  static const Map<String, IconData> weatherIcons = {
    '01d': Icons.wb_sunny, // clear sky day
    '01n': Icons.nights_stay, // clear sky night
    '02d': Icons.wb_cloudy, // few clouds day
    '02n': Icons.cloud, // few clouds night
    '03d': Icons.cloud, // scattered clouds
    '03n': Icons.cloud,
    '04d': Icons.cloud_queue, // broken clouds
    '04n': Icons.cloud_queue,
    '09d': Icons.grain, // shower rain
    '09n': Icons.grain,
    '10d': Icons.beach_access, // rain day
    '10n': Icons.beach_access, // rain night
    '11d': Icons.flash_on, // thunderstorm
    '11n': Icons.flash_on,
    '13d': Icons.ac_unit, // snow
    '13n': Icons.ac_unit,
    '50d': Icons.blur_on, // mist
    '50n': Icons.blur_on,
  };
  
  // Couleurs pour les conditions météo
  static const Map<String, Color> weatherColors = {
    'Clear': Color(0xFFFFD700),
    'Clouds': Color(0xFF87CEEB),
    'Rain': Color(0xFF4682B4),
    'Drizzle': Color(0xFF6495ED),
    'Thunderstorm': Color(0xFF483D8B),
    'Snow': Color(0xFFE6E6FA),
    'Mist': Color(0xFFD3D3D3),
    'Fog': Color(0xFFD3D3D3),
    'Haze': Color(0xFFDDA0DD),
  };
}
