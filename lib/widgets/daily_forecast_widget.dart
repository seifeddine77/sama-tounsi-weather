import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/forecast_data.dart';
import '../themes/modern_theme.dart';

class DailyForecastWidget extends StatefulWidget {
  final List<DailyForecast> dailyForecast;
  final Function(int)? onDaySelected;

  const DailyForecastWidget({
    super.key,
    required this.dailyForecast,
    this.onDaySelected,
  });

  @override
  State<DailyForecastWidget> createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prévisions 7 jours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.dailyForecast.asMap().entries.map((entry) {
            return _buildDayForecastFixed(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDayForecastFixed(int index, DailyForecast forecast) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    
    final isToday = forecast.date.day == DateTime.now().day &&
        forecast.date.month == DateTime.now().month;
    final isTomorrow = forecast.date.day == DateTime.now().add(const Duration(days: 1)).day &&
        forecast.date.month == DateTime.now().add(const Duration(days: 1)).month;
    final isSelected = selectedIndex == index;
    
    String dayName;
    if (isToday) {
      dayName = isVerySmallScreen ? 'Auj.' : 'Aujourd\'hui';
    } else if (isTomorrow) {
      dayName = isVerySmallScreen ? 'Dem.' : 'Demain';
    } else {
      dayName = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'][forecast.date.weekday % 7];
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedIndex = isSelected ? null : index;
        });
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(index);
        }
      },
      child: Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Jour
            SizedBox(
              width: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isToday || isTomorrow)
                    Text(
                      '${forecast.date.day} ${_getMonthName(forecast.date.month)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            
            // Icône météo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(forecast.mainCondition),
                color: Colors.white,
                size: 18,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Températures
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${forecast.minTemp.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${forecast.maxTemp.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Pluie dans une colonne séparée avec largeur fixe
            SizedBox(
              width: 50,
              child: forecast.pop > 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.cyan.shade400.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${(forecast.pop * 100).round()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayForecast(int index, DailyForecast forecast, bool isSmallScreen, bool isVerySmallScreen) {
    final isToday = forecast.date.day == DateTime.now().day;
    final isTomorrow = forecast.date.day == DateTime.now().add(const Duration(days: 1)).day;
    final isSelected = selectedIndex == index;
    
    String dayName;
    if (isToday) {
      dayName = 'Aujourd\'hui';
    } else if (isTomorrow) {
      dayName = 'Demain';
    } else {
      // Utiliser les noms de jours en français manuellement
      final weekday = forecast.date.weekday;
      const frenchDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      dayName = frenchDays[weekday - 1];
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedIndex = isSelected ? null : index;
        });
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 65,
        margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6
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
        child: Row(
          children: [
            // Jour
            SizedBox(
              width: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerySmallScreen && (dayName == 'Aujourd\'hui' || dayName == 'Demain') 
                      ? (dayName == 'Aujourd\'hui' ? 'Auj.' : 'Dem.') 
                      : dayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isToday || isTomorrow)
                    Text(
                      '${forecast.date.day} ${_getMonthName(forecast.date.month)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          
            // Icône météo avec pluie
            SizedBox(
              width: 45,
              height: 45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getWeatherIcon(forecast.mainCondition),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  Container(
                    height: 10,
                    child: forecast.pop > 0
                      ? Text(
                          '${(forecast.pop * 100).round()}%',
                          style: TextStyle(
                            color: Colors.cyan.shade300,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  ),
                ],
              ),
            ),
          
            SizedBox(width: 6),
            
            // Températures min/max avec badges
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Température minimale
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 8 : 10, 
                      vertical: isVerySmallScreen ? 4 : 5
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${forecast.minTemp.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 4 : 6),
                  // Température maximale
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 8 : 10, 
                      vertical: isVerySmallScreen ? 4 : 5
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${forecast.maxTemp.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayForecastHorizontal(int index, DailyForecast forecast) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    
    final isToday = forecast.date.day == DateTime.now().day &&
        forecast.date.month == DateTime.now().month;
    final isTomorrow = forecast.date.day == DateTime.now().add(const Duration(days: 1)).day &&
        forecast.date.month == DateTime.now().add(const Duration(days: 1)).month;
    final isSelected = selectedIndex == index;
    
    String dayName;
    if (isToday) {
      dayName = 'Auj.';
    } else if (isTomorrow) {
      dayName = 'Dem.';
    } else {
      dayName = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'][forecast.date.weekday % 7];
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedIndex = isSelected ? null : index;
        });
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        margin: EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jour
            Text(
              dayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            Text(
              '${forecast.date.day}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            
            // Icône météo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(forecast.mainCondition),
                color: Colors.white,
                size: 18,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Température max
            Text(
              '${forecast.maxTemp.round()}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Température min
            Text(
              '${forecast.minTemp.round()}°',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
            
            // Probabilité de pluie
            if (forecast.pop > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.cyan.shade300,
                    size: 9,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${(forecast.pop * 100).round()}%',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
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
