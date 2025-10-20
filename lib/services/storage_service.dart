import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_data.dart';
import '../models/weather_data.dart';
import '../constants/app_constants.dart';

/// Service pour gérer le stockage local
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box _box;

  /// Initialise Hive et ouvre la box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('weather_app_storage');
  }

  /// Sauvegarde les villes favorites
  Future<void> saveFavoriteCities(List<LocationData> cities) async {
    final citiesJson = cities.map((city) => city.toJson()).toList();
    await _box.put(AppConstants.favoriteCitiesKey, citiesJson);
  }

  /// Récupère les villes favorites
  List<LocationData> getFavoriteCities() {
    try {
      final citiesJson = _box.get(AppConstants.favoriteCitiesKey, defaultValue: <dynamic>[]);
      return (citiesJson as List<dynamic>)
          .map((json) => LocationData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  /// Ajoute une ville aux favoris
  Future<bool> addFavoriteCity(LocationData city) async {
    final favorites = getFavoriteCities();
    
    print('StorageService: Tentative d\'ajout - ${city.cityName}, ${city.country}');
    print('StorageService: Favoris actuels: ${favorites.map((f) => '${f.cityName}/${f.country}').join(', ')}');
    
    // Vérifier la limite de favoris
    if (favorites.length >= 10) {
      print('StorageService: Limite de 10 favoris atteinte');
      return false; // Limite atteinte
    }
    
    // Vérifier si la ville n'est pas déjà dans les favoris avec tolérance
    final exists = favorites.any((fav) => _isSameLocation(fav, city));
    
    if (!exists) {
      favorites.add(city);
      await saveFavoriteCities(favorites);
      print('StorageService: Ville ajoutée avec succès - ${city.cityName}');
      return true; // Ajout réussi
    }
    
    print('StorageService: Ville déjà existante - ${city.cityName}');
    return false; // Déjà existant
  }

  /// Supprime une ville des favoris
  Future<bool> removeFavoriteCity(LocationData city) async {
    final favorites = getFavoriteCities();
    final initialLength = favorites.length;
    
    favorites.removeWhere((fav) => _isSameLocation(fav, city));
    
    if (favorites.length != initialLength) {
      await saveFavoriteCities(favorites);
      return true; // Suppression réussie
    }
    
    return false; // Aucun élément supprimé
  }

  /// Vérifie si une ville est dans les favoris
  bool isFavoriteCity(LocationData city) {
    final favorites = getFavoriteCities();
    return favorites.any((fav) => _isSameLocation(fav, city));
  }

  /// Compare deux localisations avec une tolérance pour les coordonnées GPS
  bool _isSameLocation(LocationData a, LocationData b) {
    // Comparaison par nom de ville d'abord (plus fiable)
    if (a.cityName.toLowerCase().trim() == b.cityName.toLowerCase().trim() &&
        a.country.toLowerCase().trim() == b.country.toLowerCase().trim()) {
      return true;
    }
    
    // Comparaison par coordonnées GPS en fallback
    const double tolerance = 0.0001; // ~11 mètres de précision
    return (a.latitude - b.latitude).abs() < tolerance &&
           (a.longitude - b.longitude).abs() < tolerance;
  }

  /// Sauvegarde la dernière localisation
  Future<void> saveLastLocation(LocationData location) async {
    await _box.put(AppConstants.lastLocationKey, location.toJson());
  }

  /// Récupère la dernière localisation
  LocationData? getLastLocation() {
    final locationJson = _box.get(AppConstants.lastLocationKey);
    if (locationJson != null) {
      return LocationData.fromJson(locationJson as Map<String, dynamic>);
    }
    return null;
  }

  /// Sauvegarde le mode thème
  Future<void> saveThemeMode(String themeMode) async {
    await _box.put(AppConstants.themeKey, themeMode);
  }

  /// Récupère le mode thème
  String getThemeMode() {
    return _box.get(AppConstants.themeKey, defaultValue: 'system');
  }

  /// Sauvegarde les dernières données météo (pour le mode offline)
  Future<void> saveLastWeatherData(WeatherData weatherData) async {
    await _box.put(AppConstants.lastWeatherDataKey, weatherData.toJson());
  }

  /// Récupère les dernières données météo
  WeatherData? getLastWeatherData() {
    final weatherJson = _box.get(AppConstants.lastWeatherDataKey);
    if (weatherJson != null) {
      return WeatherData.fromJson(weatherJson as Map<String, dynamic>);
    }
    return null;
  }

  /// Efface toutes les données stockées
  Future<void> clearAllData() async {
    await _box.clear();
  }

  /// Ferme la box Hive
  Future<void> close() async {
    await _box.close();
  }
}
