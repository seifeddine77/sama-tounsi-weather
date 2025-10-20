/// Modèle de données pour les informations météorologiques actuelles
class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String mainCondition;
  final String icon;
  final DateTime dateTime;
  final DateTime sunrise;
  final DateTime sunset;
  final double visibility;
  final int uvIndex;
  final int timezoneOffset; // Décalage horaire en secondes

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.visibility,
    required this.uvIndex,
    required this.timezoneOffset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? 'Localisation inconnue',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      uvIndex: 0, // Nécessite un appel API séparé
      timezoneOffset: json['timezone'] ?? 0, // Décalage horaire en secondes depuis UTC
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'description': description,
      'mainCondition': mainCondition,
      'icon': icon,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'sunrise': sunrise.millisecondsSinceEpoch,
      'sunset': sunset.millisecondsSinceEpoch,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'timezoneOffset': timezoneOffset,
    };
  }
  
  /// Obtient l'heure locale de la ville en utilisant le décalage horaire
  DateTime getLocalTime() {
    // Obtenir l'heure UTC actuelle
    final utcNow = DateTime.now().toUtc();
    // Ajouter le décalage horaire de la ville
    return utcNow.add(Duration(seconds: timezoneOffset));
  }
}
