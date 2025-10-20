import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/weather_viewmodel.dart';
import '../models/weather_data.dart';
import '../widgets/simple_weather_card.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/forecast_chart_widget.dart';
import '../widgets/weather_animations.dart';
import '../themes/modern_theme.dart';
import 'demo_mode_screen.dart';
import 'weather_map_screen.dart';
import '../widgets/enhanced_weather_animation.dart';
import '../widgets/modern_favorites_page.dart';
import 'modern_search_page.dart';
/// Écran d'accueil moderne avec design glassmorphism et animations
class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    
    // Animation pour le FAB
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _fabController.forward();
    
    // Initialiser les données météo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          // Utiliser l'heure locale de la ville si disponible
          final localTime = viewModel.currentWeather?.getLocalTime() ?? DateTime.now();
          final gradient = viewModel.hasData
              ? ModernTheme.getGradientForTimeAndWeather(
                  localTime,
                  viewModel.currentWeather?.mainCondition,
                )
              : ModernTheme.dayGradient;
          
          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Stack(
              children: [
                // Animation météo principale
                _buildBackgroundParticles(),
                
                // Contenu principal
                _buildMainContent(viewModel),
                
                // AppBar moderne flottante
                _buildModernAppBar(context, viewModel),
                
                // Bottom Navigation Bar moderne
                _buildModernBottomNav(),
                
                // FAB moderne
                _buildModernFAB(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.hasData && viewModel.currentWeather != null) {
          // Utiliser l'heure locale de la ville
          final localTime = viewModel.currentWeather!.getLocalTime();
          final hour = localTime.hour;
          final isDay = hour >= 6 && hour < 20; // Jour de 6h à 20h
          final condition = viewModel.currentWeather!.mainCondition.toLowerCase();
          
          // Utiliser l'animation améliorée pour l'orage
          if (condition.contains('storm') || condition.contains('thunder')) {
            return EnhancedWeatherAnimation(
              weatherCondition: viewModel.currentWeather!.mainCondition,
              isDay: isDay,
            );
          }
          
          return WeatherAnimation(
            weatherCondition: viewModel.currentWeather!.mainCondition,
            isDay: isDay,
          );
        }
        return Container();
      },
    );
  }

  Widget _buildMainContent(WeatherViewModel viewModel) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      children: [
        _buildHomePage(viewModel),
        _buildForecastPage(viewModel),
        _buildMapPage(viewModel),
        _buildSettingsPage(viewModel),
      ],
    );
  }

  Widget _buildHomePage(WeatherViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return _buildLoadingState();
    }

    if (viewModel.error != null && !viewModel.hasData) {
      return _buildErrorState(viewModel);
    }

    if (!viewModel.hasData) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 700;
        
        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await viewModel.refresh();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: isSmallScreen ? 80 : 100,
              bottom: isSmallScreen ? 80 : 100,
            ),
            child: Column(
              children: [
                // Carte météo moderne
                SimpleWeatherCard(
                  weatherData: viewModel.currentWeather!,
                  location: viewModel.currentLocation!,
                  onRefresh: () => viewModel.refresh(),
                ),
                
                // Prévisions horaires avec le nouveau design
                if (viewModel.hourlyForecast.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      borderRadius: 24,
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Prévisions horaires',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          HourlyForecastWidget(
                            hourlyForecast: viewModel.hourlyForecast,
                            onItemSelected: (index) {
                              // Vous pouvez ajouter une action ici lors de la sélection
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Prévisions sur 7 jours sur la page d'accueil
                if (viewModel.dailyForecast.isNotEmpty)
                  DailyForecastWidget(
                    dailyForecast: viewModel.dailyForecast,
                    onDaySelected: (index) {
                      // Vous pouvez ajouter une action ici lors de la sélection
                      HapticFeedback.lightImpact();
                    },
                  ),
                
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Conseils météo modernes
                if (viewModel.hasWeatherData)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildWeatherTips(viewModel),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildWeatherTips(WeatherViewModel viewModel) {
    final tips = _getWeatherTips(viewModel.currentWeather!);
    
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Conseils du jour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getWeatherTips(dynamic weather) {
    final temp = weather.temperature;
    final condition = weather.mainCondition.toLowerCase();
    List<String> tips = [];
    
    if (temp > 30) {
      tips.add('Restez hydraté et évitez l\'exposition directe au soleil');
    } else if (temp < 10) {
      tips.add('Habillez-vous chaudement');
    }
    
    if (condition.contains('rain')) {
      tips.add('N\'oubliez pas votre parapluie');
    }
    
    if (weather.windSpeed > 20) {
      tips.add('Vent fort prévu, soyez prudent');
    }
    
    if (weather.humidity > 80) {
      tips.add('Humidité élevée, la température ressentie peut être différente');
    }
    
    if (tips.isEmpty) {
      tips.add('Journée agréable en perspective !');
    }
    
    return tips;
  }

  Widget _buildForecastPage(WeatherViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.hasForecast) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chargement des prévisions...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (!viewModel.hasForecast || viewModel.dailyForecast.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune prévision disponible',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion internet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await viewModel.refresh();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 120,
          bottom: 100,
          left: 12,
          right: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la page
            GlassContainer(
              borderRadius: 24,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prévisions détaillées',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${viewModel.currentLocation?.cityName ?? ""}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Résumé de la semaine
            GlassContainer(
              borderRadius: 24,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.summarize_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Résumé de la semaine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildWeekSummary(viewModel),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Supprimé - Duplication avec le graphique qui contient déjà les prévisions
            // Les prévisions sont déjà affichées dans le ForecastChartWidget ci-dessous
            
            // Graphique des températures
            if (viewModel.dailyForecast.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ForecastChartWidget(
                  dailyForecasts: viewModel.dailyForecast,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Statistiques supplémentaires
            if (viewModel.dailyForecast.isNotEmpty)
              GlassContainer(
                borderRadius: 24,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Statistiques détaillées',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsGridNew(viewModel),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Tendances météo
            if (viewModel.dailyForecast.isNotEmpty)
              GlassContainer(
                borderRadius: 24,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tendances',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeatherTrends(viewModel),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Informations météo détaillées
            if (viewModel.hasWeatherData)
              GlassContainer(
                borderRadius: 24,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Informations détaillées',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeatherDetails(viewModel.currentWeather!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticsGridNew(WeatherViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    final stats = _calculateStatistics(viewModel.dailyForecast);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.only(right: 4, bottom: 8),
                child: _buildStatItem(
                  icon: Icons.thermostat,
                  label: 'Moy.',
                  value: '${stats['avgTemp']}°',
                  color: Colors.orange,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.only(left: 4, bottom: 8),
                child: _buildStatItem(
                  icon: Icons.water_drop,
                  label: 'Pluie',
                  value: '${stats['totalRain']}%',
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.only(right: 4),
                child: _buildStatItem(
                  icon: Icons.arrow_upward,
                  label: 'Max',
                  value: '${stats['maxTemp']}°',
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.only(left: 4),
                child: _buildStatItem(
                  icon: Icons.arrow_downward,
                  label: 'Min',
                  value: '${stats['minTemp']}°',
                  color: Colors.cyan,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, int> _calculateStatistics(List<dynamic> dailyForecast) {
    if (dailyForecast.isEmpty) {
      return {
        'avgTemp': 0,
        'maxTemp': 0,
        'minTemp': 0,
        'totalRain': 0,
      };
    }
    
    double totalTemp = 0;
    double maxTemp = -999;
    double minTemp = 999;
    double totalRain = 0;
    
    for (var forecast in dailyForecast) {
      final avgTemp = (forecast.maxTemp + forecast.minTemp) / 2;
      totalTemp += avgTemp;
      
      if (forecast.maxTemp > maxTemp) {
        maxTemp = forecast.maxTemp;
      }
      
      if (forecast.minTemp < minTemp) {
        minTemp = forecast.minTemp;
      }
      
      totalRain += forecast.pop * 100;
    }
    
    return {
      'avgTemp': (totalTemp / dailyForecast.length).round(),
      'maxTemp': maxTemp.round(),
      'minTemp': minTemp.round(),
      'totalRain': (totalRain / dailyForecast.length).round(),
    };
  }

  Widget _buildWeekSummary(WeatherViewModel viewModel) {
    final forecasts = viewModel.dailyForecast;
    if (forecasts.isEmpty) return const SizedBox.shrink();
    
    // Analyser les conditions météo de la semaine
    int sunnyDays = 0;
    int rainyDays = 0;
    double avgTemp = 0;
    
    for (var forecast in forecasts.take(7)) {
      final condition = forecast.mainCondition.toLowerCase();
      if (condition.contains('clear')) sunnyDays++;
      else if (condition.contains('rain') || condition.contains('drizzle')) rainyDays++;
      
      avgTemp += (forecast.maxTemp + forecast.minTemp) / 2;
    }
    
    avgTemp = avgTemp / forecasts.take(7).length;
    
    // Déterminer le meilleur jour
    var bestDay = forecasts.first;
    for (var forecast in forecasts.take(7)) {
      if (forecast.maxTemp > bestDay.maxTemp && forecast.pop < 0.3) {
        bestDay = forecast;
      }
    }
    
    final bestDayName = _getDayName(bestDay.date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vue d'ensemble
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette semaine sera ${avgTemp > 25 ? "chaude" : avgTemp > 15 ? "agréable" : "fraîche"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (sunnyDays > 0) ...[
                    Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$sunnyDays jour${sunnyDays > 1 ? "s" : ""} ensoleillé${sunnyDays > 1 ? "s" : ""}',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (rainyDays > 0) ...[
                    Icon(Icons.water_drop, color: Colors.blue.shade300, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$rainyDays jour${rainyDays > 1 ? "s" : ""} pluvieux',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🌟 Meilleur jour : $bestDayName (${bestDay.maxTemp.round()}°)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeatherTrends(WeatherViewModel viewModel) {
    final forecasts = viewModel.dailyForecast;
    if (forecasts.length < 2) return const SizedBox.shrink();
    
    // Analyser les tendances
    bool tempIncreasing = true;
    bool tempDecreasing = true;
    
    for (int i = 1; i < forecasts.take(7).length; i++) {
      final prevTemp = (forecasts[i-1].maxTemp + forecasts[i-1].minTemp) / 2;
      final currTemp = (forecasts[i].maxTemp + forecasts[i].minTemp) / 2;
      
      if (currTemp <= prevTemp) tempIncreasing = false;
      if (currTemp >= prevTemp) tempDecreasing = false;
    }
    
    String tempTrend = tempIncreasing ? "hausse" : tempDecreasing ? "baisse" : "stable";
    IconData trendIcon = tempIncreasing ? Icons.trending_up : tempDecreasing ? Icons.trending_down : Icons.trending_flat;
    Color trendColor = tempIncreasing ? Colors.orange : tempDecreasing ? Colors.blue : Colors.grey;
    
    // Identifier les périodes
    List<String> recommendations = [];
    
    for (int i = 0; i < forecasts.take(7).length; i++) {
      final forecast = forecasts[i];
      final dayName = _getDayName(forecast.date);
      
      if (forecast.pop < 0.2 && forecast.maxTemp > 20 && forecast.maxTemp < 30) {
        recommendations.add('$dayName : Parfait pour les activités extérieures');
        break;
      }
    }
    
    if (recommendations.isEmpty) {
      for (int i = 0; i < forecasts.take(7).length; i++) {
        final forecast = forecasts[i];
        if (forecast.pop > 0.5) {
          final dayName = _getDayName(forecast.date);
          recommendations.add('$dayName : Prévoyez un parapluie');
          break;
        }
      }
    }
    
    return Column(
      children: [
        // Tendance principale
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: trendColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: trendColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Températures en $tempTrend',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tempIncreasing)
                      Text(
                        'Préparez-vous à des journées plus chaudes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      )
                    else if (tempDecreasing)
                      Text(
                        'Les températures vont se rafraîchir',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      )
                    else
                      Text(
                        'Conditions météo stables cette semaine',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Recommandations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Colors.amber.shade300,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ],
    );
  }
  
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) return "Aujourd'hui";
    if (dateOnly == tomorrow) return "Demain";
    
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }
  
  Widget _buildWeatherDetails(WeatherData weather) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: isSmallScreen ? 6 : 12,
      crossAxisSpacing: isSmallScreen ? 6 : 12,
      children: [
        // UV Index
        _buildDetailCard(
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.amber,
          title: 'INDICE UV',
          value: '${weather.uvIndex}',
          subtitle: _getUVDescription(weather.uvIndex.toDouble()),
          description: weather.uvIndex > 5 ? 'Protection recommandée' : '',
          gradient: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
        ),
        
        // Sunset/Sunrise
        _buildDetailCard(
          icon: Icons.wb_twilight,
          iconColor: Colors.orange.shade300,
          title: 'COUCHER DU SOLEIL',
          value: '${weather.sunset.hour.toString().padLeft(2, '0')}:${weather.sunset.minute.toString().padLeft(2, '0')}',
          subtitle: '',
          description: 'Lever: ${weather.sunrise.hour.toString().padLeft(2, '0')}:${weather.sunrise.minute.toString().padLeft(2, '0')}',
          gradient: [Colors.orange.withOpacity(0.2), Colors.purple.withOpacity(0.1)],
        ),
        
        // Wind
        _buildDetailCard(
          icon: Icons.air,
          iconColor: Colors.blue.shade300,
          title: 'VENT',
          value: '${weather.windSpeed.round()}',
          subtitle: 'km/h',
          description: 'Direction: Variable',
          gradient: [Colors.blue.withOpacity(0.2), Colors.cyan.withOpacity(0.1)],
          hasCompass: false,
          windDegree: 0,
        ),
        
        // Precipitation
        _buildDetailCard(
          icon: Icons.water_drop_outlined,
          iconColor: Colors.cyan,
          title: 'PRÉCIPITATIONS',
          value: '0',
          subtitle: 'mm',
          description: 'Aucune pluie prévue',
          gradient: [Colors.cyan.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
        ),
        
        // Feels Like
        _buildDetailCard(
          icon: Icons.thermostat_outlined,
          iconColor: Colors.green,
          title: 'RESSENTI',
          value: '${weather.feelsLike.round()}°',
          subtitle: '',
          description: weather.feelsLike.round() == weather.temperature.round() 
              ? 'Température réelle'
              : weather.feelsLike > weather.temperature 
                  ? 'Plus chaud'
                  : 'Plus frais',
          gradient: [Colors.green.withOpacity(0.2), Colors.teal.withOpacity(0.1)],
        ),
        
        // Humidity
        _buildDetailCard(
          icon: Icons.water,
          iconColor: Colors.blue,
          title: 'HUMIDITÉ',
          value: '${weather.humidity}%',
          subtitle: '',
          description: 'Point de rosée: ${_calculateDewPoint(weather.temperature, weather.humidity).round()}°',
          gradient: [Colors.blue.withOpacity(0.2), Colors.indigo.withOpacity(0.1)],
        ),
        
        // Visibility
        _buildDetailCard(
          icon: Icons.visibility_outlined,
          iconColor: Colors.purple.shade300,
          title: 'VISIBILITÉ',
          value: '${(weather.visibility / 1000).round()}',
          subtitle: 'km',
          description: weather.visibility > 10000 ? 'Excellente' : 'Bonne',
          gradient: [Colors.purple.withOpacity(0.2), Colors.pink.withOpacity(0.1)],
        ),
        
        // Pressure
        _buildDetailCard(
          icon: Icons.compress,
          iconColor: Colors.indigo,
          title: 'PRESSION',
          value: '${weather.pressure}',
          subtitle: 'hPa',
          description: weather.pressure > 1013 ? 'Haute pression' : 'Basse pression',
          gradient: [Colors.indigo.withOpacity(0.2), Colors.deepPurple.withOpacity(0.1)],
        ),
      ],
    );
  }
  
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required String description,
    required List<Color> gradient,
    bool hasCompass = false,
    double windDegree = 0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: isVerySmallScreen ? 14 : isSmallScreen ? 16 : 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isVerySmallScreen ? 9 : isSmallScreen ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          if (hasCompass) ...[
            Center(
              child: Transform.rotate(
                angle: windDegree * 3.14159 / 180,
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isVerySmallScreen ? 11 : isSmallScreen ? 12 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              if (false) ...[
                const SizedBox(height: 1),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 9 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  String _getUVDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Faible';
    if (uvIndex <= 5) return 'Modéré';
    if (uvIndex <= 7) return 'Élevé';
    if (uvIndex <= 10) return 'Très élevé';
    return 'Extrême';
  }
  
  double _calculateDewPoint(double temp, int humidity) {
    final a = 17.27;
    final b = 237.7;
    final gamma = (a * temp / (b + temp)) + math.log((humidity / 100.0).clamp(0.01, 1.0));
    return (b * gamma) / (a - gamma);
  }

  Widget _buildMapPage(WeatherViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 120, bottom: 100),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Carte météo interactive
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Carte Météo Interactive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Bouton pour ouvrir la carte interactive
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherMapScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                          Colors.blue.shade900.withOpacity(0.2),
                          Colors.teal.shade900.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Image de carte
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cliquez pour ouvrir la carte',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Carte météo interactive avec données en temps réel',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bouton pour ouvrir la carte
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WeatherMapScreen(),
                                  ),
                                );
                              },
                              child: const Text('Ouvrir la carte'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Informations sur la carte
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📍 Cliquez sur une ville pour voir sa météo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🌡️ Température actuelle: ${viewModel.currentWeather?.temperature.round() ?? '--'}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 Position: ${viewModel.currentLocation?.cityName ?? 'Non définie'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Légende des conditions météo
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Légende',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(Icons.wb_sunny, 'Ensoleillé (25-35°C)', Colors.orange),
                  _buildLegendItem(Icons.cloud, 'Nuageux (20-25°C)', Colors.grey),
                  _buildLegendItem(Icons.beach_access, 'Pluvieux (15-20°C)', Colors.blue),
                  _buildLegendItem(Icons.ac_unit, 'Froid (<15°C)', Colors.cyan),
                  _buildLegendItem(Icons.whatshot, 'Très chaud (>35°C)', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(WeatherViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 120, bottom: 100),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingSection(
              title: 'Préférences',
              items: [
                _buildSettingItem(
                  icon: Icons.language_rounded,
                  title: 'Langue',
                  subtitle: 'Français',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.straighten_rounded,
                  title: 'Unités',
                  subtitle: 'Métrique (°C, km/h)',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'Activées',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingSection(
              title: 'À propos',
              items: [
                _buildSettingItem(
                  icon: Icons.info_rounded,
                  title: 'Version',
                  subtitle: '2.0.0',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Confidentialité',
                  subtitle: 'Politique de confidentialité',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.help_rounded,
                  title: 'Aide',
                  subtitle: 'Centre d\'aide',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> items,
  }) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WeatherViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                viewModel.error ?? 'Une erreur est survenue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              ModernButton(
                text: 'Réessayer',
                onPressed: () => viewModel.refresh(),
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Aucune donnée disponible',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, WeatherViewModel viewModel) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo ou titre
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.pink],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sama Tounsi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Actions
            Row(
              children: [
                _buildAppBarAction(
                  icon: Icons.search_rounded,
                  onTap: () => _showSearchDialog(context),
                ),
                const SizedBox(width: 8),
                _buildAppBarAction(
                  icon: Icons.favorite_rounded,
                  onTap: () => _showFavoritesDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Accueil',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.calendar_today_rounded,
                label: 'Prévisions',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.map_rounded,
                label: 'Carte',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings_rounded,
                label: 'Paramètres',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFAB(WeatherViewModel viewModel) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Localisation Actuelle
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "current_location",
              onPressed: () async {
                HapticFeedback.lightImpact();
                // Afficher un indicateur de chargement
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Récupération de votre position...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Obtenir la localisation actuelle
                await viewModel.loadCurrentLocationWeather();
              },
              backgroundColor: Colors.green.withOpacity(0.9),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton Mode Démo
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "demo_mode",
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DemoModeScreen(),
                  ),
                );
              },
              backgroundColor: Colors.purple.withOpacity(0.9),
              child: const Icon(
                Icons.theater_comedy,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton Refresh
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "refresh",
              onPressed: () {
                HapticFeedback.lightImpact();
                viewModel.refresh();
              },
              backgroundColor: Colors.white.withOpacity(0.9),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const ModernSearchPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showFavoritesDialog(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const ModernFavoritesPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
