import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/weather_data.dart';
import '../models/location_data.dart';
import '../themes/modern_theme.dart';
import '../utils/weather_utils.dart';

/// Widget moderne pour afficher la météo avec effets 3D et animations
class ModernWeatherCard extends StatefulWidget {
  final WeatherData weatherData;
  final LocationData location;
  final VoidCallback? onRefresh;

  const ModernWeatherCard({
    super.key,
    required this.weatherData,
    required this.location,
    this.onRefresh,
  });

  @override
  State<ModernWeatherCard> createState() => _ModernWeatherCardState();
}

class _ModernWeatherCardState extends State<ModernWeatherCard>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Pour l'effet parallax
  double _xOffset = 0;
  double _yOffset = 0;

  @override
  void initState() {
    super.initState();
    
    // Animation de rotation pour l'icône météo
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Animation de pulsation pour la température
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Animation de glissement à l'entrée
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gradient = ModernTheme.getGradientForTimeAndWeather(
      widget.weatherData.dateTime,
      widget.weatherData.mainCondition,
    );
    
    // Calcul dynamique de la hauteur basé sur la taille de l'écran
    final cardHeight = size.height > 700 ? 320.0 : 280.0;
    
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xOffset = (details.localPosition.dx - size.width / 2) / 10;
            _yOffset = (details.localPosition.dy - 200) / 10;
          });
        },
        onPanEnd: (_) {
          setState(() {
            _xOffset = 0;
            _yOffset = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_yOffset * 0.01)
            ..rotateY(_xOffset * 0.01),
          child: Container(
            height: cardHeight,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Stack(
              children: [
                // Fond avec dégradé animé
                _buildAnimatedBackground(gradient),
                
                // Contenu principal
                _buildMainContent(),
                
                // Particules flottantes
                ..._buildFloatingParticles(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(LinearGradient gradient) {
    return Positioned.fill(
      child: GlassContainer(
        borderRadius: 32,
        blur: 20,
        opacity: 0.15,
        gradient: gradient,
        child: Container(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec localisation
          _buildLocationHeader(),
          
          const SizedBox(height: 10),
          
          // Température principale avec animation
          _buildTemperatureSection(),
          
          const Spacer(),
          
          // Détails météo
          _buildWeatherDetails(),
          
          const SizedBox(height: 10),
          
          // Statistiques en bas
          _buildBottomStats(),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.location.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              widget.location.country,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        // Bouton de rafraîchissement moderne
        if (widget.onRefresh != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onRefresh!();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return Center(
      child: Column(
        children: [
          // Icône météo animée
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: widget.weatherData.mainCondition.toLowerCase().contains('sun')
                    ? _rotationAnimation.value
                    : 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      WeatherUtils.getWeatherIcon(widget.weatherData.mainCondition),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 10),
          
          // Température avec animation de pulsation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.weatherData.temperature.round()}',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(
                        text: '°',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Description météo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.weatherData.description.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDetailItem(
          icon: Icons.thermostat_rounded,
          label: 'Ressenti',
          value: '${widget.weatherData.feelsLike.round()}°',
        ),
        const SizedBox(width: 20),
        _buildDetailItem(
          icon: Icons.water_drop_rounded,
          label: 'Humidité',
          value: '${widget.weatherData.humidity}%',
        ),
        const SizedBox(width: 20),
        _buildDetailItem(
          icon: Icons.air_rounded,
          label: 'Vent',
          value: '${widget.weatherData.windSpeed.round()} km/h',
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.arrow_upward_rounded,
            value: '${widget.weatherData.tempMax.round()}°',
            label: 'Max',
            color: Colors.orange,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Icons.arrow_downward_rounded,
            value: '${widget.weatherData.tempMin.round()}°',
            label: 'Min',
            color: Colors.blue,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Icons.compress_rounded,
            value: '${widget.weatherData.pressure}',
            label: 'hPa',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        ),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    final random = math.Random();
    return List.generate(5, (index) {
      return Positioned(
        left: random.nextDouble() * 300 + 50,
        top: random.nextDouble() * 300 + 50,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(seconds: 3 + index),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(value * math.pi * 2) * 20,
                math.cos(value * math.pi * 2) * 20,
              ),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
