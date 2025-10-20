import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../viewmodels/weather_viewmodel.dart';
import '../models/location_data.dart';
import '../models/weather_data.dart';
import '../themes/modern_theme.dart';
import '../services/weather_service.dart';
import '../views/modern_search_page.dart';

/// Page moderne pour gérer les villes favorites
class ModernFavoritesPage extends StatefulWidget {
  const ModernFavoritesPage({super.key});

  @override
  State<ModernFavoritesPage> createState() => _ModernFavoritesPageState();
}

class _ModernFavoritesPageState extends State<ModernFavoritesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fabController;
  final Map<String, WeatherData?> _weatherCache = {};
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animationController.forward();
    _fabController.forward();
    
    // Charger la météo pour toutes les villes favorites
    _loadAllWeatherData();
  }

  Future<void> _loadAllWeatherData() async {
    final viewModel = context.read<WeatherViewModel>();
    setState(() => _isLoading = true);
    
    for (final city in viewModel.favoriteCities) {
      try {
        final weather = await _weatherService.getCurrentWeather(
          city.latitude,
          city.longitude,
        );
        if (mounted) {
          setState(() {
            _weatherCache[city.cityName] = weather;
          });
        }
      } catch (e) {
        print('Erreur chargement météo pour ${city.cityName}: $e');
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernTheme.nightGradient,
        ),
        child: Stack(
          children: [
            // Effet de particules en arrière-plan
            _buildBackgroundEffect(),
            
            // Contenu principal
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildFavoritesList(),
                  ),
                ],
              ),
            ),
            
            // FAB pour ajouter une ville
            _buildAddFAB(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(animation: _animationController),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Villes Favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadAllWeatherData,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isLoading ? _animationController.value * 2 * 3.14159 : 0,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barre de statistiques
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Consumer<WeatherViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.location_city_rounded,
                      value: '${viewModel.favoriteCities.length}',
                      label: 'Villes',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      icon: Icons.update_rounded,
                      value: 'En direct',
                      label: 'Mise à jour',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      icon: Icons.cloud_rounded,
                      value: '${_weatherCache.length}',
                      label: 'Synchronisé',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
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

  Widget _buildFavoritesList() {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.favoriteCities.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadAllWeatherData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: viewModel.favoriteCities.length,
            itemBuilder: (context, index) {
              final city = viewModel.favoriteCities[index];
              final weather = _weatherCache[city.cityName];
              
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.easeOutBack,
                  ),
                )),
                child: _buildFavoriteCard(city, weather, viewModel),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(
    LocationData city,
    WeatherData? weather,
    WeatherViewModel viewModel,
  ) {
    return Dismissible(
      key: Key(city.cityName),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(city);
      },
      onDismissed: (direction) {
        viewModel.removeFromFavorites(city);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${city.cityName} supprimé des favoris'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () {
                viewModel.addToFavorites(city);
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _loadCityWeather(city, viewModel);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône météo ou ville
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: weather != null
                          ? _getWeatherGradient(weather.mainCondition)
                          : [Colors.blue, Colors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    weather != null
                        ? _getWeatherIcon(weather.mainCondition)
                        : Icons.location_city_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations de la ville
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.cityName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city.country,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          if (city.state != null && city.state!.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              city.state!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Température ou chargement
                if (weather != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        weather.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ] else if (_isLoading) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 28,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune ville favorite',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos villes préférées\npour un accès rapide',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          ModernButton(
            text: 'Ajouter une ville',
            icon: Icons.add_location_alt_rounded,
            onPressed: _showAddCityDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAddFAB() {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.favoriteCities.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          bottom: 20,
          right: 20,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabController,
              curve: Curves.elasticOut,
            ),
            child: FloatingActionButton.extended(
              onPressed: _showAddCityDialog,
              backgroundColor: ModernTheme.primaryBlue,
              label: const Text(
                'Ajouter',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(
                Icons.add_location_alt_rounded,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(LocationData city) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Supprimer ${city.cityName}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Cette ville sera retirée de vos favoris.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddCityDialog() {
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

  void _loadCityWeather(LocationData city, WeatherViewModel viewModel) async {
    Navigator.of(context).pop();
    await viewModel.loadFavoriteWeather(city);
  }

  List<Color> _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return [Colors.orange, Colors.yellow];
      case 'clouds':
        return [Colors.blueGrey, Colors.grey];
      case 'rain':
        return [Colors.blue, Colors.indigo];
      case 'snow':
        return [Colors.lightBlue, Colors.white];
      case 'thunderstorm':
        return [Colors.deepPurple, Colors.purple];
      default:
        return [Colors.blue, Colors.cyan];
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.grain_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }
}

// Painter pour l'arrière-plan animé
class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Dessiner des cercles flottants
    for (int i = 0; i < 5; i++) {
      final progress = (animation.value + i * 0.2) % 1.0;
      final y = size.height * (1 - progress);
      final opacity = (1 - progress) * 0.1;
      
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(
          size.width * (0.2 + i * 0.15),
          y,
        ),
        30 + i * 10.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}
