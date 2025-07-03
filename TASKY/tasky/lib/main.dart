import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local auth service
  final authService = AuthService();
  await authService.initialize();
  
  runApp(TaskyApp(authService: authService));
}

class TaskyApp extends StatelessWidget {
  final AuthService? authService;
  
  const TaskyApp({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    // Créer une instance d'AuthService si elle n'est pas fournie (pour les tests)
    final authServiceInstance = authService ?? AuthService();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authServiceInstance)),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'TASKY',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}