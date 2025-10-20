import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/location_data.dart';
import '../constants/api_constants.dart';

/// Service pour gérer les appels API météo
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Récupère les données météo actuelles pour une localisation
  Future<WeatherData> getCurrentWeather(double latitude, double longitude) async {
    try {
      final url = ApiConstants.getCurrentWeatherUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données météo: $e');
    }
  }

  /// Récupère les prévisions météo pour une localisation
  Future<WeatherForecast> getForecast(double latitude, double longitude) async {
    try {
      final url = ApiConstants.getForecastUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherForecast.fromJson(data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des prévisions: $e');
    }
  }

  /// Recherche des villes par nom
  Future<List<LocationData>> searchCities(String cityName) async {
    try {
      final url = ApiConstants.getGeocodingUrl(cityName);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          if (item != null) {
            return LocationData.fromJson(item as Map<String, dynamic>);
          }
          return null;
        }).where((item) => item != null).cast<LocationData>().toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche de villes: $e');
    }
  }

  /// Géocodage inverse pour obtenir le nom de la ville à partir des coordonnées
  Future<LocationData?> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = ApiConstants.getReverseGeocodingUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LocationData.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors du géocodage inverse: $e');
    }
  }

  /// Vérifie si la clé API est configurée
  bool isApiKeyConfigured() {
    return ApiConstants.apiKey != 'YOUR_API_KEY_HERE' && 
           ApiConstants.apiKey.isNotEmpty;
  }
}
