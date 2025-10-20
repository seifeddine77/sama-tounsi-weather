# 🌤️ Sama Tounsi - Weather App

<div align="center">
  <img src="assets/logo.png" alt="Sama Tounsi Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue.svg)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
</div>

## 📱 Description

**Sama Tounsi** est une application météo moderne et élégante développée avec Flutter. Elle offre des prévisions météorologiques précises et en temps réel avec une interface utilisateur intuitive et des animations fluides.

## ✨ Fonctionnalités

- 🌍 **Météo en temps réel** : Données météo actuelles basées sur votre localisation
- 📅 **Prévisions 7 jours** : Prévisions détaillées pour la semaine
- 🏙️ **Villes favorites** : Sauvegardez et gérez vos villes préférées
- 📊 **Graphiques interactifs** : Visualisation des tendances de température
- 🗺️ **Carte météo** : Vue cartographique des conditions météo
- 🌙 **Mode sombre/clair** : Thème adaptatif selon l'heure
- 💾 **Mode hors ligne** : Consultation des dernières données sans connexion
- 🔔 **Notifications** : Alertes météo importantes (à venir)
- 🌐 **Multilingue** : Support français/anglais

## 🚀 Installation

### Prérequis

- Flutter SDK (>=3.9.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Un émulateur ou appareil physique

### Étapes d'installation

1. **Cloner le repository**
```bash
git clone https://github.com/yourusername/sama-tounsi-weather.git
cd sama-tounsi-weather
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration de l'API**
   - Créez un compte sur [OpenWeatherMap](https://openweathermap.org/api)
   - Obtenez votre clé API gratuite
   - Remplacez la clé API dans `lib/constants/api_constants.dart`
```dart
static const String apiKey = 'VOTRE_CLE_API';
```

4. **Lancer l'application**
```bash
flutter run
```

## 🏗️ Architecture

L'application suit le pattern **MVVM** (Model-View-ViewModel) avec Provider pour la gestion d'état :

```
lib/
├── models/          # Modèles de données
├── views/           # Écrans de l'application
├── viewmodels/      # Logique métier
├── services/        # Services (API, Storage, Location)
├── widgets/         # Composants réutilisables
├── themes/          # Thèmes et styles
├── constants/       # Constantes de l'application
└── utils/           # Utilitaires
```

## 📦 Dépendances principales

- **provider** : Gestion d'état
- **http** : Requêtes API
- **geolocator** : Géolocalisation
- **hive** : Base de données locale
- **fl_chart** : Graphiques
- **flutter_map** : Cartes
- **permission_handler** : Gestion des permissions
- **lottie** : Animations

## 🎨 Captures d'écran

<div align="center">
  <img src="screenshots/home.png" width="200" alt="Écran d'accueil"/>
  <img src="screenshots/forecast.png" width="200" alt="Prévisions"/>
  <img src="screenshots/map.png" width="200" alt="Carte"/>
  <img src="screenshots/favorites.png" width="200" alt="Favoris"/>
</div>

## 🔧 Configuration

### Android
- Min SDK : 21 (Android 5.0)
- Target SDK : 34 (Android 14)

### iOS
- iOS 12.0+

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 TODO

- [ ] Ajouter plus de langues
- [ ] Widget pour l'écran d'accueil
- [ ] Notifications push pour alertes météo
- [ ] Thèmes personnalisables
- [ ] Export des données météo
- [ ] Support Apple Watch / WearOS

## 🐛 Bugs connus

- Problème d'overflow sur certains petits écrans (résolu)
- Animation de splash screen à optimiser

## 📄 License

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👨‍💻 Auteur

**Votre Nom**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Votre Profil](https://linkedin.com/in/yourprofile)

## 🙏 Remerciements

- [OpenWeatherMap](https://openweathermap.org/) pour l'API météo
- [Flutter](https://flutter.dev/) pour le framework
- La communauté Flutter pour les packages

---

<div align="center">
  Fait avec ❤️ en Flutter
</div>
