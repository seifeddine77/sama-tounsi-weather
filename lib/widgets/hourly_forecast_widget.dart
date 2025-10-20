import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HourlyForecastWidget extends StatefulWidget {
  final List<dynamic> hourlyForecast;
  final Function(int)? onItemSelected;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyForecast,
    this.onItemSelected,
  });

  @override
  State<HourlyForecastWidget> createState() => _HourlyForecastWidgetState();
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.hourlyForecast.take(24).length,
        itemBuilder: (context, index) {
          final forecast = widget.hourlyForecast[index];
          final isSelected = selectedIndex == index;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                selectedIndex = isSelected ? null : index;
              });
              if (widget.onItemSelected != null) {
                widget.onItemSelected!(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 85,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == widget.hourlyForecast.length - 1 ? 0 : 0,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      )
                    : null,
                color: !isSelected ? Colors.white.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white.withOpacity(0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Heure
                    Text(
                      _formatHour(forecast.dateTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    
                    // Icône météo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getWeatherIcon(forecast.mainCondition),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    
                    // Température
                    Text(
                      '${forecast.temperature.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Probabilité de pluie si applicable
                    if (forecast.pop > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue.shade300,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${(forecast.pop * 100).round()}%',
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatHour(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.hour == now.hour && dateTime.day == now.day) {
      return 'Maint.';
    }
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  IconData _getWeatherIcon(String condition) {
    final lowerCondition = condition.toLowerCase();
    
    if (lowerCondition.contains('clear')) return Icons.wb_sunny;
    if (lowerCondition.contains('cloud')) return Icons.cloud;
    if (lowerCondition.contains('rain')) return Icons.water_drop;
    if (lowerCondition.contains('drizzle')) return Icons.grain;
    if (lowerCondition.contains('thunderstorm')) return Icons.flash_on;
    if (lowerCondition.contains('snow')) return Icons.ac_unit;
    if (lowerCondition.contains('mist') || lowerCondition.contains('fog')) return Icons.blur_on;
    
    return Icons.wb_cloudy;
  }
}
