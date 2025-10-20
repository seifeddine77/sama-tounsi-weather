import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/// Widget principal pour les animations météo
class WeatherAnimation extends StatefulWidget {
  final String weatherCondition;
  final bool isDay;
  
  const WeatherAnimation({
    super.key,
    required this.weatherCondition,
    this.isDay = true,
  });

  @override
  State<WeatherAnimation> createState() => _WeatherAnimationState();
}

class _WeatherAnimationState extends State<WeatherAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _windController;
  late List<Particle> particles;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _windController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    _initializeParticles();
  }
  
  void _initializeParticles() {
    final random = math.Random();
    particles = [];
    
    switch (widget.weatherCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        // Gouttes de pluie
        particles = List.generate(100, (index) {
          return RainParticle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            speed: 0.5 + random.nextDouble() * 0.5,
            size: 2 + random.nextDouble() * 3,
          );
        });
        break;
        
      case 'snow':
        // Flocons de neige
        particles = List.generate(60, (index) {
          return SnowParticle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            speed: 0.1 + random.nextDouble() * 0.2,
            size: 3 + random.nextDouble() * 5,
            wobble: random.nextDouble() * 2 - 1,
          );
        });
        break;
        
      case 'thunderstorm':
        // Pluie intense avec éclairs
        particles = List.generate(150, (index) {
          return RainParticle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            speed: 0.8 + random.nextDouble() * 0.4,
            size: 3 + random.nextDouble() * 4,
            isHeavy: true,
          );
        });
        break;
        
      case 'clear':
        if (widget.isDay) {
          // Rayons de soleil
          particles = List.generate(8, (index) {
            return SunRay(
              angle: (index * 45.0),
              length: 100 + random.nextDouble() * 50,
              width: 2 + random.nextDouble() * 3,
            );
          });
        } else {
          // Étoiles la nuit
          particles = List.generate(50, (index) {
            return Star(
              x: random.nextDouble(),
              y: random.nextDouble() * 0.5,
              size: 1 + random.nextDouble() * 2,
              twinkleSpeed: 0.5 + random.nextDouble(),
            );
          });
        }
        break;
        
      case 'clouds':
        // Nuages flottants
        particles = List.generate(5, (index) {
          return Cloud(
            x: random.nextDouble() * 1.5 - 0.25,
            y: random.nextDouble() * 0.3,
            speed: 0.02 + random.nextDouble() * 0.03,
            size: 80 + random.nextDouble() * 40,
          );
        });
        break;
        
      case 'mist':
      case 'fog':
        // Brouillard
        particles = List.generate(3, (index) {
          return FogLayer(
            y: index * 0.3,
            speed: 0.01 + random.nextDouble() * 0.02,
            opacity: 0.3 + random.nextDouble() * 0.2,
          );
        });
        break;
        
      default:
        particles = [];
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _windController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: WeatherPainter(
            animation: _animationController.value,
            windAnimation: _windController.value,
            particles: particles,
            weatherCondition: widget.weatherCondition,
            isDay: widget.isDay,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// Painter pour dessiner les animations météo
class WeatherPainter extends CustomPainter {
  final double animation;
  final double windAnimation;
  final List<Particle> particles;
  final String weatherCondition;
  final bool isDay;
  
  WeatherPainter({
    required this.animation,
    required this.windAnimation,
    required this.particles,
    required this.weatherCondition,
    required this.isDay,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    switch (weatherCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        _drawRain(canvas, size);
        break;
      case 'snow':
        _drawSnow(canvas, size);
        break;
      case 'thunderstorm':
        _drawThunderstorm(canvas, size);
        break;
      case 'clear':
        if (isDay) {
          _drawSun(canvas, size);
        } else {
          _drawStars(canvas, size);
        }
        break;
      case 'clouds':
        _drawClouds(canvas, size);
        break;
      case 'mist':
      case 'fog':
        _drawFog(canvas, size);
        break;
    }
  }
  
  void _drawRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    for (final particle in particles) {
      if (particle is RainParticle) {
        final x = particle.x * size.width;
        final y = ((particle.y + animation * particle.speed) % 1.2) * size.height;
        
        // Effet de vent
        final windOffset = math.sin(windAnimation * 2 * math.pi) * 10;
        
        paint.color = Colors.white.withOpacity(0.6);
        paint.strokeWidth = particle.size / 2;
        
        canvas.drawLine(
          Offset(x + windOffset, y),
          Offset(x + windOffset - 5, y + particle.size * 3),
          paint,
        );
      }
    }
  }
  
  void _drawSnow(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      if (particle is SnowParticle) {
        final wobbleX = math.sin(animation * 2 * math.pi + particle.wobble) * 20;
        final x = particle.x * size.width + wobbleX;
        final y = ((particle.y + animation * particle.speed) % 1.1) * size.height;
        
        // Dessiner un flocon de neige
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(animation * 2 * math.pi * particle.wobble);
        
        // Flocon en forme d'étoile
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          final innerRadius = particle.size * 0.4;
          final outerRadius = particle.size;
          
          if (i == 0) {
            path.moveTo(
              math.cos(angle) * outerRadius,
              math.sin(angle) * outerRadius,
            );
          }
          
          path.lineTo(
            math.cos(angle) * outerRadius,
            math.sin(angle) * outerRadius,
          );
          path.lineTo(
            math.cos(angle + math.pi / 6) * innerRadius,
            math.sin(angle + math.pi / 6) * innerRadius,
          );
        }
        path.close();
        
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
  }
  
  void _drawThunderstorm(Canvas canvas, Size size) {
    // Pluie intense
    _drawRain(canvas, size);
    
    // Éclairs occasionnels
    if (animation > 0.95) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      final startX = size.width * 0.3 + math.Random().nextDouble() * size.width * 0.4;
      path.moveTo(startX, 0);
      
      double currentX = startX;
      double currentY = 0;
      
      while (currentY < size.height * 0.6) {
        currentY += 20 + math.Random().nextDouble() * 30;
        currentX += (math.Random().nextDouble() - 0.5) * 40;
        path.lineTo(currentX, currentY);
      }
      
      // Effet de lueur
      canvas.drawPath(
        path,
        paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawPath(path, paint..maskFilter = null);
    }
  }
  
  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.15);
    
    // Halo lumineux
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.3),
          Colors.orange.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 80));
    
    canvas.drawCircle(center, 80, haloPaint);
    
    // Soleil principal
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow,
          Colors.orange,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 30));
    
    canvas.drawCircle(center, 30, sunPaint);
    
    // Rayons animés
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (final particle in particles) {
      if (particle is SunRay) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate((particle.angle + animation * 30) * math.pi / 180);
        
        final gradient = LinearGradient(
          colors: [
            Colors.yellow,
            Colors.yellow.withOpacity(0),
          ],
        );
        
        rayPaint.shader = gradient.createShader(
          Rect.fromPoints(const Offset(35, 0), Offset(35 + particle.length, 0)),
        );
        
        canvas.drawLine(
          const Offset(35, 0),
          Offset(35 + particle.length * (0.8 + 0.2 * math.sin(animation * 2 * math.pi)), 0),
          rayPaint,
        );
        
        canvas.restore();
      }
    }
  }
  
  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      if (particle is Star) {
        final opacity = 0.5 + 0.5 * math.sin(animation * particle.twinkleSpeed * 2 * math.pi);
        paint.color = Colors.white.withOpacity(opacity);
        
        final x = particle.x * size.width;
        final y = particle.y * size.height;
        
        // Étoile à 4 branches
        canvas.save();
        canvas.translate(x, y);
        
        final path = Path();
        for (int i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          if (i == 0) {
            path.moveTo(
              math.cos(angle) * particle.size,
              math.sin(angle) * particle.size,
            );
          } else {
            path.lineTo(
              math.cos(angle) * particle.size,
              math.sin(angle) * particle.size,
            );
          }
          path.lineTo(
            math.cos(angle + math.pi / 4) * particle.size * 0.3,
            math.sin(angle + math.pi / 4) * particle.size * 0.3,
          );
        }
        path.close();
        
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
    
    // Lune
    final moonCenter = Offset(size.width * 0.85, size.height * 0.15);
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.grey.shade300,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 25));
    
    canvas.drawCircle(moonCenter, 25, moonPaint);
  }
  
  void _drawClouds(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle is Cloud) {
        final x = ((particle.x + animation * particle.speed) % 1.5) * size.width - size.width * 0.25;
        final y = particle.y * size.height;
        
        final paint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        
        // Dessiner plusieurs cercles pour former un nuage
        canvas.drawCircle(Offset(x, y), particle.size * 0.8, paint);
        canvas.drawCircle(Offset(x + particle.size * 0.5, y - particle.size * 0.2), particle.size * 0.6, paint);
        canvas.drawCircle(Offset(x - particle.size * 0.5, y - particle.size * 0.1), particle.size * 0.7, paint);
        canvas.drawCircle(Offset(x + particle.size * 0.3, y + particle.size * 0.2), particle.size * 0.5, paint);
      }
    }
  }
  
  void _drawFog(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle is FogLayer) {
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(particle.opacity),
              Colors.white.withOpacity(particle.opacity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));
        
        final y = particle.y * size.height;
        final offsetX = math.sin(animation * 2 * math.pi) * 50;
        
        final path = Path();
        path.moveTo(-50 + offsetX, y);
        
        for (double x = 0; x <= size.width + 100; x += 20) {
          final waveY = y + math.sin((x / 100) + animation * 2 * math.pi) * 20;
          path.lineTo(x + offsetX, waveY);
        }
        
        path.lineTo(size.width + 50 + offsetX, size.height);
        path.lineTo(-50 + offsetX, size.height);
        path.close();
        
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(WeatherPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Classes de particules
abstract class Particle {}

class RainParticle extends Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final bool isHeavy;
  
  RainParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    this.isHeavy = false,
  });
}

class SnowParticle extends Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double wobble;
  
  SnowParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.wobble,
  });
}

class SunRay extends Particle {
  final double angle;
  final double length;
  final double width;
  
  SunRay({
    required this.angle,
    required this.length,
    required this.width,
  });
}

class Star extends Particle {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
  });
}

class Cloud extends Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  
  Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

class FogLayer extends Particle {
  final double y;
  final double speed;
  final double opacity;
  
  FogLayer({
    required this.y,
    required this.speed,
    required this.opacity,
  });
}
