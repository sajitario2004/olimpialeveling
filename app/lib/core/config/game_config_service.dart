import 'dart:convert';
import 'package:flutter/services.dart';

/// Servicio de configuración del juego empaquetada en el APK.
/// Permite leer los tiempos de descanso, curvas de nivel y parámetros
/// definidos y exportados desde el servidor Python local en localhost:8000.
class GameConfigService {
  static final GameConfigService instance = GameConfigService._init();
  GameConfigService._init();

  int _defaultRestTimeSeconds = 90;
  double _xpCurveBase = 1000.0;
  double _xpCurveMultiplier = 1.15;
  int _statPointsPerLevel = 3;
  bool _penaltyEnabled = true;
  bool _isLoaded = false;

  int get defaultRestTimeSeconds => _defaultRestTimeSeconds;
  double get xpCurveBase => _xpCurveBase;
  double get xpCurveMultiplier => _xpCurveMultiplier;
  int get statPointsPerLevel => _statPointsPerLevel;
  bool get penaltyEnabled => _penaltyEnabled;
  bool get isLoaded => _isLoaded;

  /// Carga la configuración estática embebida en los assets del APK.
  Future<void> loadBundledConfig() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/game_config.json');
      final Map<String, dynamic> data = json.decode(jsonStr);

      if (data.containsKey('settings')) {
        final settings = data['settings'] as Map<String, dynamic>;
        _defaultRestTimeSeconds = settings['default_rest_time_seconds'] as int? ?? _defaultRestTimeSeconds;
        _xpCurveBase = (settings['xp_curve_base'] as num?)?.toDouble() ?? _xpCurveBase;
        _xpCurveMultiplier = (settings['xp_curve_multiplier'] as num?)?.toDouble() ?? _xpCurveMultiplier;
        _statPointsPerLevel = settings['stat_points_per_level'] as int? ?? _statPointsPerLevel;
        _penaltyEnabled = settings['penalty_enabled'] as bool? ?? _penaltyEnabled;
      }
      _isLoaded = true;
    } catch (_) {
      // Si el asset no existe o no se puede leer, conserva los valores por defecto seguros
      _isLoaded = true;
    }
  }
}
