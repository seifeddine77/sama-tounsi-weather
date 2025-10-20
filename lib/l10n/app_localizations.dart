import 'package:flutter/material.dart';

/// Classe pour gérer les traductions de l'application
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();

  /// Traductions
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Général
      'appTitle': 'Weather Pro',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'ok': 'OK',
      'search': 'Search',
      'settings': 'Settings',
      
      // Météo
      'currentWeather': 'Current Weather',
      'forecast': 'Forecast',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'temperature': 'Temperature',
      'feelsLike': 'Feels like',
      'humidity': 'Humidity',
      'windSpeed': 'Wind speed',
      'pressure': 'Pressure',
      'visibility': 'Visibility',
      'uvIndex': 'UV Index',
      'sunrise': 'Sunrise',
      'sunset': 'Sunset',
      
      // Conditions météo
      'clear': 'Clear',
      'clouds': 'Cloudy',
      'rain': 'Rain',
      'drizzle': 'Drizzle',
      'thunderstorm': 'Thunderstorm',
      'snow': 'Snow',
      'mist': 'Mist',
      'fog': 'Fog',
      
      // Messages
      'searchCity': 'Search for a city',
      'noResults': 'No results found',
      'locationPermissionDenied': 'Location permission denied',
      'locationServiceDisabled': 'Location service is disabled',
      'networkError': 'Network error. Check your connection',
      'unknownError': 'An unknown error occurred',
      'addToFavorites': 'Add to favorites',
      'removeFromFavorites': 'Remove from favorites',
      'maxFavoritesReached': 'Maximum favorites reached (10)',
      
      // Navigation
      'home': 'Home',
      'favorites': 'Favorites',
      'charts': 'Charts',
      'about': 'About',
    },
    'fr': {
      // Général
      'appTitle': 'Météo Pro',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'cancel': 'Annuler',
      'ok': 'OK',
      'search': 'Rechercher',
      'settings': 'Paramètres',
      
      // Météo
      'currentWeather': 'Météo actuelle',
      'forecast': 'Prévisions',
      'today': 'Aujourd\'hui',
      'tomorrow': 'Demain',
      'temperature': 'Température',
      'feelsLike': 'Ressenti',
      'humidity': 'Humidité',
      'windSpeed': 'Vitesse du vent',
      'pressure': 'Pression',
      'visibility': 'Visibilité',
      'uvIndex': 'Indice UV',
      'sunrise': 'Lever du soleil',
      'sunset': 'Coucher du soleil',
      
      // Conditions météo
      'clear': 'Ensoleillé',
      'clouds': 'Nuageux',
      'rain': 'Pluie',
      'drizzle': 'Bruine',
      'thunderstorm': 'Orage',
      'snow': 'Neige',
      'mist': 'Brume',
      'fog': 'Brouillard',
      
      // Messages
      'searchCity': 'Rechercher une ville',
      'noResults': 'Aucun résultat trouvé',
      'locationPermissionDenied': 'Permission de localisation refusée',
      'locationServiceDisabled': 'Service de localisation désactivé',
      'networkError': 'Erreur réseau. Vérifiez votre connexion',
      'unknownError': 'Une erreur inconnue s\'est produite',
      'addToFavorites': 'Ajouter aux favoris',
      'removeFromFavorites': 'Retirer des favoris',
      'maxFavoritesReached': 'Maximum de favoris atteint (10)',
      
      // Navigation
      'home': 'Accueil',
      'favorites': 'Favoris',
      'charts': 'Graphiques',
      'about': 'À propos',
    },
    'es': {
      // Général
      'appTitle': 'Clima Pro',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
      'cancel': 'Cancelar',
      'ok': 'OK',
      'search': 'Buscar',
      'settings': 'Ajustes',
      
      // Météo
      'currentWeather': 'Clima actual',
      'forecast': 'Pronóstico',
      'today': 'Hoy',
      'tomorrow': 'Mañana',
      'temperature': 'Temperatura',
      'feelsLike': 'Sensación térmica',
      'humidity': 'Humedad',
      'windSpeed': 'Velocidad del viento',
      'pressure': 'Presión',
      'visibility': 'Visibilidad',
      'uvIndex': 'Índice UV',
      'sunrise': 'Amanecer',
      'sunset': 'Atardecer',
      
      // Conditions météo
      'clear': 'Despejado',
      'clouds': 'Nublado',
      'rain': 'Lluvia',
      'drizzle': 'Llovizna',
      'thunderstorm': 'Tormenta',
      'snow': 'Nieve',
      'mist': 'Neblina',
      'fog': 'Niebla',
      
      // Messages
      'searchCity': 'Buscar una ciudad',
      'noResults': 'No se encontraron resultados',
      'locationPermissionDenied': 'Permiso de ubicación denegado',
      'locationServiceDisabled': 'Servicio de ubicación desactivado',
      'networkError': 'Error de red. Verifica tu conexión',
      'unknownError': 'Ocurrió un error desconocido',
      'addToFavorites': 'Agregar a favoritos',
      'removeFromFavorites': 'Quitar de favoritos',
      'maxFavoritesReached': 'Máximo de favoritos alcanzado (10)',
      
      // Navigation
      'home': 'Inicio',
      'favorites': 'Favoritos',
      'charts': 'Gráficos',
      'about': 'Acerca de',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters pour un accès facile
  String get appTitle => get('appTitle');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get cancel => get('cancel');
  String get ok => get('ok');
  String get search => get('search');
  String get settings => get('settings');
  
  String get currentWeather => get('currentWeather');
  String get forecast => get('forecast');
  String get today => get('today');
  String get tomorrow => get('tomorrow');
  String get temperature => get('temperature');
  String get feelsLike => get('feelsLike');
  String get humidity => get('humidity');
  String get windSpeed => get('windSpeed');
  String get pressure => get('pressure');
  String get visibility => get('visibility');
  String get uvIndex => get('uvIndex');
  String get sunrise => get('sunrise');
  String get sunset => get('sunset');
  
  String get searchCity => get('searchCity');
  String get noResults => get('noResults');
  String get locationPermissionDenied => get('locationPermissionDenied');
  String get locationServiceDisabled => get('locationServiceDisabled');
  String get networkError => get('networkError');
  String get unknownError => get('unknownError');
  String get addToFavorites => get('addToFavorites');
  String get removeFromFavorites => get('removeFromFavorites');
  String get maxFavoritesReached => get('maxFavoritesReached');
  
  String get home => get('home');
  String get favorites => get('favorites');
  String get charts => get('charts');
  String get about => get('about');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
