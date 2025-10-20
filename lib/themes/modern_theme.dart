import 'package:flutter/material.dart';
import 'dart:ui';

/// Thème moderne avec glassmorphism et effets visuels avancés
class ModernTheme {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryOrange = Color(0xFFFF9F43);
  static const Color primaryGreen = Color(0xFF00D2D3);
  
  // Couleurs de fond
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color lightBackground = Color(0xFFF5F7FA);
  
  // Dégradés modernes améliorés
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9C88FF), // Violet
      Color(0xFFFF6B9D), // Rose
      Color(0xFFFFB347), // Orange clair
    ],
  );
  
  static const LinearGradient morningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD89B), // Jaune doré
      Color(0xFFFF9F43), // Orange
      Color(0xFFEE5A6F), // Rose corail
    ],
  );
  
  static const LinearGradient dayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF56CCF2), // Bleu ciel clair
      Color(0xFF2F80ED), // Bleu ciel
      Color(0xFF87CEEB), // Sky blue
    ],
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8E44AD), // Violet profond
      Color(0xFFE74C3C), // Rouge orangé
      Color(0xFFF39C12), // Orange doré
    ],
  );
  
  static const LinearGradient eveningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5D4E6D), // Violet sombre
      Color(0xFF3D2C4E), // Violet très sombre
      Color(0xFF1A1A2E), // Bleu nuit
    ],
  );
  
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2027), // Bleu très sombre
      Color(0xFF203A43), // Bleu gris sombre
      Color(0xFF2C5364), // Bleu acier sombre
    ],
  );
  
  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF536976),
      Color(0xFF292E49),
    ],
  );
  
  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B9DC3), // Bleu gris moyen
      Color(0xFF7A8B9C), // Gris bleuté moyen
      Color(0xFF697A8B), // Gris ardoise
    ],
  );
  
  static const LinearGradient snowyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6DADA),
      Color(0xFF274046),
    ],
  );
  
  // Obtenir le dégradé selon l'heure et la météo
  static LinearGradient getGradientForTimeAndWeather(DateTime time, String? weatherCondition) {
    final hour = time.hour;
    
    // Conditions météo spéciales (priorité sur l'heure pour certains cas)
    if (weatherCondition != null) {
      final condition = weatherCondition.toLowerCase();
      
      // Pour la pluie et la neige, on garde les dégradés spéciaux
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return rainyGradient;
      } else if (condition.contains('snow')) {
        return snowyGradient;
      } else if (condition.contains('cloud')) {
        // Nuageux : adapter selon l'heure de la journée
        if (hour >= 5 && hour < 7) {
          // Nuageux au lever du soleil
          return getCloudySunriseGradient();
        } else if (hour >= 16 && hour < 19) {
          // Nuageux au coucher du soleil
          return getCloudySunsetGradient();
        } else if (hour >= 10 && hour < 16) {
          // Nuageux en journée
          return getCloudyDayGradient();
        } else if (hour >= 21 || hour < 5) {
          // Nuageux la nuit
          return getCloudyNightGradient();
        } else {
          // Autres heures nuageuses
          return cloudyGradient;
        }
      }
    }
    
    // Selon l'heure avec des transitions plus précises
    if (hour >= 5 && hour < 7) {
      // Lever du soleil (5h-7h)
      return sunriseGradient;
    } else if (hour >= 7 && hour < 10) {
      // Matin (7h-10h)
      return morningGradient;
    } else if (hour >= 10 && hour < 16) {
      // Journée (10h-16h)
      return dayGradient;
    } else if (hour >= 16 && hour < 19) {
      // Coucher du soleil (16h-19h)
      return sunsetGradient;
    } else if (hour >= 19 && hour < 21) {
      // Soirée (19h-21h)
      return eveningGradient;
    } else {
      // Nuit (21h-5h)
      return nightGradient;
    }
  }
  
  // Nouvelle méthode pour obtenir un dégradé spécifique pour les pages
  static LinearGradient getSunsetPurpleGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7F7FD5), // Violet clair
        Color(0xFF86A8E7), // Bleu lavande
        Color(0xFF91EAE4), // Cyan clair
      ],
    );
  }
  
  // Dégradé violet/rose comme dans l'exemple de Jeddah
  static LinearGradient getPurplePinkGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF9C88FF), // Violet
        Color(0xFFB084CC), // Violet rosé
        Color(0xFFFF6B9D), // Rose
      ],
    );
  }
  
  // Dégradés nuageux adaptés selon l'heure
  static LinearGradient getCloudySunriseGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8B7AA8), // Violet grisé
        Color(0xFFA8A8A8), // Gris
        Color(0xFFD4A574), // Beige rosé
      ],
    );
  }
  
  static LinearGradient getCloudySunsetGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7F6B8F), // Violet sombre
        Color(0xFF9B8B7A), // Brun grisé
        Color(0xFFB08D57), // Orange terne
      ],
    );
  }
  
  static LinearGradient getCloudyDayGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7B8FA6), // Bleu gris plus foncé
        Color(0xFF6B7C8B), // Gris bleuté foncé
        Color(0xFF5A6978), // Gris ardoise moyen
      ],
    );
  }
  
  static LinearGradient getCloudyNightGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2C3E50), // Bleu gris sombre
        Color(0xFF34495E), // Gris ardoise
        Color(0xFF1C2833), // Presque noir
      ],
    );
  }
  
  // Thème Material moderne
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryPurple,
        tertiary: primaryPink,
        surface: Color(0xFFF5F7FA),
        background: lightBackground,
        onSurface: Color(0xFF2C3E50),
        onBackground: Color(0xFF2C3E50),
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
  
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryPurple,
        tertiary: primaryPink,
        surface: Color(0xFF1A1F3A),
        background: darkBackground,
        onSurface: Color(0xFFE4E7EB),
        onBackground: Color(0xFFE4E7EB),
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Widget pour créer un effet glassmorphism
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final double opacity;
  final Border? border;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.color,
    this.opacity = 0.1,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: color ?? Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Widget pour créer un bouton moderne avec effet néomorphisme
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;
  final bool isLoading;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    buttonColor,
                    buttonColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isPressed ? [] : [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
}
