import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/weather_animations.dart';
import '../widgets/enhanced_weather_animation.dart';
import '../themes/modern_theme.dart';

/// Écran de démonstration pour présenter les animations météo
class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({super.key});

  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen> {
  String selectedWeather = 'clear';
  double temperature = 25.0;
  bool isDay = true;
  double currentHour = 12.0; // Nouvelle variable pour l'heure
  
  final Map<String, Map<String, dynamic>> weatherPresets = {
    'clear': {
      'icon': '☀️',
      'label': 'Ensoleillé',
      'temp': 28.0,
      'description': 'Ciel dégagé',
      'color': Colors.orange,
    },
    'rain': {
      'icon': '🌧️',
      'label': 'Pluie',
      'temp': 18.0,
      'description': 'Pluie modérée',
      'color': Colors.blue,
    },
    'thunderstorm': {
      'icon': '⛈️',
      'label': 'Orage',
      'temp': 16.0,
      'description': 'Orage avec éclairs',
      'color': Colors.purple,
    },
    'snow': {
      'icon': '❄️',
      'label': 'Neige',
      'temp': -2.0,
      'description': 'Chutes de neige',
      'color': Colors.lightBlue,
    },
    'clouds': {
      'icon': '☁️',
      'label': 'Nuageux',
      'temp': 20.0,
      'description': 'Ciel couvert',
      'color': Colors.grey,
    },
    'mist': {
      'icon': '🌫️',
      'label': 'Brouillard',
      'temp': 15.0,
      'description': 'Brume matinale',
      'color': Colors.blueGrey,
    },
  };

  @override
  Widget build(BuildContext context) {
    // Utiliser l'heure du slider pour tester les dégradés
    final fakeDateTime = DateTime(2024, 1, 1, currentHour.round());
    
    // Déterminer automatiquement si c'est le jour ou la nuit selon l'heure
    isDay = currentHour >= 5 && currentHour < 21;
    
    final gradient = ModernTheme.getGradientForTimeAndWeather(
      fakeDateTime,
      selectedWeather,
    );
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            // Animation météo de fond
            if (selectedWeather.toLowerCase().contains('storm'))
              EnhancedWeatherAnimation(
                weatherCondition: selectedWeather,
                isDay: isDay,
              )
            else
              WeatherAnimation(
                weatherCondition: selectedWeather,
                isDay: isDay,
              ),
            
            // Interface
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                  // Header avec titre
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            '🎭 Mode Démonstration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  
                  // Carte météo actuelle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          weatherPresets[selectedWeather]?['icon'] ?? '☀️',
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${temperature.round()}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weatherPresets[selectedWeather]?['description'] ?? 'Ciel dégagé',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Slider pour la température
                        Row(
                          children: [
                            Icon(Icons.thermostat, color: Colors.white.withOpacity(0.7)),
                            Expanded(
                              child: Slider(
                                value: temperature,
                                min: -10,
                                max: 40,
                                divisions: 50,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withOpacity(0.3),
                                onChanged: (value) {
                                  setState(() {
                                    temperature = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${temperature.round()}°',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Slider pour l'heure de la journée
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🕐 Heure: ${currentHour.round()}h - ${_getTimeDescription(currentHour.round())}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.white.withOpacity(0.7)),
                                Expanded(
                                  child: Slider(
                                    value: currentHour,
                                    min: 0,
                                    max: 23,
                                    divisions: 23,
                                    activeColor: _getSliderColor(currentHour.round()),
                                    inactiveColor: Colors.white.withOpacity(0.3),
                                    onChanged: (value) {
                                      setState(() {
                                        currentHour = value;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${currentHour.round().toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Informations supplémentaires météo
                  Container(
                    height: 110,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weatherPresets.length,
                      itemBuilder: (context, index) {
                        final weather = weatherPresets.keys.elementAt(index);
                        final preset = weatherPresets[weather];
                        if (preset == null) return const SizedBox.shrink();
                        final isSelected = selectedWeather == weather;
                        
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              selectedWeather = weather;
                              temperature = preset['temp'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getGradientColors(),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _getGradientColors().last.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  preset['icon'],
                                  style: TextStyle(
                                    fontSize: isSelected ? 36 : 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  preset['label'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Instructions pour la présentation
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, 
                                 color: Colors.white.withOpacity(0.8), 
                                 size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Mode Présentation',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Cliquez sur les conditions météo pour voir les animations\n'
                          '• Ajustez la température avec le slider\n'
                          '• Utilisez le slider d\'heure pour tester les dégradés\n'
                          '• Observez les changements d\'animation en temps réel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Color> _getGradientColors() {
    // Différencier jour et nuit
    if (!isDay) {
      // NUIT - couleurs sombres
      return [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
    } else {
      // JOUR - couleurs claires  
      return [Color(0xFF56CCF2), Color(0xFF2F80ED)];
    }
  }
  
  String _getTimeDescription(int hour) {
    if (hour >= 5 && hour < 7) {
      return 'Lever du soleil 🌅';
    } else if (hour >= 7 && hour < 10) {
      return 'Matin ☀️';
    } else if (hour >= 10 && hour < 16) {
      return 'Journée 🌞';
    } else if (hour >= 16 && hour < 19) {
      return 'Coucher du soleil 🌇';
    } else if (hour >= 19 && hour < 21) {
      return 'Soirée 🌆';
    } else {
      return 'Nuit 🌙';
    }
  }
  
  Color _getSliderColor(int hour) {
    if (hour >= 5 && hour < 7) {
      return Colors.purple.shade300; // Lever du soleil
    } else if (hour >= 7 && hour < 10) {
      return Colors.amber; // Matin
    } else if (hour >= 10 && hour < 16) {
      return Colors.blue.shade400; // Journée
    } else if (hour >= 16 && hour < 19) {
      return Colors.orange.shade600; // Coucher du soleil
    } else if (hour >= 19 && hour < 21) {
      return Colors.deepPurple; // Soirée
    } else {
      return Colors.indigo.shade900; // Nuit
    }
  }
}
