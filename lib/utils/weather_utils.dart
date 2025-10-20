import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utilitaires pour les données météo
class WeatherUtils {
  /// Obtient le dégradé de couleur basé sur la condition météo et l'heure
  static LinearGradient getWeatherGradient(String condition, bool isDay) {
    if (!isDay) {
      return AppConstants.nightGradient;
    }
    
    switch (condition.toLowerCase()) {
      case 'clear':
        return AppConstants.sunnyGradient;
      case 'clouds':
        return AppConstants.cloudyGradient;
      case 'rain':
      case 'drizzle':
        return AppConstants.rainyGradient;
      case 'snow':
        return AppConstants.snowyGradient;
      default:
        return AppConstants.cloudyGradient;
    }
  }

  /// Obtient l'icône météo appropriée
  static IconData getWeatherIcon(String iconCode) {
    return AppConstants.weatherIcons[iconCode] ?? Icons.wb_cloudy;
  }

  /// Obtient la couleur basée sur la condition météo
  static Color getWeatherColor(String condition) {
    return AppConstants.weatherColors[condition] ?? AppConstants.lightBlue;
  }

  /// Détermine si c'est le jour ou la nuit basé sur l'heure
  static bool isDayTime(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 6 && hour < 20;
  }

  /// Formate la température
  static String formatTemperature(double temperature) {
    return '${temperature.round()}°';
  }

  /// Formate la vitesse du vent
  static String formatWindSpeed(double windSpeed) {
    return '${windSpeed.toStringAsFixed(1)} km/h';
  }

  /// Formate l'humidité
  static String formatHumidity(int humidity) {
    return '$humidity%';
  }

  /// Formate la pression
  static String formatPressure(int pressure) {
    return '$pressure hPa';
  }

  /// Formate la visibilité
  static String formatVisibility(double visibility) {
    final km = visibility / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Obtient la description de la qualité de l'air basée sur l'indice UV
  static String getUVDescription(int uvIndex) {
    if (uvIndex <= 2) return 'Faible';
    if (uvIndex <= 5) return 'Modéré';
    if (uvIndex <= 7) return 'Élevé';
    if (uvIndex <= 10) return 'Très élevé';
    return 'Extrême';
  }

  /// Obtient la couleur de l'indice UV
  static Color getUVColor(int uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  /// Convertit la direction du vent en degrés vers une description
  static String getWindDirection(double degrees) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSO', 'SO', 'OSO', 'O', 'ONO', 'NO', 'NNO'
    ];
    
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Obtient une description textuelle de la condition météo
  static String getWeatherDescription(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Ciel dégagé';
      case 'clouds':
        return 'Nuageux';
      case 'rain':
        return 'Pluie';
      case 'drizzle':
        return 'Bruine';
      case 'thunderstorm':
        return 'Orage';
      case 'snow':
        return 'Neige';
      case 'mist':
      case 'fog':
        return 'Brouillard';
      case 'haze':
        return 'Brume';
      default:
        return condition;
    }
  }

  /// Calcule l'indice de confort basé sur la température et l'humidité
  static String getComfortIndex(double temperature, int humidity) {
    if (temperature < 10) return 'Froid';
    if (temperature > 30) return 'Chaud';
    if (humidity > 70) return 'Humide';
    if (humidity < 30) return 'Sec';
    return 'Confortable';
  }

  /// Obtient des conseils basés sur les conditions météo
  static List<String> getWeatherAdvice(String condition, double temperature) {
    List<String> advice = [];
    
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        advice.add('N\'oubliez pas votre parapluie');
        advice.add('Portez des vêtements imperméables');
        break;
      case 'snow':
        advice.add('Habillez-vous chaudement');
        advice.add('Attention aux routes glissantes');
        break;
      case 'thunderstorm':
        advice.add('Évitez les activités extérieures');
        advice.add('Restez à l\'intérieur si possible');
        break;
      case 'clear':
        if (temperature > 25) {
          advice.add('Portez de la crème solaire');
          advice.add('Hydratez-vous régulièrement');
        }
        break;
    }
    
    if (temperature < 5) {
      advice.add('Risque de gel, protégez vos plantes');
    } else if (temperature > 35) {
      advice.add('Évitez l\'exposition prolongée au soleil');
    }
    
    return advice;
  }
}
