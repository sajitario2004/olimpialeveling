import 'dart:convert';
import '../../models/routine.dart';

/// Servicio para codificar y decodificar rutinas en cadenas de texto alfanuméricas
/// fácilmente compartibles a través de WhatsApp, Telegram o portapapeles.
class RoutineShareService {
  static const String prefix = 'OLM:';

  /// Codifica una rutina completa en un código de texto compacto.
  static String encode(Routine routine) {
    final map = routine.toMap();
    // No incluir id de usuario privado al compartir
    map.remove('user_id');
    final jsonStr = jsonEncode(map);
    final bytes = utf8.encode(jsonStr);
    final base64Str = base64Url.encode(bytes);
    return '$prefix$base64Str';
  }

  /// Decodifica un código de texto en un objeto Routine válido con un nuevo ID.
  static Routine? decode(String rawCode, {required String userId}) {
    try {
      String code = rawCode.trim();
      if (code.startsWith(prefix)) {
        code = code.substring(prefix.length).trim();
      }
      final bytes = base64Url.decode(code);
      final jsonStr = utf8.decode(bytes);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Asignar identificadores nuevos para evitar colisiones
      map['id'] = 'shared_${DateTime.now().millisecondsSinceEpoch}';
      map['user_id'] = userId;
      map['created_at'] = DateTime.now().toIso8601String();

      return Routine.fromMap(map);
    } catch (_) {
      return null;
    }
  }
}
