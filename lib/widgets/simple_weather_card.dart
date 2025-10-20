import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../models/weather_data.dart';
import '../models/location_data.dart';
import '../utils/weather_utils.dart';

/// Carte météo simplifiée et optimisée pour éviter les overflows
class SimpleWeatherCard extends StatelessWidget {
  final WeatherData weatherData;
  final LocationData location;
  final VoidCallback? onRefresh;

  const SimpleWeatherCard({
    super.key,
    required this.weatherData,
    required this.location,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête avec localisation
                _buildHeader(),
                
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Section principale avec température et icône
                _buildMainSection(isSmallScreen),
                
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Statistiques météo
                _buildStatsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                location.country,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (onRefresh != null)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onRefresh!();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildMainSection(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône météo
        Container(
          width: isSmallScreen ? 60 : 70,
          height: isSmallScreen ? 60 : 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Center(
            child: Icon(
              WeatherUtils.getWeatherIcon(weatherData.mainCondition),
              size: isSmallScreen ? 35 : 40,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Température
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weatherData.temperature.round()}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 48 : 56,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Text(
              weatherData.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.thermostat_rounded,
            label: 'Ressenti',
            value: '${weatherData.feelsLike.round()}°',
          ),
          _buildStatItem(
            icon: Icons.water_drop_rounded,
            label: 'Humidité',
            value: '${weatherData.humidity}%',
          ),
          _buildStatItem(
            icon: Icons.air_rounded,
            label: 'Vent',
            value: '${weatherData.windSpeed.round()} km/h',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
