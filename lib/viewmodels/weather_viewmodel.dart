import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/location_data.dart';
import 'dart:async';
import '../services/weather_service.dart';
import '../services/location_service.dart';
// import '../services/notification_service.dart'; // Temporairement désactivé
import '../services/storage_service.dart';
import '../utils/web_utils.dart';
import '../providers/theme_provider.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  final ThemeProvider _themeProvider = ThemeProvider();
  // late final NotificationService _notificationService; // Temporairement désactivé
  String? _successMessage;
  bool _isLoading = false;
  bool _isLoadingForecast = false;
  String? _error;
  
  // Données météo
  WeatherData? _currentWeather;
  WeatherForecast? _forecast;
  LocationData? _currentLocation;
  
  // Villes favorites
  List<LocationData> _favoriteCities = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingForecast => _isLoadingForecast;
  String? get error => _error;
  String? get successMessage => _successMessage;
  WeatherData? get currentWeather => _currentWeather;
  WeatherForecast? get forecast => _forecast;
  LocationData? get currentLocation => _currentLocation;
  List<LocationData> get favoriteCities => _favoriteCities;
  ThemeProvider get themeProvider => _themeProvider;
  
  bool get hasData => _currentWeather != null;
  bool get hasForecast => _forecast != null;
  bool get hasWeatherData => _currentWeather != null;
  WeatherData? get weatherData => _currentWeather;
  
  // Getters pour les prévisions
  List<ForecastData> get hourlyForecast => _forecast?.hourlyForecast ?? [];
  List<DailyForecast> get dailyForecast => _forecast?.dailyForecast ?? [];

  /// Initialise le ViewModel
  Future<void> init({bool withLocation = true}) async {
    print('WeatherViewModel: Début initialisation');
    try {
      await _storageService.init();
      print('WeatherViewModel: StorageService initialisé');
      
      // Initialiser les notifications (désactivé temporairement)
      // _notificationService = NotificationService();
      // await _notificationService.initialize();
      // print('WeatherViewModel: NotificationService initialisé');
      
      _loadFavoriteCities();
      print('WeatherViewModel: Favoris chargés');
      
      if (withLocation) {
        await loadCurrentLocationWeather();
        print('WeatherViewModel: Météo chargée');
      } else {
        // Charger une ville par défaut ou les dernières données sauvegardées
        await _loadLastSavedData();
        if (_currentWeather == null) {
          // Si aucune donnée sauvegardée, charger Paris par défaut
          await loadWeatherForCity('Paris');
        }
      }
    } catch (e) {
      print('WeatherViewModel: Erreur init - $e');
      // En cas d'erreur, essayer de charger les dernières données
      _setError('Erreur d\'initialisation: $e');
      await _loadLastSavedData();
    }
  }

  /// Charge les données météo pour la position actuelle
  Future<void> loadCurrentLocationWeather({bool skipIfNoPermission = false}) async {
    print('WeatherViewModel: Début chargement localisation');
    _setLoading(true);
    _clearError();

    try {
      // Obtenir la localisation actuelle
      print('WeatherViewModel: Récupération localisation...');
      _currentLocation = await _locationService.getCurrentLocationData();
      print('WeatherViewModel: Localisation obtenue: ${_currentLocation?.cityName}');
      
      // Charger les données météo
      await _loadWeatherForLocation(_currentLocation!);
      
      // Sauvegarder la dernière localisation
      await _storageService.saveLastLocation(_currentLocation!);
      print('WeatherViewModel: Données météo chargées avec succès');
      
    } catch (e) {
      print('WeatherViewModel: Erreur chargement - $e');
      if (skipIfNoPermission && e.toString().contains('permission')) {
        // Si pas de permission et skip autorisé, charger une ville par défaut
        await loadWeatherForCity('Paris');
        return;
      }
      final errorMessage = kIsWeb ? WebUtils.handleWebError(e) : e.toString();
      _setError(errorMessage);
      
      // Sur le web, proposer une localisation par défaut si la géolocalisation échoue
      if (kIsWeb) {
        try {
          print('WeatherViewModel: Utilisation localisation par défaut');
          final defaultLocation = WebUtils.getDefaultLocation();
          await _loadWeatherForLocation(defaultLocation);
          _setError('Utilisation de la localisation par défaut (Paris). Autorisez la géolocalisation pour votre position.');
        } catch (defaultError) {
          print('WeatherViewModel: Erreur localisation par défaut - $defaultError');
          await _loadLastSavedData();
        }
      } else {
        await _loadLastSavedData();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les données météo pour une localisation spécifique
  Future<void> loadWeatherForLocation(LocationData location) async {
    _setLoading(true);
    _clearError();

    try {
      _currentLocation = location;
      await _loadWeatherForLocation(location);
      
      // Sauvegarder la dernière localisation
      await _storageService.saveLastLocation(location);
      
      _setSuccessMessage('Météo mise à jour pour ${location.cityName}');
      print('WeatherViewModel: Météo chargée avec succès pour ${location.cityName}');
    } catch (e) {
      print('WeatherViewModel: Erreur chargement météo - $e');
      _setError('Erreur lors du chargement de la météo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les prévisions météo
  Future<void> loadForecast() async {
    if (_currentLocation == null) return;

    _setLoadingForecast(true);
    
    try {
      _forecast = await _weatherService.getForecast(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des prévisions: $e');
    } finally {
      _setLoadingForecast(false);
    }
  }

  /// Recherche des villes
  Future<List<LocationData>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      return await _weatherService.searchCities(query);
    } catch (e) {
      _setError('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Ajoute une ville aux favoris
  Future<void> addToFavorites(LocationData location) async {
    try {
      final success = await _storageService.addFavoriteCity(location);
      if (success) {
        await _loadFavoriteCities();
        _setSuccessMessage('${location.cityName} ajoutée aux favoris !');
      } else {
        if (_favoriteCities.length >= 10) {
          _setError('Maximum 10 villes favorites autorisées');
        } else {
          _setError('Cette ville est déjà dans vos favoris');
        }
      }
    } catch (e) {
      _setError('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  /// Supprime une ville des favoris
  Future<void> removeFromFavorites(LocationData location) async {
    try {
      final success = await _storageService.removeFavoriteCity(location);
      if (success) {
        await _loadFavoriteCities();
        _setSuccessMessage('${location.cityName} supprimée des favoris');
      } else {
        _setError('Impossible de supprimer cette ville');
      }
    } catch (e) {
      _setError('Erreur lors de la suppression des favoris: $e');
    }
  }

  /// Vérifie si une ville est dans les favoris
  bool isFavorite(LocationData location) {
    return _storageService.isFavoriteCity(location);
  }

  /// Charge les données météo pour une ville spécifique
  Future<void> loadWeatherForCity(String cityName) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Rechercher la ville
      final cities = await searchCities(cityName);
      if (cities.isNotEmpty) {
        final location = cities.first;
        _currentLocation = location;
        await _loadWeatherForLocation(location);
        await loadForecast();
      } else {
        _setError('Ville "$cityName" non trouvée');
      }
    } catch (e) {
      _setError('Erreur lors du chargement de la ville: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualise les données météo
  Future<void> refresh() async {
    if (_currentLocation != null) {
      await _loadWeatherForLocation(_currentLocation!);
      await loadForecast();
    } else {
      await loadCurrentLocationWeather();
    }
  }

  /// Méthodes privées
  Future<void> _loadWeatherForLocation(LocationData location) async {
    print('WeatherViewModel: Chargement météo pour ${location.cityName}');
    _currentWeather = await _weatherService.getCurrentWeather(
      location.latitude,
      location.longitude,
    );
    
    print('WeatherViewModel: Météo reçue - cityName: ${_currentWeather!.cityName}');
    
    // Envoyer une notification pour les alertes météo importantes (désactivé temporairement)
    // if (_currentWeather != null) {
    //   await _checkAndSendWeatherAlert(_currentWeather!);
    // }
    
    // Mettre à jour le nom de la ville avec celui de l'API météo si disponible
    if (_currentWeather!.cityName.isNotEmpty && _currentWeather!.cityName != 'Localisation inconnue') {
      _currentLocation = LocationData(
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: _currentWeather!.cityName,
        country: _currentWeather!.country,
        state: location.state,
      );
      print('WeatherViewModel: Location mise à jour avec ${_currentLocation!.cityName}');
    } else {
      // Garder la localisation originale si l'API ne retourne pas de nom
      _currentLocation = location;
      print('WeatherViewModel: Garde la localisation originale ${_currentLocation!.cityName}');
    }
    
    // Sauvegarder les dernières données pour le mode offline
    await _storageService.saveLastWeatherData(_currentWeather!);
    
    // Mettre à jour le thème basé sur la météo
    _themeProvider.updateThemeFromWeather(_currentWeather!.mainCondition);
    
    notifyListeners();
    
    // Charger les prévisions en arrière-plan
    loadForecast();
  }

  Future<void> _loadFavoriteCities() async {
    _favoriteCities = _storageService.getFavoriteCities();
    notifyListeners();
  }

  Future<void> _loadLastSavedData() async {
    final lastLocation = _storageService.getLastLocation();
    final lastWeather = _storageService.getLastWeatherData();
    
    if (lastLocation != null && lastWeather != null) {
      _currentLocation = lastLocation;
      _currentWeather = lastWeather;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingForecast(bool loading) {
    _isLoadingForecast = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _successMessage = null; // Effacer le message de succès
    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _error = null; // Effacer l'erreur
    notifyListeners();
    
    // Effacer le message après 3 secondes
    Timer(const Duration(seconds: 3), () {
      _successMessage = null;
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _storageService.close();
    super.dispose();
  }

  /// Recherche et ajoute une ville aux favoris
  Future<void> searchAndAddCity(String cityName) async {
    try {
      print('WeatherViewModel: Recherche de la ville: $cityName');
      
      // Utiliser l'API de géocodage pour obtenir les coordonnées réelles
      final cities = await _weatherService.searchCities(cityName);
      
      if (cities.isNotEmpty) {
        final locationData = cities.first;
        print('WeatherViewModel: Ville trouvée - ${locationData.cityName}, ${locationData.country}');
        await addToFavorites(locationData);
      } else {
        print('WeatherViewModel: Aucune ville trouvée, utilisation du nom saisi');
        // Créer une entrée avec le nom saisi par l'utilisateur
        final locationData = LocationData(
          latitude: 48.8566, // Paris par défaut pour les coordonnées
          longitude: 2.3522,
          cityName: cityName.trim(), // Utiliser le nom exact saisi
          country: 'Inconnu',
        );
        await addToFavorites(locationData);
      }
    } catch (e) {
      print('WeatherViewModel: Erreur API, utilisation du nom saisi - $e');
      // En cas d'erreur, utiliser le nom saisi par l'utilisateur
      final locationData = LocationData(
        latitude: 48.8566, // Paris par défaut pour les coordonnées
        longitude: 2.3522,
        cityName: cityName.trim(), // Utiliser le nom exact saisi
        country: 'Inconnu',
      );
      await addToFavorites(locationData);
    }
  }

  /// Charge la météo pour une ville favorite sélectionnée
  Future<void> loadFavoriteWeather(LocationData location) async {
    _setLoading(true);
    _clearError();
    
    try {
      print('WeatherViewModel: Chargement météo pour ${location.cityName}');
      
      // Charger les données météo pour cette localisation
      _currentWeather = await _weatherService.getCurrentWeather(
        location.latitude,
        location.longitude,
      );
      
      // Mettre à jour la localisation actuelle
      _currentLocation = location;
      
      // Charger les prévisions
      await loadForecast();
      
      // Mettre à jour le thème
      if (_currentWeather != null) {
        _themeProvider.updateThemeFromWeather(_currentWeather!.mainCondition);
      }
      
      // Sauvegarder comme dernière localisation
      await _storageService.saveLastLocation(location);
      
      print('WeatherViewModel: Météo chargée avec succès pour ${location.cityName}');
      notifyListeners();
    } catch (e) {
      print('WeatherViewModel: Erreur chargement météo - $e');
      _setError('Erreur lors du chargement de la météo pour ${location.cityName}: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /* Désactivé temporairement - Notifications
  /// Vérifie et envoie une alerte météo si nécessaire
  Future<void> _checkAndSendWeatherAlert(WeatherData weather) async {
    try {
      // Alertes pour conditions extrêmes
      if (weather.temperature > 35) {
        await _notificationService.showWeatherAlert(
          title: 'Alerte Chaleur Extrême 🌡️',
          message: 'Température de ${weather.temperature.round()}°C à ${weather.cityName}. Restez hydraté!',
          type: 'heat',
        );
      } else if (weather.temperature < 0) {
        await _notificationService.showWeatherAlert(
          title: 'Alerte Gel ❄️',
          message: 'Température de ${weather.temperature.round()}°C à ${weather.cityName}. Risque de verglas!',
          type: 'cold',
        );
      } else if (weather.windSpeed > 50) {
        await _notificationService.showWeatherAlert(
          title: 'Alerte Vent Fort 💨',
          message: 'Vent de ${weather.windSpeed.round()} km/h à ${weather.cityName}. Soyez prudent!',
          type: 'wind',
        );
      } else if (weather.mainCondition.toLowerCase().contains('storm') || 
                 weather.mainCondition.toLowerCase().contains('orage')) {
        await _notificationService.showWeatherAlert(
          title: 'Alerte Orage ⛈️',
          message: 'Conditions orageuses à ${weather.cityName}. Restez à l\'abri!',
          type: 'storm',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }
  
  /// Envoie une notification de rappel quotidien
  Future<void> sendDailyWeatherNotification() async {
    if (_currentWeather != null) {
      await _notificationService.showWeatherNotification(_currentWeather!);
    }
  }
  
  /// Programme des notifications récurrentes
  Future<void> scheduleWeatherNotifications() async {
    if (_currentWeather != null) {
      await _notificationService.scheduleDailyWeatherNotification(
        weather: _currentWeather!,
        time: const TimeOfDay(hour: 8, minute: 0),
      );
    }
  }
  */
}
