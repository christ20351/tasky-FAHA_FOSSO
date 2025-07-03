@echo off
echo Configuration du stockage local pour TASKY...
echo.

echo Nettoyage des dépendances...
flutter clean

echo Installation des nouvelles dépendances...
flutter pub get

echo.
echo Configuration terminée !
echo Le projet utilise maintenant SQLite et SharedPreferences pour le stockage local.
echo.
pause