/// Constantes pour l'API OpenWeatherMap
class ApiConstants {
  // IMPORTANT: Remplacez par votre clé API OpenWeatherMap
  static const String apiKey = 'f3149b7b3f73aefbdb9feaecbe6e5677';
  
  // URLs de base
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';
  
  // Endpoints
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  static const String geocodingEndpoint = '/direct';
  static const String reverseGeocodingEndpoint = '/reverse';
  
  // Paramètres par défaut
  static const String units = 'metric'; // Celsius
  static const String lang = 'fr'; // Français
  
  // Limites
  static const int maxCitiesSearch = 5;
  
  // URLs complètes
  static String getCurrentWeatherUrl(double lat, double lon) {
    return '$baseUrl$currentWeatherEndpoint?lat=$lat&lon=$lon&appid=$apiKey&units=$units&lang=$lang';
  }
  
  static String getForecastUrl(double lat, double lon) {
    return '$baseUrl$forecastEndpoint?lat=$lat&lon=$lon&appid=$apiKey&units=$units&lang=$lang';
  }
  
  static String getGeocodingUrl(String cityName) {
    return '$geoUrl$geocodingEndpoint?q=$cityName&limit=$maxCitiesSearch&appid=$apiKey';
  }
  
  static String getReverseGeocodingUrl(double lat, double lon) {
    return '$geoUrl$reverseGeocodingEndpoint?lat=$lat&lon=$lon&limit=1&appid=$apiKey';
  }
  
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
