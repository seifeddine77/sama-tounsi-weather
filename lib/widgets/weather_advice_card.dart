import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/weather_utils.dart';

class WeatherAdviceCard extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherAdviceCard({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final advice = WeatherUtils.getWeatherAdvice(
      weatherData.mainCondition,
      weatherData.temperature,
    );

    if (advice.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildAdviceList(advice),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Conseils météo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceList(List<String> advice) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: advice.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildAdviceItem(advice[index], index);
        },
      ),
    );
  }

  Widget _buildAdviceItem(String adviceText, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _getAdviceColor(index).withOpacity(0.2),
            _getAdviceColor(index).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getAdviceColor(index),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAdviceIcon(adviceText),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              adviceText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAdviceColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getAdviceIcon(String advice) {
    final lowerAdvice = advice.toLowerCase();
    
    if (lowerAdvice.contains('parapluie') || lowerAdvice.contains('imperméable')) {
      return Icons.umbrella;
    } else if (lowerAdvice.contains('chaud') || lowerAdvice.contains('gel')) {
      return Icons.ac_unit;
    } else if (lowerAdvice.contains('solaire') || lowerAdvice.contains('soleil')) {
      return Icons.wb_sunny;
    } else if (lowerAdvice.contains('hydrat') || lowerAdvice.contains('eau')) {
      return Icons.local_drink;
    } else if (lowerAdvice.contains('intérieur') || lowerAdvice.contains('évitez')) {
      return Icons.home;
    } else if (lowerAdvice.contains('route') || lowerAdvice.contains('glissant')) {
      return Icons.warning;
    } else if (lowerAdvice.contains('plante')) {
      return Icons.local_florist;
    } else {
      return Icons.info_outline;
    }
  }
}
