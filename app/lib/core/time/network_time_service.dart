import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Servicio de tiempo sincronizado por red para controlar los reinicios diarios (a las 00:00).
/// Si no hay conexión de red, recurre de forma segura a la hora del sistema del dispositivo.
class NetworkTimeService {
  static Duration? _networkOffset;
  static DateTime? _lastSuccessfulSync;

  /// Obtiene la hora real comprobada por red. Si falla o no hay conexión, usa la hora del sistema.
  static Future<DateTime> getNetworkTime() async {
    // Si sincronizamos hace menos de 5 minutos, calculamos con el desfase guardado
    if (_networkOffset != null && _lastSuccessfulSync != null) {
      if (DateTime.now().difference(_lastSuccessfulSync!).inMinutes < 5) {
        return DateTime.now().add(_networkOffset!);
      }
    }

    try {
      // 1. Intento primario: petición HEAD rápida a Google o Cloudflare para leer cabecera Date
      final client = http.Client();
      try {
        final response = await client
            .head(Uri.parse('https://clients3.google.com/generate_204'))
            .timeout(const Duration(seconds: 2));

        final dateHeader = response.headers['date'];
        if (dateHeader != null && dateHeader.isNotEmpty) {
          final serverUtc = HttpDate.parse(dateHeader);
          final serverLocal = serverUtc.toLocal();
          _networkOffset = serverLocal.difference(DateTime.now());
          _lastSuccessfulSync = DateTime.now();
          debugPrint('NetworkTimeService: Sincronizado por red HTTP Date -> $serverLocal');
          return serverLocal;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('NetworkTimeService: Fallo consulta HEAD primaria ($e), probando fallback...');
    }

    try {
      // 2. Intento secundario: Cloudflare
      final client = http.Client();
      try {
        final response = await client
            .head(Uri.parse('https://www.cloudflare.com'))
            .timeout(const Duration(seconds: 2));

        final dateHeader = response.headers['date'];
        if (dateHeader != null && dateHeader.isNotEmpty) {
          final serverUtc = HttpDate.parse(dateHeader);
          final serverLocal = serverUtc.toLocal();
          _networkOffset = serverLocal.difference(DateTime.now());
          _lastSuccessfulSync = DateTime.now();
          debugPrint('NetworkTimeService: Sincronizado vía Cloudflare -> $serverLocal');
          return serverLocal;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('NetworkTimeService: Sin respuesta de red ($e). Usando hora del sistema.');
    }

    // 3. Fallback: usar desfase anterior o reloj del dispositivo
    if (_networkOffset != null) {
      return DateTime.now().add(_networkOffset!);
    }
    return DateTime.now();
  }

  /// Devuelve la fecha formateada en formato estándar `yyyy-MM-dd` de hoy.
  static Future<String> getTodayDateString() async {
    final now = await getNetworkTime();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
