class UserModel {
  final String uid;
  final String pseudo;
  final String email;
  final String profileLetter;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.pseudo,
    required this.email,
    required this.profileLetter,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      pseudo: map['pseudo'] ?? '',
      email: map['email'] ?? '',
      profileLetter: map['profileLetter'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pseudo': pseudo,
      'email': email,
      'profileLetter': profileLetter,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? pseudo,
    String? email,
    String? profileLetter,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      pseudo: pseudo ?? this.pseudo,
      email: email ?? this.email,
      profileLetter: profileLetter ?? this.profileLetter,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}