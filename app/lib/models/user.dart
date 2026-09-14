/// Modelo de Usuario / Cazador autenticado en Olimpia Leveling.
class User {
  final String id;
  final String uid; // Identificador único de 15 caracteres alfanuméricos
  final String username;
  final String passwordHash;
  final String salt;
  final String role; // 'hunter', 'admin', 'developer', 'admin,developer'
  final String hunterName;
  final String createdAt;
  final String? lastLogin;
  final String? avatarUrl;

  const User({
    required this.id,
    this.uid = '000000000000001',
    required this.username,
    required this.passwordHash,
    required this.salt,
    this.role = 'hunter',
    required this.hunterName,
    required this.createdAt,
    this.lastLogin,
    this.avatarUrl,
  });

  /// Determina si el usuario tiene privilegios de Administrador.
  bool get isAdmin => role.contains('admin');

  /// Determina si el usuario tiene privilegios de Desarrollador (God Mode).
  bool get isDeveloper => role.contains('developer');

  /// Determina si el usuario tiene acceso a herramientas privilegiadas del Sistema.
  bool get hasPrivilegedAccess => isAdmin || isDeveloper;

  /// Rol formateado para mostrar en la interfaz.
  String get roleDisplay {
    if (isAdmin && isDeveloper) return 'ADMIN // DEVELOPER';
    if (isAdmin) return 'ADMINISTRADOR';
    if (isDeveloper) return 'DESARROLLADOR';
    return 'CAZADOR';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
      'role': role,
      'hunter_name': hunterName,
      'created_at': createdAt,
      'last_login': lastLogin,
      'avatar_url': avatarUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      uid: map['uid'] as String? ??
          (map['username'] == 'sajiadmin' ? '000000000000001' : '000000000000001'),
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      role: map['role'] as String? ?? 'hunter',
      hunterName: map['hunter_name'] as String? ?? map['username'] as String,
      createdAt: map['created_at'] as String,
      lastLogin: map['last_login'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? uid,
    String? username,
    String? passwordHash,
    String? salt,
    String? role,
    String? hunterName,
    String? createdAt,
    String? lastLogin,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      hunterName: hunterName ?? this.hunterName,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
