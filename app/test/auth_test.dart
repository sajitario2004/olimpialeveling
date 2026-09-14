import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:olimpia_leveling/core/security/password_hasher.dart';
import 'package:olimpia_leveling/models/user.dart';
import 'package:olimpia_leveling/core/database/database_helper.dart';
import 'package:olimpia_leveling/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Seguridad y Hasheo de Contraseñas (PasswordHasher)', () {
    test('Genera un salt hexadecimal aleatorio y seguro de longitud correcta', () {
      final salt1 = PasswordHasher.generateSalt(16);
      final salt2 = PasswordHasher.generateSalt(16);

      expect(salt1.length, 32); // 16 bytes en formato hex = 32 caracteres
      expect(salt2.length, 32);
      expect(salt1, isNot(equals(salt2)));
    });

    test('Hasheo determinista con SHA-256 para misma combinación de salt y contraseña', () {
      const salt = 'a1b2c3d4e5f60718';
      const password = 'sajiadmin';

      final hash1 = PasswordHasher.hashPassword(password, salt);
      final hash2 = PasswordHasher.hashPassword(password, salt);

      expect(hash1, equals(hash2));
      expect(hash1.length, 64); // SHA-256 produce 64 caracteres hex
    });

    test('Diferente salt produce hashes totalmente distintos (resistencia a Rainbow Tables)', () {
      const password = 'sajiadmin';
      final salt1 = PasswordHasher.generateSalt();
      final salt2 = PasswordHasher.generateSalt();

      final hash1 = PasswordHasher.hashPassword(password, salt1);
      final hash2 = PasswordHasher.hashPassword(password, salt2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('Verificación de contraseña correcta e incorrecta', () {
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hashPassword('sajiadmin', salt);

      expect(
        PasswordHasher.verifyPassword(password: 'sajiadmin', salt: salt, expectedHash: hash),
        isTrue,
      );
      expect(
        PasswordHasher.verifyPassword(password: 'incorrecta', salt: salt, expectedHash: hash),
        isFalse,
      );
    });
  });

  group('Modelo de Usuario (User) y Permisos de Rol', () {
    test('Identifica roles de Administrador y Desarrollador correctamente', () {
      const adminDev = User(
        id: 'u1',
        username: 'sajiadmin',
        passwordHash: 'hash',
        salt: 'salt',
        role: 'admin,developer',
        hunterName: 'Saji',
        createdAt: '2026-09-14',
      );

      expect(adminDev.isAdmin, isTrue);
      expect(adminDev.isDeveloper, isTrue);
      expect(adminDev.hasPrivilegedAccess, isTrue);
      expect(adminDev.roleDisplay, 'ADMIN // DEVELOPER');

      const normalHunter = User(
        id: 'u2',
        username: 'hunter1',
        passwordHash: 'hash',
        salt: 'salt',
        role: 'hunter',
        hunterName: 'Cazador Solitario',
        createdAt: '2026-09-14',
      );

      expect(normalHunter.isAdmin, isFalse);
      expect(normalHunter.isDeveloper, isFalse);
      expect(normalHunter.hasPrivilegedAccess, isFalse);
      expect(normalHunter.roleDisplay, 'CAZADOR');
    });

    test('Serialización y deserialización completa de User', () {
      const original = User(
        id: 'user_123',
        username: 'jinwoo',
        passwordHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        salt: 'salt_abc123',
        role: 'hunter',
        hunterName: 'Sung Jin-Woo',
        createdAt: '2026-09-14T20:00:00',
        lastLogin: '2026-09-14T21:00:00',
      );

      final map = original.toMap();
      final restored = User.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.username, original.username);
      expect(restored.passwordHash, original.passwordHash);
      expect(restored.salt, original.salt);
      expect(restored.role, original.role);
      expect(restored.hunterName, original.hunterName);
      expect(restored.createdAt, original.createdAt);
      expect(restored.lastLogin, original.lastLogin);
    });
  });

  group('Base de Datos SQLite y Cuenta sajiadmin por defecto', () {
    test('Cuenta sajiadmin existe en base de datos con contraseña cifrada', () async {
      final dbHelper = DatabaseHelper.instance;
      final sajiUser = await dbHelper.getUserByUsername('sajiadmin');

      expect(sajiUser, isNotNull);
      expect(sajiUser!.username, 'sajiadmin');
      expect(sajiUser.isAdmin, isTrue);
      expect(sajiUser.isDeveloper, isTrue);
      expect(sajiUser.hasPrivilegedAccess, isTrue);

      // Comprobar que la contraseña se valida con el hash
      final isValid = PasswordHasher.verifyPassword(
        password: 'sajiadmin',
        salt: sajiUser.salt,
        expectedHash: sajiUser.passwordHash,
      );
      expect(isValid, isTrue);
    });

    test('Guardado y recuperación de sesión activa', () async {
      final dbHelper = DatabaseHelper.instance;
      final sajiUser = await dbHelper.getUserByUsername('sajiadmin');
      expect(sajiUser, isNotNull);

      await dbHelper.saveActiveSession(sajiUser!.id);
      final activeUser = await dbHelper.getActiveSessionUser();
      expect(activeUser, isNotNull);
      expect(activeUser!.id, sajiUser.id);
      expect(activeUser.username, 'sajiadmin');

      await dbHelper.clearActiveSession();
      final cleared = await dbHelper.getActiveSessionUser();
      expect(cleared, isNull);
    });
  });

  group('Flujo de Autenticación en GameProvider', () {
    test('Login con credenciales válidas de sajiadmin', () async {
      final game = GameProvider();
      await game.initialize();

      final error = await game.login('sajiadmin', 'sajiadmin');
      expect(error, isNull);
      expect(game.isAuthenticated, isTrue);
      expect(game.currentUser?.username, 'sajiadmin');
      expect(game.isAdmin, isTrue);
      expect(game.isDeveloper, isTrue);

      await game.logout();
      expect(game.isAuthenticated, isFalse);
      expect(game.currentUser, isNull);
    });

    test('Login con contraseña incorrecta es denegado', () async {
      final game = GameProvider();
      await game.initialize();

      final error = await game.login('sajiadmin', 'password_equivocada');
      expect(error, isNotNull);
      expect(error, contains('Contraseña incorrecta'));
      expect(game.isAuthenticated, isFalse);
    });

    test('Registro de nuevo cazador con salt y contraseña hasheada', () async {
      final game = GameProvider();
      await game.initialize();

      final uniqueUser = 'hunter_${DateTime.now().millisecondsSinceEpoch}';
      final error = await game.register(uniqueUser, 'claveSecreta123', 'Cazador Fénix');

      expect(error, isNull);
      expect(game.isAuthenticated, isTrue);
      expect(game.currentUser?.username, uniqueUser);
      expect(game.currentUser?.hunterName, 'Cazador Fénix');
      expect(game.isAdmin, isFalse);

      await game.logout();
    });
  });
}
