# Migration vers le Stockage Local

## Changements effectués

Le projet TASKY a été reconfiguré pour utiliser le stockage local au lieu de Firebase. Voici les principales modifications :

### 1. Dépendances mises à jour

**Supprimées :**
- `firebase_core`
- `firebase_auth` 
- `cloud_firestore`

**Ajoutées :**
- `sqflite` : Base de données SQLite locale
- `path` : Gestion des chemins de fichiers
- `crypto` : Hachage sécurisé des mots de passe

### 2. Nouveaux services

#### DatabaseService (`lib/services/database_service.dart`)
- Gère la base de données SQLite locale
- Tables : `users` et `tasks`
- Opérations CRUD pour les utilisateurs et tâches
- Stream simulé pour les mises à jour en temps réel

#### AuthService mis à jour (`lib/services/auth_service.dart`)
- Authentification locale avec hachage SHA-256
- Stockage des sessions avec SharedPreferences
- Gestion des utilisateurs sans serveur externe

#### TaskService mis à jour (`lib/services/task_service.dart`)
- Utilise maintenant DatabaseService au lieu de Firestore
- Toutes les fonctionnalités conservées

### 3. Avantages du stockage local

✅ **Fonctionnement hors ligne** : L'application fonctionne sans connexion internet
✅ **Données privées** : Toutes les données restent sur l'appareil de l'utilisateur
✅ **Performance** : Accès plus rapide aux données locales
✅ **Simplicité** : Pas de configuration de serveur nécessaire
✅ **Sécurité** : Mots de passe hachés avec SHA-256

### 4. Structure de la base de données

#### Table `users`
```sql
CREATE TABLE users(
  uid TEXT PRIMARY KEY,
  pseudo TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  profileLetter TEXT NOT NULL,
  createdAt INTEGER NOT NULL
)
```

#### Table `tasks`
```sql
CREATE TABLE tasks(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  completedAt INTEGER,
  userId TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users (uid) ON DELETE CASCADE
)
```

### 5. Installation

1. Ex��cutez le script `setup_local_storage.bat` ou manuellement :
   ```bash
   flutter clean
   flutter pub get
   ```

2. L'application est maintenant prête à fonctionner avec le stockage local !

### 6. Fonctionnalités conservées

- ✅ Inscription/Connexion des utilisateurs
- ✅ Gestion des tâches (CRUD)
- ✅ Statistiques des tâches
- ✅ Interface utilisateur inchangée
- ✅ Gestion des thèmes
- ✅ Toutes les animations et transitions

### 7. Notes importantes

- Les données sont stockées localement sur chaque appareil
- Pas de synchronisation entre appareils (fonctionnalité locale uniquement)
- Les mots de passe sont hachés et ne peuvent pas être récupérés
- La base de données est créée automatiquement au premier lancement