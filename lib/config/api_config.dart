/// Configuration API sécurisée
/// 
/// IMPORTANT: Ne jamais committer de vraies clés API sur GitHub
/// Utilisez des variables d'environnement ou un fichier .env local
class ApiConfig {
  // Pour la production, utilisez des variables d'environnement
  // ou un service de gestion des secrets
  static const String openWeatherApiKey = const String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE', // Remplacer en local seulement
  );

  // Validation de la clé API
  static bool isApiKeyValid() {
    return openWeatherApiKey != 'YOUR_API_KEY_HERE' && 
           openWeatherApiKey.isNotEmpty;
  }

  // Message d'erreur pour clé API manquante
  static String getMissingApiKeyMessage() {
    return '''
    ⚠️ Clé API OpenWeatherMap manquante !
    
    Pour configurer l'application :
    1. Créez un compte sur https://openweathermap.org/api
    2. Obtenez votre clé API gratuite
    3. Remplacez 'YOUR_API_KEY_HERE' dans lib/constants/api_constants.dart
    
    Pour la production :
    - Utilisez des variables d'environnement
    - Ne committez jamais de vraies clés API
    ''';
  }
}
