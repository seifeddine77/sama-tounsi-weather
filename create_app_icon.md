# 🎨 Création de l'icône de l'application Weather Pro

## Option 1: Utiliser un générateur en ligne (RECOMMANDÉ)

1. **Allez sur** : https://www.appicon.co/ ou https://icon.kitchen/
2. **Téléchargez cette image** ou créez votre propre design :
   - Fond: Dégradé bleu-violet (#667EEA → #764BA2)
   - Éléments: Soleil ☀️ + Nuage ☁️ + Gouttes 💧

3. **Générez les icônes** pour Android et iOS

4. **Placez les fichiers** :
   - Android: `android/app/src/main/res/mipmap-*`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Option 2: Utiliser Flutter Launcher Icons

1. **Créez une image PNG** (1024x1024) nommée `app_icon.png` dans `assets/icon/`

2. **Installez les dépendances** :
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

## Option 3: Icône temporaire avec emoji

Pour une solution rapide, créez une image avec ces éléments :
- 🌤️ ou ⛅ ou 🌦️
- Fond coloré dégradé

## Design suggéré pour l'icône :

```
╔═══════════════════╗
║                   ║
║      ☀️           ║
║         ☁️        ║
║     💧 💧 💧      ║
║                   ║
╚═══════════════════╝
```

## Couleurs recommandées :
- Primaire: #667EEA (Bleu)
- Secondaire: #764BA2 (Violet)
- Accent: #FFD700 (Or pour le soleil)

## Tailles requises :

### Android (mipmap) :
- mdpi: 48×48
- hdpi: 72×72
- xhdpi: 96×96
- xxhdpi: 144×144
- xxxhdpi: 192×192

### iOS :
- 20pt: 20×20, 40×40, 60×60
- 29pt: 29×29, 58×58, 87×87
- 40pt: 40×40, 80×80, 120×120
- 60pt: 120×120, 180×180
- 1024pt: 1024×1024 (App Store)
