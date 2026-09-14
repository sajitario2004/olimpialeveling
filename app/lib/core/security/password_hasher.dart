import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Servicio de seguridad para el hash de contraseñas de cazadores del Sistema.
/// Implementa generación de Salt criptográfico y algoritmo SHA-256.
class PasswordHasher {
  /// Genera un salt criptográficamente seguro de [length] bytes en formato hexadecimal.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Calcula el hash SHA-256 de una contraseña combinada con su salt.
  static String hashPassword(String password, String salt) {
    final payload = utf8.encode('$salt:$password');
    final digest = sha256.convert(payload);
    return digest.toString();
  }

  /// Verifica si una contraseña proporcionada coincide con el hash esperado.
  static bool verifyPassword({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    final computedHash = hashPassword(password, salt);
    return computedHash == expectedHash;
  }

  /// Genera un identificador único (UID) alfanumérico aleatorio de [length] caracteres (letras y números).
  static String generateUid([int length = 15]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
