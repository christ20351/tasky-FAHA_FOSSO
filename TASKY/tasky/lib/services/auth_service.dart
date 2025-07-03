import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_uid';
  static const String _passwordKey = 'user_passwords';
  
  final DatabaseService _databaseService = DatabaseService();
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  // Get current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Auth state changes stream
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // Initialize auth service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserUid = prefs.getString(_currentUserKey);
    
    if (currentUserUid != null) {
      _currentUser = await _databaseService.getUser(currentUserUid);
      _authStateController.add(_currentUser);
    } else {
      _authStateController.add(null);
    }
  }

  // Hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate unique user ID
  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Store password hash
  Future<void> _storePasswordHash(String email, String passwordHash) async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(_passwordKey) ?? '{}';
    final passwords = Map<String, String>.from(json.decode(passwordsJson));
    passwords[email] = passwordHash;
    await prefs.setString(_passwordKey, json.encode(passwords));
  }

  // Verify password
  Future<bool> _verifyPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(_passwordKey) ?? '{}';
    final passwords = Map<String, String>.from(json.decode(passwordsJson));
    final storedHash = passwords[email];
    
    if (storedHash == null) return false;
    return storedHash == _hashPassword(password);
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Un compte avec cet email existe déjà');
      }

      // Create new user
      String uid = _generateUserId();
      String profileLetter = pseudo.isNotEmpty ? pseudo[0].toUpperCase() : 'U';
      
      UserModel userModel = UserModel(
        uid: uid,
        pseudo: pseudo,
        email: email,
        profileLetter: profileLetter,
        createdAt: DateTime.now(),
      );

      // Store user in database
      await _databaseService.insertUser(userModel);
      
      // Store password hash
      await _storePasswordHash(email, _hashPassword(password));

      // Set as current user
      _currentUser = userModel;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, uid);
      
      _authStateController.add(_currentUser);
      return userModel;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Verify password
      final isValidPassword = await _verifyPassword(email, password);
      if (!isValidPassword) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // Get user data
      final user = await _databaseService.getUserByEmail(email);
      if (user == null) {
        throw Exception('Utilisateur non trouvé');
      }

      // Set as current user
      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, user.uid);
      
      _authStateController.add(_currentUser);
      return user;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      return await _databaseService.getUser(uid);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _databaseService.updateUser(user);
      if (_currentUser?.uid == user.uid) {
        _currentUser = user;
        _authStateController.add(_currentUser);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      _authStateController.add(null);
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (_currentUser != null) {
        // Remove password hash
        final prefs = await SharedPreferences.getInstance();
        final passwordsJson = prefs.getString(_passwordKey) ?? '{}';
        final passwords = Map<String, String>.from(json.decode(passwordsJson));
        passwords.remove(_currentUser!.email);
        await prefs.setString(_passwordKey, json.encode(passwords));
        
        // Delete user from database (this will cascade delete tasks)
        await _databaseService.deleteUser(_currentUser!.uid);
        
        // Sign out
        await signOut();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: ${e.toString()}');
    }
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}