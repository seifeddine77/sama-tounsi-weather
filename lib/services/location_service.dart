import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/location_data.dart';
import 'weather_service.dart';

/// Service pour gérer la localisation
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final WeatherService _weatherService = WeatherService();

  /// Vérifie et demande les permissions de localisation
  Future<bool> checkLocationPermission() async {
    // Sur le web, utiliser directement Geolocator
    if (kIsWeb) {
      return await Geolocator.isLocationServiceEnabled();
    }
    
    final permission = await Permission.location.status;
    
    if (permission.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    return permission.isGranted;
  }

  /// Vérifie si les services de localisation sont activés
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    // Sur le web, gérer différemment les permissions
    if (kIsWeb) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Permission de localisation refusée');
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Permission de localisation refusée définitivement');
        }

        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        throw Exception('Impossible d\'obtenir la position: $e');
      }
    }

    // Pour mobile
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      throw Exception('Permission de localisation refusée');
    }

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Service de localisation désactivé');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw Exception('Impossible d\'obtenir la position: $e');
    }
  }

  /// Obtient les données de localisation avec le nom de la ville
  Future<LocationData> getCurrentLocationData() async {
    final position = await getCurrentPosition();
    
    final locationData = await _weatherService.reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (locationData != null) {
      return locationData;
    } else {
      // Fallback si le géocodage inverse échoue
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'Position actuelle',
        country: '',
      );
    }
  }

  /// Calcule la distance entre deux points géographiques
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Surveille les changements de position
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Mise à jour tous les 100 mètres
      ),
    );
  }
}
