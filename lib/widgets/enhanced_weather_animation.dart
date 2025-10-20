import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class EnhancedWeatherAnimation extends StatefulWidget {
  final String weatherCondition;
  final bool isDay;
  
  const EnhancedWeatherAnimation({
    super.key,
    required this.weatherCondition,
    this.isDay = true,
  });

  @override
  State<EnhancedWeatherAnimation> createState() => _EnhancedWeatherAnimationState();
}

class _EnhancedWeatherAnimationState extends State<EnhancedWeatherAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _lightningTimer;
  bool _showLightning = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    if (widget.weatherCondition.toLowerCase().contains('storm')) {
      _startLightningEffect();
    }
  }
  
  void _startLightningEffect() {
    _lightningTimer = Timer.periodic(
      Duration(seconds: 2 + math.Random().nextInt(3)),
      (timer) {
        if (mounted) {
          setState(() => _showLightning = true);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) setState(() => _showLightning = false);
          });
        }
      },
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _lightningTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: StormPainter(
                animation: _animationController.value,
                showLightning: _showLightning,
              ),
              child: Container(),
            );
          },
        ),
        if (_showLightning)
          Container(
            color: Colors.white.withOpacity(0.2),
          ),
      ],
    );
  }
}

class StormPainter extends CustomPainter {
  final double animation;
  final bool showLightning;
  
  StormPainter({
    required this.animation,
    required this.showLightning,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Pluie intense
    final rainPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final random = math.Random(42);
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() + animation) % 1.0 * size.height;
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 7, y + 25),
        rainPaint,
      );
    }
    
    // Éclairs
    if (showLightning) {
      final lightningPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      final startX = size.width * 0.5;
      path.moveTo(startX, 0);
      path.lineTo(startX - 30, 150);
      path.lineTo(startX + 20, 150);
      path.lineTo(startX - 10, 300);
      
      canvas.drawPath(path, lightningPaint);
    }
  }
  
  @override
  bool shouldRepaint(StormPainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.showLightning != showLightning;
  }
}
