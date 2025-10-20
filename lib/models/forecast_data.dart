/// Modèle pour les prévisions météorologiques
class ForecastData {
  final DateTime dateTime;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String mainCondition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double pop; // Probability of precipitation

  ForecastData({
    required this.dateTime,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Modèle pour les prévisions sur 5 jours
class WeatherForecast {
  final List<ForecastData> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherForecast({
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    List<ForecastData> hourly = [];
    List<DailyForecast> daily = [];

    // Traiter les données horaires
    for (var item in json['list']) {
      hourly.add(ForecastData.fromJson(item));
    }

    // Grouper par jour pour les prévisions quotidiennes
    Map<String, List<ForecastData>> groupedByDay = {};
    for (var forecast in hourly) {
      String dayKey = '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(forecast);
    }

    // Créer les prévisions quotidiennes
    groupedByDay.forEach((day, forecasts) {
      if (forecasts.isNotEmpty) {
        daily.add(DailyForecast.fromHourlyForecasts(forecasts));
      }
    });

    return WeatherForecast(
      hourlyForecast: hourly.take(24).toList(), // 24h seulement
      dailyForecast: daily.take(7).toList(), // 7 jours seulement
    );
  }
}

/// Modèle pour les prévisions quotidiennes
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String mainCondition;
  final String icon;
  final double pop;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.pop,
  });

  factory DailyForecast.fromHourlyForecasts(List<ForecastData> hourlyForecasts) {
    if (hourlyForecasts.isEmpty) {
      throw ArgumentError('La liste des prévisions horaires ne peut pas être vide');
    }

    // Calculer min/max température
    double minTemp = hourlyForecasts.map((f) => f.minTemp).reduce((a, b) => a < b ? a : b);
    double maxTemp = hourlyForecasts.map((f) => f.maxTemp).reduce((a, b) => a > b ? a : b);
    
    // Prendre la condition la plus fréquente
    Map<String, int> conditionCount = {};
    for (var forecast in hourlyForecasts) {
      conditionCount[forecast.mainCondition] = (conditionCount[forecast.mainCondition] ?? 0) + 1;
    }
    
    String mostFrequentCondition = conditionCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Trouver l'icône et la description correspondantes
    ForecastData representativeForecast = hourlyForecasts
        .firstWhere((f) => f.mainCondition == mostFrequentCondition);

    // Calculer la probabilité moyenne de précipitations
    double avgPop = hourlyForecasts.map((f) => f.pop).reduce((a, b) => a + b) / hourlyForecasts.length;

    return DailyForecast(
      date: hourlyForecasts.first.dateTime,
      minTemp: minTemp,
      maxTemp: maxTemp,
      description: representativeForecast.description,
      mainCondition: mostFrequentCondition,
      icon: representativeForecast.icon,
      pop: avgPop,
    );
  }
}
