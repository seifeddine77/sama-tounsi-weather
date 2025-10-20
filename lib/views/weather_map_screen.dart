import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes/modern_theme.dart';
import '../services/weather_service.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final MapController _mapController = MapController();
  final WeatherService _weatherService = WeatherService();
  
  // Position initiale (Paris)
  LatLng _currentPosition = LatLng(48.8566, 2.3522);
  double _currentZoom = 5.0;
  
  // Couche météo sélectionnée
  String _selectedLayer = 'temp';
  
  // Villes principales avec leurs coordonnées
  final List<CityWeather> _cities = [];
  
  // Layers disponibles
  final Map<String, String> _weatherLayers = {
    'temp': 'Température',
    'precipitation': 'Précipitations',
    'clouds': 'Nuages',
    'wind': 'Vent',
    'pressure': 'Pression',
  };

  @override
  void initState() {
    super.initState();
    _loadCitiesWeather();
  }

  Future<void> _loadCitiesWeather() async {
    // Villes principales à afficher
    final cities = [
      {'name': 'Paris', 'lat': 48.8566, 'lon': 2.3522},
      {'name': 'Londres', 'lat': 51.5074, 'lon': -0.1278},
      {'name': 'Berlin', 'lat': 52.5200, 'lon': 13.4050},
      {'name': 'Madrid', 'lat': 40.4168, 'lon': -3.7038},
      {'name': 'Rome', 'lat': 41.9028, 'lon': 12.4964},
      {'name': 'Istanbul', 'lat': 41.0082, 'lon': 28.9784},
      {'name': 'Tunis', 'lat': 36.8065, 'lon': 10.1815},
      {'name': 'Dubai', 'lat': 25.2048, 'lon': 55.2708},
      {'name': 'New York', 'lat': 40.7128, 'lon': -74.0060},
      {'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503},
      {'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093},
    ];

    for (var city in cities) {
      try {
        final weather = await _weatherService.getCurrentWeather(
          city['lat'] as double,
          city['lon'] as double,
        );
        
        setState(() {
          _cities.add(CityWeather(
            name: city['name'] as String,
            position: LatLng(city['lat'] as double, city['lon'] as double),
            temperature: weather.temperature,
            condition: weather.mainCondition,
            icon: weather.icon,
          ));
        });
      } catch (e) {
        print('Erreur chargement météo pour ${city['name']}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Carte interactive
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition,
              zoom: _currentZoom,
              minZoom: 2.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) => _handleMapTap(point),
            ),
            children: [
              // Couche de base OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_app',
              ),
              
              // Couche météo (commentée car nécessite une API key)
              // Pour activer : remplacez YOUR_API_KEY par votre clé OpenWeatherMap
              // TileLayer(
              //   urlTemplate: 'https://tile.openweathermap.org/map/${_selectedLayer}_new/{z}/{x}/{y}.png?appid=YOUR_API_KEY',
              //   opacity: 0.6,
              // ),
              
              // Marqueurs des villes
              MarkerLayer(
                markers: _cities.map((city) => _buildCityMarker(city)).toList(),
              ),
            ],
          ),
          
          // Header
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '🗺️ Carte Météo Interactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Sélecteur de couches
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: _weatherLayers.entries.map((entry) {
                  final isSelected = _selectedLayer == entry.key;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedLayer = entry.key;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getLayerIcon(entry.key),
                            color: isSelected ? Colors.blue : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Contrôles de zoom
          Positioned(
            bottom: 120,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1,
                    );
                  },
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1,
                    );
                  },
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
          
          // Bouton Ma Position
          Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'my_location_map',
              onPressed: () async {
                HapticFeedback.lightImpact();
                // Centrer sur la position actuelle
                _mapController.move(_currentPosition, 10);
              },
              backgroundColor: Colors.green.withOpacity(0.9),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          
          // Légende
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Légende',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.red],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getLegendText(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildCityMarker(CityWeather city) {
    return Marker(
      point: city.position,
      width: 80,
      height: 60,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showCityWeatherDetails(city);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                city.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getWeatherEmoji(city.condition),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${city.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMapTap(LatLng point) async {
    HapticFeedback.lightImpact();
    
    // Charger la météo pour le point cliqué
    try {
      final weather = await _weatherService.getCurrentWeather(
        point.latitude,
        point.longitude,
      );
      
      if (mounted) {
        _showWeatherAtLocation(point, weather);
      }
    } catch (e) {
      print('Erreur chargement météo: $e');
    }
  }

  void _showCityWeatherDetails(CityWeather city) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              city.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getWeatherEmoji(city.condition),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Text(
                  '${city.temperature.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              city.condition,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeatherAtLocation(LatLng point, weather) {
    // Afficher les détails météo pour un point cliqué
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weather.cityName.isNotEmpty ? weather.cityName : 'Position sélectionnée',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getWeatherEmoji(weather.mainCondition),
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Text(
                  '${weather.temperature.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              weather.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lat: ${point.latitude.toStringAsFixed(4)}, Lon: ${point.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLayerIcon(String layer) {
    switch (layer) {
      case 'temp':
        return Icons.thermostat;
      case 'precipitation':
        return Icons.water_drop;
      case 'clouds':
        return Icons.cloud;
      case 'wind':
        return Icons.air;
      case 'pressure':
        return Icons.speed;
      default:
        return Icons.layers;
    }
  }

  String _getLegendText() {
    switch (_selectedLayer) {
      case 'temp':
        return '-40°C → +40°C';
      case 'precipitation':
        return '0mm → 100mm';
      case 'clouds':
        return '0% → 100%';
      case 'wind':
        return '0 → 50 m/s';
      case 'pressure':
        return '960 → 1060 hPa';
      default:
        return '';
    }
  }

  String _getWeatherEmoji(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return '☀️';
    } else if (lowerCondition.contains('cloud')) {
      return '☁️';
    } else if (lowerCondition.contains('rain')) {
      return '🌧️';
    } else if (lowerCondition.contains('storm') || lowerCondition.contains('thunder')) {
      return '⛈️';
    } else if (lowerCondition.contains('snow')) {
      return '❄️';
    } else if (lowerCondition.contains('mist') || lowerCondition.contains('fog')) {
      return '🌫️';
    }
    return '🌤️';
  }
}

class CityWeather {
  final String name;
  final LatLng position;
  final double temperature;
  final String condition;
  final String icon;

  CityWeather({
    required this.name,
    required this.position,
    required this.temperature,
    required this.condition,
    required this.icon,
  });
}
