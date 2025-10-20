# Guide de Contribution

Merci de votre intérêt pour contribuer à Sama Tounsi Weather App ! 🎉

## Comment contribuer

### 🐛 Signaler des bugs

1. Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/yourusername/sama-tounsi-weather/issues)
2. Créez une nouvelle issue avec le template "Bug Report"
3. Incluez :
   - Description claire du problème
   - Étapes pour reproduire
   - Comportement attendu vs actuel
   - Screenshots si applicable
   - Version de Flutter/Dart
   - OS et version

### 💡 Proposer des fonctionnalités

1. Vérifiez les issues existantes
2. Créez une issue avec le template "Feature Request"
3. Décrivez clairement la fonctionnalité et son utilité

### 📝 Soumettre du code

#### Configuration de l'environnement

1. Fork le repository
2. Clone votre fork :
```bash
git clone https://github.com/yourusername/sama-tounsi-weather.git
cd sama-tounsi-weather
```

3. Ajoutez le repo original comme upstream :
```bash
git remote add upstream https://github.com/originaluser/sama-tounsi-weather.git
```

4. Créez une branche pour votre feature :
```bash
git checkout -b feature/nom-de-la-feature
```

#### Standards de code

- **Style** : Suivez les [Dart Style Guidelines](https://dart.dev/guides/language/effective-dart/style)
- **Formatage** : Utilisez `dart format`
```bash
dart format lib/
```

- **Analyse** : Assurez-vous qu'il n'y a pas d'erreurs
```bash
flutter analyze
```

- **Tests** : Ajoutez des tests pour les nouvelles fonctionnalités
```bash
flutter test
```

#### Structure des commits

Utilisez les conventions de commit suivantes :

- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, missing semi-colons, etc.
- `refactor:` Refactoring du code
- `test:` Ajout de tests
- `chore:` Maintenance

Exemple :
```bash
git commit -m "feat: ajout du widget de prévision horaire"
```

#### Pull Request

1. Mettez à jour votre branche avec main :
```bash
git fetch upstream
git rebase upstream/main
```

2. Push votre branche :
```bash
git push origin feature/nom-de-la-feature
```

3. Créez une Pull Request sur GitHub
4. Remplissez le template de PR
5. Attendez la review

### 📚 Documentation

- Commentez votre code en anglais ou français
- Mettez à jour le README si nécessaire
- Documentez les nouvelles APIs

### 🌐 Traduction

Pour ajouter une nouvelle langue :

1. Créez un fichier dans `lib/l10n/`
2. Ajoutez les traductions
3. Mettez à jour `lib/main.dart`

## Code de conduite

- Soyez respectueux et inclusif
- Acceptez les critiques constructives
- Focalisez-vous sur ce qui est mieux pour la communauté
- Montrez de l'empathie envers les autres

## Questions ?

N'hésitez pas à :
- Ouvrir une issue pour discuter
- Contacter les mainteneurs
- Rejoindre notre Discord/Slack (si applicable)

Merci pour votre contribution ! 🚀
