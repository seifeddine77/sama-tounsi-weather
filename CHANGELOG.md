# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-20

### 🎉 Version initiale

#### Ajouté
- ✨ Météo en temps réel basée sur la localisation
- 📅 Prévisions sur 7 jours avec détails quotidiens
- 🏙️ Système de villes favorites
- 📊 Graphiques de température interactifs
- 🗺️ Carte météo interactive
- 🌙 Thème adaptatif (jour/nuit)
- 💾 Mode hors ligne avec cache local
- 🔍 Recherche de villes mondiale
- 📱 Design responsive pour tous les écrans
- 🎨 Animations fluides et modernes
- 🔐 Écran de permission pour la localisation
- 🌐 Support multilingue (FR/EN)

#### Technique
- Architecture MVVM avec Provider
- Stockage local avec Hive
- API OpenWeatherMap intégrée
- Gestion des permissions
- Support Android/iOS/Web

### Corrections
- ✅ Résolution des problèmes d'overflow sur petits écrans
- ✅ Optimisation des animations du splash screen
- ✅ Amélioration de la gestion des erreurs réseau
- ✅ Correction du système de cache

### Sécurité
- 🔒 Gestion sécurisée des clés API
- 🔐 Permissions explicites pour la localisation
- 🛡️ Validation des données API

## [0.9.0] - 2024-10-15 (Beta)

### Ajouté
- Version beta pour tests internes
- Fonctionnalités de base implémentées

## Roadmap

### [1.1.0] - À venir
- [ ] Notifications push pour alertes météo
- [ ] Widget pour l'écran d'accueil
- [ ] Plus de langues supportées
- [ ] Thèmes personnalisables

### [1.2.0] - Futur
- [ ] Support Apple Watch / WearOS
- [ ] Partage de la météo
- [ ] Export des données
- [ ] Prévisions horaires détaillées
