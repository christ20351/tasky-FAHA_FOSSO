@echo off
echo Résolution de l'erreur Kotlin Daemon...
echo.

echo 1. Nettoyage du projet Flutter...
flutter clean

echo.
echo 2. Arrêt des processus Gradle...
taskkill /f /im java.exe 2>nul
taskkill /f /im gradle.exe 2>nul

echo.
echo 3. Suppression du cache Gradle...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Cache Gradle supprimé
) else (
    echo Cache Gradle non trouvé
)

echo.
echo 4. Suppression du cache Kotlin...
if exist "%USERPROFILE%\.kotlin" (
    rmdir /s /q "%USERPROFILE%\.kotlin"
    echo Cache Kotlin supprimé
) else (
    echo Cache Kotlin non trouvé
)

echo.
echo 5. Nettoyage du dossier build Android...
if exist "android\build" (
    rmdir /s /q "android\build"
    echo Dossier build Android supprimé
)

if exist "android\.gradle" (
    rmdir /s /q "android\.gradle"
    echo Dossier .gradle Android supprimé
)

echo.
echo 6. Récupération des dépendances...
flutter pub get

echo.
echo 7. Tentative de build...
flutter build apk --debug

echo.
echo Si l'erreur persiste, essayez :
echo - Redémarrer votre ordinateur
echo - Mettre à jour Flutter : flutter upgrade
echo - Vérifier Java JDK version : java -version
echo.
pause