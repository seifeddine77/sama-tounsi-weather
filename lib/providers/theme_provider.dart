import 'package:flutter/material.dart';
import '../themes/modern_theme.dart';

/// Provider pour gérer le thème de l'application
class ThemeProvider extends ChangeNotifier {
  // Thème par défaut
  ThemeData _currentTheme = ModernTheme.getLightTheme();
  String _currentWeatherCondition = 'clear';
  bool _isDarkMode = false;

  ThemeData get currentTheme => _currentTheme;
  String get currentWeatherCondition => _currentWeatherCondition;
  bool get isDarkMode => _isDarkMode;

  /// Met à jour le thème en fonction de la météo
  void updateThemeFromWeather(String weatherCondition) {
    _currentWeatherCondition = weatherCondition;
    _updateTheme();
  }

  /// Active/désactive le mode sombre
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _updateTheme();
  }

  /// Définit explicitement le mode sombre
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _updateTheme();
  }

  /// Met à jour le thème en fonction des paramètres actuels
  void _updateTheme() {
    final newTheme = _isDarkMode 
        ? ModernTheme.getDarkTheme()
        : ModernTheme.getLightTheme();
    
    if (newTheme != _currentTheme) {
      _currentTheme = newTheme;
      notifyListeners();
    }
  }

  /// Obtient la couleur principale du thème actuel
  Color get primaryColor => _currentTheme.colorScheme.primary;
  
  /// Obtient la couleur de fond du thème actuel
  Color get backgroundColor => _currentTheme.colorScheme.background;
  
  /// Obtient la couleur de surface du thème actuel
  Color get surfaceColor => _currentTheme.colorScheme.surface;

  /// Vérifie si le thème actuel est sombre
  bool get isCurrentThemeDark => _currentTheme.brightness == Brightness.dark;

  /// Obtient un gradient basé sur la condition météo
  LinearGradient getWeatherGradient() {
    switch (_currentWeatherCondition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
        );
      
      case 'clouds':
      case 'cloudy':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFFBDC3C7), const Color(0xFFF9F9F9)],
        );
      
      case 'rain':
      case 'drizzle':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFF3498DB), const Color(0xFF4FC3F7)],
        );
      
      case 'thunderstorm':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
        );
      
      case 'snow':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
        );
      
      case 'mist':
      case 'fog':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
        );
      
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode 
            ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
            : [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
        );
    }
  }
}
