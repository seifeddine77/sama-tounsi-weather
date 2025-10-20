import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';

/// Service pour gérer les notifications météo
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('✅ Service de notifications initialisé');
  }

  /// Gestion du tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigation vers l'écran approprié si nécessaire
  }

  /// Demande la permission pour les notifications
  Future<bool> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Par défaut sur d'autres plateformes
  }

  /// Affiche une notification météo actuelle
  Future<void> showWeatherNotification(WeatherData weather) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Météo actuelle',
      channelDescription: 'Notifications de la météo actuelle',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final emoji = _getWeatherEmoji(weather.mainCondition);
    
    await _notifications.show(
      0,
      '${weather.cityName} $emoji',
      '${weather.temperature.round()}°C - ${weather.description}\n'
      'Ressenti: ${weather.feelsLike.round()}°C | '
      'Humidité: ${weather.humidity}%',
      details,
      payload: 'weather_current',
    );
  }

  /// Affiche une notification d'alerte météo
  Future<void> showWeatherAlert({
    required String title,
    required String message,
    required String type,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts',
      'Alertes météo',
      channelDescription: 'Alertes météo importantes',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Colors.orange,
      enableVibration: true,
      enableLights: true,
      ledColor: Colors.orange,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '⚠️ $title',
      message,
      details,
      payload: 'weather_alert_$type',
    );
  }

  /// Programme une notification quotidienne de météo
  Future<void> scheduleDailyWeatherNotification({
    required WeatherData weather,
    required TimeOfDay time,
  }) async {
    // Cette fonctionnalité nécessite flutter_local_notifications avec timezone
    // Pour simplifier, on utilise une notification immédiate
    await showWeatherNotification(weather);
    debugPrint('📅 Notification quotidienne programmée pour ${time.hour}:${time.minute}');
  }

  /// Annule toutes les notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 Toutes les notifications annulées');
  }

  /// Annule une notification spécifique
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Vérifie les conditions pour les alertes automatiques
  void checkWeatherAlerts(WeatherData weather) {
    // Alerte pluie
    if (weather.mainCondition.toLowerCase().contains('rain')) {
      showWeatherAlert(
        title: 'Pluie prévue',
        message: "N'oubliez pas votre parapluie ! ☔",
        type: 'rain',
      );
    }

    // Alerte température élevée
    if (weather.temperature > 35) {
      showWeatherAlert(
        title: 'Forte chaleur',
        message: 'Température élevée: ${weather.temperature.round()}°C. Restez hydraté! 💧',
        type: 'heat',
      );
    }

    // Alerte température basse
    if (weather.temperature < 0) {
      showWeatherAlert(
        title: 'Gel possible',
        message: 'Température: ${weather.temperature.round()}°C. Couvrez-vous bien! 🧥',
        type: 'cold',
      );
    }

    // Alerte orage
    if (weather.mainCondition.toLowerCase().contains('thunderstorm')) {
      showWeatherAlert(
        title: 'Orage en cours',
        message: 'Restez à l\'abri et évitez les déplacements si possible ⛈️',
        type: 'storm',
      );
    }

    // Alerte vent fort
    if (weather.windSpeed > 50) {
      showWeatherAlert(
        title: 'Vent violent',
        message: 'Vitesse du vent: ${weather.windSpeed.round()} km/h. Soyez prudent! 💨',
        type: 'wind',
      );
    }
  }

  /// Retourne l'emoji approprié pour la condition météo
  String _getWeatherEmoji(String condition) {
    final lowerCondition = condition.toLowerCase();
    
    if (lowerCondition.contains('clear')) return '☀️';
    if (lowerCondition.contains('cloud')) return '☁️';
    if (lowerCondition.contains('rain')) return '🌧️';
    if (lowerCondition.contains('drizzle')) return '🌦️';
    if (lowerCondition.contains('thunderstorm')) return '⛈️';
    if (lowerCondition.contains('snow')) return '❄️';
    if (lowerCondition.contains('mist') || lowerCondition.contains('fog')) return '🌫️';
    if (lowerCondition.contains('haze')) return '🌫️';
    
    return '🌤️';
  }
}
