# Résolution de l'erreur Kotlin Daemon

## Erreur rencontrée
```
Daemon compilation failed: Could not connect to Kotlin compile daemon
java.lang.RuntimeException: Could not connect to Kotlin compile daemon
```

## Solutions à essayer dans l'ordre

### Solution 1 : Script automatique
Exécutez le fichier `fix_kotlin_daemon.bat` qui automatise toutes les étapes.

### Solution 2 : Commandes manuelles

1. **Nettoyage du projet**
   ```bash
   flutter clean
   ```

2. **Arrêt des processus Java/Gradle**
   - Ouvrez le Gestionnaire des tâches (Ctrl+Shift+Esc)
   - Terminez tous les processus `java.exe` et `gradle.exe`

3. **Suppression des caches**
   ```bash
   # Supprimer le cache Gradle
   rmdir /s /q "%USERPROFILE%\.gradle\caches"
   
   # Supprimer le cache Kotlin
   rmdir /s /q "%USERPROFILE%\.kotlin"
   ```

4. **Nettoyage Android**
   ```bash
   # Dans le dossier du projet
   rmdir /s /q "android\build"
   rmdir /s /q "android\.gradle"
   ```

5. **Récupération des dépendances**
   ```bash
   flutter pub get
   ```

### Solution 3 : Configuration Gradle

Le fichier `android/gradle.properties` a été mis à jour avec :
- Configuration optimisée du daemon Kotlin
- Allocation mémoire appropriée
- Option de fallback (décommenter si nécessaire)

### Solution 4 : Si le problème persiste

1. **Redémarrer l'ordinateur** pour libérer tous les processus

2. **Vérifier Java JDK**
   ```bash
   java -version
   ```
   Assurez-vous d'avoir Java 11 ou supérieur

3. **Mettre à jour Flutter**
   ```bash
   flutter upgrade
   flutter doctor
   ```

4. **Désactiver le daemon Kotlin** (solution de dernier recours)
   Dans `android/gradle.properties`, décommentez :
   ```
   kotlin.compiler.execution.strategy=in-process
   ```

### Solution 5 : Alternative de build

Si rien ne fonctionne, essayez :
```bash
flutter build apk --no-tree-shake-icons
```

ou

```bash
flutter run --debug
```

## Prévention

Pour éviter ce problème à l'avenir :
- Fermez Android Studio/VS Code avant les builds
- Ne lancez pas plusieurs builds simultanément
- Redémarrez régulièrement votre environnement de développement

## Vérification

Après résolution, testez avec :
```bash
flutter run
```

L'application devrait se compiler et se lancer sans erreur.