import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/database/database_helper.dart';
import '../core/audio/audio_service.dart';
import '../core/sync/server_sync_service.dart';
import '../core/security/password_hasher.dart';
import '../models/muscle.dart';
import '../models/exercise.dart';
import '../models/daily_quest.dart';
import '../models/player.dart';
import '../models/rank.dart';
import '../models/user.dart';
import '../models/routine.dart';
import '../core/time/network_time_service.dart';

class LevelUpEvent {
  final String muscleName;
  final int muscleLevel;
  final int totalLevel;
  final RankTier rank;
  final int pointsAwarded;

  LevelUpEvent({
    required this.muscleName,
    required this.muscleLevel,
    required this.totalLevel,
    required this.rank,
    required this.pointsAwarded,
  });
}

class GameProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  ServerSyncService _sync = ServerSyncService();

  User? _currentUser;
  Player? _player;
  List<Muscle> _muscles = [];
  List<Exercise> _exercises = [];
  List<DailyQuest> _dailyQuests = [];

  bool _isLoading = true;
  bool _isServerOnline = false;
  String? _penaltyAlert;
  LevelUpEvent? _lastLevelUpEvent;
  String _serverUrl = 'http://127.0.0.1:8000';

  // Anti-cheat tracking
  DateTime? _lastLoggedWorkoutTime;
  String? _lastLoggedExerciseId;
  String? _antiCheatWarning;

  // Workout logs & PR tracking
  List<Map<String, dynamic>> _workoutLogs = [];
  double _todayVolume = 0.0;
  String? _prAlert;
  List<Routine> _routines = [];

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isDeveloper => _currentUser?.isDeveloper ?? false;

  Player? get player => _player;
  List<Muscle> get muscles => _muscles;
  List<Exercise> get exercises => _exercises;
  List<DailyQuest> get dailyQuests => _dailyQuests;
  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;
  bool get isServerOnline => _isServerOnline;
  String? get penaltyAlert => _penaltyAlert;
  LevelUpEvent? get lastLevelUpEvent => _lastLevelUpEvent;
  String get serverUrl => _serverUrl;
  String? get antiCheatWarning => _antiCheatWarning;
  List<Map<String, dynamic>> get workoutLogs => _workoutLogs;
  double get todayVolume => _todayVolume;
  String? get prAlert => _prAlert;

  /// Nivel del Cazador en la escala de 1 a 100 (suma de los 14 músculos / 14).
  int get hunterLevel {
    if (_player == null) return 1;
    final avg = (_player!.totalLevel / 14).floor();
    return avg.clamp(1, 100);
  }

  /// Progreso hacia el siguiente nivel de Cazador (0.0 a 1.0).
  /// Al alcanzar el nivel 100, devuelve 1.0 (barra completa dorada).
  double get hunterLevelProgress {
    if (_player == null) return 0.0;
    if (hunterLevel >= 100) return 1.0;
    final fraction = (_player!.totalLevel % 14) / 14.0;
    return fraction.clamp(0.0, 1.0);
  }

  /// Rango del jugador en la escala 0..100
  RankTier get hunterRank => RankTier.getRankForHunterLevel(
        hunterLevel,
        hasCompletedSupremeTrial: _player?.hasCompletedSupremeTrial ?? false,
      );

  /// Indica si el cazador se encuentra en un nivel que requiere prueba física semanal (Superentrenamiento) para ascender.
  /// En el nivel 100, se requiere la Prueba Suprema para desbloquear God of Olimpus.
  bool get isAtTrialLevel {
    if (_player == null) return false;
    if (hunterLevel >= 100) {
      return !_player!.hasCompletedSupremeTrial;
    }
    if (RankTier.isTrialLevel(hunterLevel)) {
      return _player!.lastCompletedTrialLevel < hunterLevel;
    }
    return false;
  }

  /// Indica si el jugador ha ascendido formalmente a God of Olimpus tras superar la prueba suprema
  bool get isGodOfOlimpusUnlocked =>
      hunterLevel >= 100 && (_player?.hasCompletedSupremeTrial ?? false);

  /// Completa el superentrenamiento / prueba de ascenso de rango
  Future<void> completeAscensionTrial([int? level]) async {
    if (_player == null) return;
    final trialLvl = level ?? hunterLevel;
    _player!.lastCompletedTrialLevel = trialLvl;
    if (trialLvl >= 100) {
      _player!.hasCompletedSupremeTrial = true;
    }
    await _db.updatePlayer(_player!);
    AudioService.instance.playLevelUp();
    notifyListeners();
  }

  /// Completa la prueba suprema del nivel 100 coronando al cazador como GOD OF OLIMPUS
  Future<void> completeSupremeAscensionTrial() async {
    await completeAscensionTrial(100);
  }

  void clearPrAlert() {
    _prAlert = null;
    notifyListeners();
  }

  Future<double> getMaxWeightForExercise(String exerciseId) {
    return _db.getMaxWeightForExercise(exerciseId);
  }

  Future<Map<String, double>> getAllPersonalRecords() {
    return _db.getAllPersonalRecords();
  }

  /// Herramienta de desarrollador: modificar o fijar el récord personal de un ejercicio
  Future<void> devSetPersonalRecord(String exerciseId, double weightKg) async {
    await _db.devSetPersonalRecord(exerciseId, weightKg);
    notifyListeners();
  }

  /// Herramienta de desarrollador: forzar el rango a cualquiera de los 8 rangos para pruebas
  Future<void> devSetRank(String rankId) async {
    if (_player == null) return;
    int targetLevel = 1;
    bool supreme = false;
    switch (rankId) {
      case 'skinnybitch':
        targetLevel = 2;
        break;
      case 'human':
        targetLevel = 8;
        break;
      case 'normal_gym_buddy':
        targetLevel = 20;
        break;
      case 'gymbro':
        targetLevel = 35;
        break;
      case 'soldier':
        targetLevel = 55;
        break;
      case 'spartan':
        targetLevel = 70;
        break;
      case 'hercules':
        targetLevel = 88;
        break;
      case 'god_of_olimpus':
        targetLevel = 100;
        supreme = true;
        break;
      default:
        targetLevel = 1;
    }

    _player!.totalLevel = targetLevel * 14;
    _player!.hasCompletedSupremeTrial = supreme;
    for (int i = 0; i < _muscles.length; i++) {
      _muscles[i] = _muscles[i].copyWith(level: targetLevel);
      await _db.updateMuscle(_muscles[i]);
    }
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  void clearLevelUpEvent() {
    _lastLevelUpEvent = null;
    notifyListeners();
  }

  void clearPenaltyAlert() {
    _penaltyAlert = null;
    notifyListeners();
  }

  void clearAntiCheatWarning() {
    _antiCheatWarning = null;
    notifyListeners();
  }

  Future<void> updateServerUrl(String newUrl) async {
    _serverUrl = newUrl;
    _sync = ServerSyncService(baseUrl: newUrl);
    _isServerOnline = await _sync.checkServerOnline();
    notifyListeners();
  }

  @visibleForTesting
  void loadTestData({
    Player? player,
    List<Muscle>? muscles,
    List<Exercise>? exercises,
    List<DailyQuest>? dailyQuests,
    List<Map<String, dynamic>>? workoutLogs,
    double? todayVolume,
    User? currentUser,
  }) {
    _player = player ?? _player;
    _muscles = muscles ?? _muscles;
    _exercises = exercises ?? _exercises;
    _dailyQuests = dailyQuests ?? _dailyQuests;
    _workoutLogs = workoutLogs ?? _workoutLogs;
    _todayVolume = todayVolume ?? _todayVolume;
    _currentUser = currentUser ?? _currentUser;
    _isLoading = false;
    notifyListeners();
  }

  /// Asegura que el jugador, músculos, ejercicios y misiones estén cargados en memoria.
  Future<void> ensureGameStateLoaded() async {
    try {
      if (_player == null) {
        _player = await _db.getPlayer();
      }
      if (_muscles.isEmpty) {
        _muscles = await _db.getAllMuscles();
      }
      if (_exercises.isEmpty) {
        _exercises = await _db.getAllExercises();
      }
      if (_dailyQuests.isEmpty) {
        final todayStr = await NetworkTimeService.getTodayDateString();
        _dailyQuests = await _db.getDailyQuestsForDate(todayStr);
        if (_dailyQuests.isEmpty) {
          await _handleMidnightCycle(todayStr);
        }
      }
      await refreshWorkoutLogs();
    } catch (e) {
      debugPrint('Error in ensureGameStateLoaded: $e');
    }
  }

  Future<void> initialize() async {
    _isLoading = true;

    try {
      await checkAuthSession();
      await ensureGameStateLoaded();

      // Check server connectivity
      _isServerOnline = await _sync.checkServerOnline();

      // Load routines
      await loadRoutines();

      _isLoading = false;
      notifyListeners();

      // Trigger background sync
      if (_player != null && _isServerOnline) {
        _sync.syncPlayerState(_player!, muscles: _muscles);
      }
    } catch (e) {
      debugPrint('GameProvider init error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleMidnightCycle(String todayStr) async {
    if (_player == null) return;

    // Check if day changed since last active date
    if (_player!.lastActiveDate != todayStr) {
      // Check if player failed yesterday's daily quests AND did not use a Rest Day Token
      if (_player!.completedDailyDate != _player!.lastActiveDate && !_player!.isRestDayUsedToday) {
        // PENALTY TRIGGERED! Player loses 1 level
        final oldLevel = _player!.totalLevel;
        _player!.totalLevel = max(14, _player!.totalLevel - 1);
        
        // Also reduce highest muscle level to keep sum balanced
        if (_muscles.isNotEmpty) {
          _muscles.sort((a, b) => b.level.compareTo(a.level));
          if (_muscles.first.level > 1) {
            _muscles.first.level -= 1;
            await _db.updateMuscle(_muscles.first);
          }
        }

        _penaltyAlert = "¡ADVERTENCIA DEL SISTEMA!\nNo completaste tu misión diaria antes de medianoche.\nPenalización aplicada: -1 Nivel (Nivel $oldLevel ➔ ${_player!.totalLevel})";
        AudioService.instance.playPenaltyAlert();
      }

      _player!.isRestDayUsedToday = false;
      _player!.lastActiveDate = todayStr;
      await _db.updatePlayer(_player!);
    }

    // Load or generate the 4 legendary daily quests for today
    _dailyQuests = await _db.getDailyQuestsForDate(todayStr);
    if (_dailyQuests.isEmpty) {
      _dailyQuests = [
        DailyQuest(
          id: 'quest_${todayStr}_flexiones',
          name: '100 Flexiones de Heracles',
          target: 100.0,
          unit: 'reps',
          date: todayStr,
          isSelected: true,
        ),
        DailyQuest(
          id: 'quest_${todayStr}_sentadillas',
          name: '100 Sentadillas de Ares',
          target: 100.0,
          unit: 'reps',
          date: todayStr,
        ),
        DailyQuest(
          id: 'quest_${todayStr}_abdominales',
          name: '100 Abdominales de Zeus',
          target: 100.0,
          unit: 'reps',
          date: todayStr,
        ),
        DailyQuest(
          id: 'quest_${todayStr}_correr',
          name: '10 Kilómetros de Hermes',
          target: 10.0,
          unit: 'km',
          date: todayStr,
        ),
      ];
      await _db.insertDailyQuests(_dailyQuests);
    }
  }

  Future<void> selectDailyQuest(String questId) async {
    for (var q in _dailyQuests) {
      q.isSelected = (q.id == questId);
      await _db.updateDailyQuest(q);
    }
    _player?.selectedDailyQuestId = questId;
    if (_player != null) {
      await _db.updatePlayer(_player!);
    }
    notifyListeners();
  }

  Muscle? getMuscle(String id) {
    try {
      return _muscles.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> logWorkout({
    required Exercise exercise,
    required double weightKg,
    required int reps,
    int dropsetDrops = 0,
    int? customMultiplier,
  }) async {
    if (_player == null) return false;

    // Anti-cheat verification
    final now = DateTime.now();
    if (_lastLoggedWorkoutTime != null && _lastLoggedExerciseId == exercise.id) {
      final diff = now.difference(_lastLoggedWorkoutTime!).inSeconds;
      if (diff < 5 && reps > 15) {
        _antiCheatWarning = "El Sistema detecta una cadencia anormalmente rápida ($diff s). Respeta el tiempo de recuperación para una hipertrofia real.";
        notifyListeners();
      }
    }
    _lastLoggedWorkoutTime = now;
    _lastLoggedExerciseId = exercise.id;

    // Cap excessive reps per set to avoid unrealistic inputs
    final safeReps = reps.clamp(1, 200);

    // Apply streak multiplier (7 days -> +5%, 30 days -> +10%)
    final streakMultiplier = _player!.streakXpMultiplier;
    final xpDistribution = exercise.calculateXp(
      weightKg: weightKg,
      reps: safeReps,
      dropsetDrops: dropsetDrops,
      customMultiplier: customMultiplier,
    );

    // Check for Personal Record (PR)
    final priorMax = await _db.getMaxWeightForExercise(exercise.id);
    bool isNewPr = false;
    if (priorMax > 0 && weightKg > priorMax) {
      isNewPr = true;
      _prAlert = "¡NUEVO RÉCORD PERSONAL (PR) EN ${exercise.name.toUpperCase()}!\nSuperaste tu marca previa de ${priorMax.toStringAsFixed(1)} kg levantando ${weightKg.toStringAsFixed(1)} kg.\n¡+50 XP de Bonificación Divina otorgada!";
    }

    for (var entry in xpDistribution.entries) {
      final muscleId = entry.key;
      final xp = entry.value * streakMultiplier;

      final muscle = getMuscle(muscleId);
      if (muscle != null) {
        await _addXpToMuscle(muscle, xp);
        await _db.logWorkout(
          exerciseId: exercise.id,
          weight: weightKg,
          reps: safeReps,
          xpAwarded: xp,
          muscleId: muscleId,
        );
      }
    }

    // Award PR Bonus XP
    if (isNewPr) {
      final primaryM = getMuscle(exercise.primaryMuscle);
      if (primaryM != null) {
        await _addXpToMuscle(primaryM, 50.0 * streakMultiplier);
      }
    }

    // Check if exercise contributes to any daily quest (e.g. flexiones, sentadillas, abdominales)
    _checkQuestsProgression(exercise.name, safeReps.toDouble());

    // Refresh history
    await refreshWorkoutLogs();

    notifyListeners();

    if (_isServerOnline) {
      _sync.syncPlayerState(_player!, muscles: _muscles);
    }
    return true;
  }

  Future<void> _addXpToMuscle(Muscle muscle, double xp) async {
    muscle.currentXp += xp;
    bool leveledUp = false;

    while (muscle.currentXp >= muscle.xpForNextLevel) {
      if (isAtTrialLevel) {
        // Bloqueo estricto: no se puede subir de nivel si no se ha completado el superentrenamiento
        muscle.currentXp = (muscle.xpForNextLevel - 0.1).clamp(0.0, double.infinity);
        break;
      }
      muscle.currentXp -= muscle.xpForNextLevel;
      muscle.level += 1;
      _player!.totalLevel += 1;
      _player!.unallocatedPoints += 3; // +3 stat points per level
      leveledUp = true;
    }

    await _db.updateMuscle(muscle);
    await _db.updatePlayer(_player!);

    if (leveledUp) {
      AudioService.instance.playLevelUp();
      _lastLevelUpEvent = LevelUpEvent(
        muscleName: muscle.name,
        muscleLevel: muscle.level,
        totalLevel: _player!.totalLevel,
        rank: _player!.rank,
        pointsAwarded: 3,
      );
    }
  }

  void _checkQuestsProgression(String exerciseName, double progressToAdd) {
    final lower = exerciseName.toLowerCase();
    for (var quest in _dailyQuests) {
      final qLower = quest.name.toLowerCase();
      if ((lower.contains('flexion') && qLower.contains('flexion')) ||
          (lower.contains('sentadilla') && qLower.contains('sentadilla')) ||
          (lower.contains('abdominal') && qLower.contains('abdominal')) ||
          (lower.contains('crunch') && qLower.contains('abdominal')) ||
          (lower.contains('correr') && qLower.contains('carrera'))) {
        quest.addProgress(progressToAdd);
        _db.updateDailyQuest(quest);
      }
    }
    _checkQuestsCompletion();
  }

  Future<void> addProgressToQuest(String questId, double amount) async {
    final quest = _dailyQuests.firstWhere((q) => q.id == questId);
    quest.addProgress(amount);
    await _db.updateDailyQuest(quest);
    await _checkQuestsCompletion();
    notifyListeners();
  }

  Future<void> _checkQuestsCompletion() async {
    if (_dailyQuests.isEmpty || _player == null) return;
    // Completing ANY of the 4 daily quests (or the selected one) fulfills the daily requirement!
    final hasCompletedAny = _dailyQuests.any((q) => q.isCompleted);
    if (hasCompletedAny && _player!.completedDailyDate != _player!.lastActiveDate) {
      _player!.completedDailyDate = _player!.lastActiveDate;
      _player!.streakDays += 1;
      // Award rest token every 6 days of streak
      if (_player!.streakDays % 6 == 0) {
        _player!.restTokens += 1;
      }
      await _db.updatePlayer(_player!);
      AudioService.instance.playQuestComplete();
    }
  }

  Future<bool> useRestDayToken() async {
    if (_player == null || _player!.restTokens <= 0 || _player!.isRestDayUsedToday) {
      return false;
    }
    _player!.restTokens -= 1;
    _player!.isRestDayUsedToday = true;
    _player!.completedDailyDate = _player!.lastActiveDate;
    await _db.updatePlayer(_player!);
    notifyListeners();
    return true;
  }

  Future<void> allocateStatPoint(String statKey) async {
    if (_player == null || _player!.unallocatedPoints <= 0) return;

    if (statKey == 'strength') {
      _player!.strength += 1;
    } else if (statKey == 'agility') {
      _player!.agility += 1;
    } else if (statKey == 'endurance') {
      _player!.endurance += 1;
    } else if (statKey == 'discipline') {
      _player!.discipline += 1;
    }

    _player!.unallocatedPoints -= 1;
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  Future<void> equipTitle(String? title) async {
    if (_player == null) return;
    _player!.equippedTitle = title;
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  Future<String> exportBackupJson() async {
    final playerMap = _player?.toMap() ?? {};
    final musclesList = _muscles.map((m) => m.toMap()).toList();
    final questsList = _dailyQuests.map((q) => q.toMap()).toList();

    final data = {
      'app': 'Olimpia Leveling',
      'version': '0.0.1',
      'exported_at': DateTime.now().toIso8601String(),
      'player': playerMap,
      'muscles': musclesList,
      'daily_quests': questsList,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> resetAllProgress() async {
    if (_player == null) return;
    _player!.totalLevel = 14;
    _player!.strength = 10;
    _player!.agility = 10;
    _player!.endurance = 10;
    _player!.discipline = 10;
    _player!.unallocatedPoints = 0;
    _player!.streakDays = 1;
    _player!.equippedTitle = null;
    await _db.updatePlayer(_player!);

    for (var m in _muscles) {
      m.level = 1;
      m.currentXp = 0.0;
      await _db.updateMuscle(m);
    }
    notifyListeners();
  }

  /// Utility to test midnight penalty trigger
  Future<void> simulateMidnightPenalty() async {
    if (_player == null) return;
    final oldLevel = _player!.totalLevel;
    _player!.totalLevel = max(14, _player!.totalLevel - 1);
    
    if (_muscles.isNotEmpty) {
      _muscles.sort((a, b) => b.level.compareTo(a.level));
      if (_muscles.first.level > 1) {
        _muscles.first.level -= 1;
        await _db.updateMuscle(_muscles.first);
      }
    }

    _penaltyAlert = "¡ADVERTENCIA DEL SISTEMA!\nPenalización de medianoche activada: No se completaron las misiones diarias.\nSe ha descontado 1 nivel (Nivel $oldLevel ➔ ${_player!.totalLevel})";
    AudioService.instance.playPenaltyAlert();
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  Future<void> refreshWorkoutLogs() async {
    try {
      _workoutLogs = await _db.getWorkoutLogs(limit: 50);
      final todayStr = await NetworkTimeService.getTodayDateString();
      _todayVolume = await _db.getTodayVolume(todayStr);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing workout logs: $e');
    }
  }

  /// Comprueba activamente si se ha producido el cambio de día a las 00:00 por hora de red.
  Future<void> checkDailyReset() async {
    final todayStr = await NetworkTimeService.getTodayDateString();
    await _handleMidnightCycle(todayStr);
    await refreshWorkoutLogs();
    notifyListeners();
  }

  // ==================== MÉTODOS DE AUTENTICACIÓN ====================

  /// Comprueba si existe una sesión activa persistida en SQLite.
  Future<void> checkAuthSession() async {
    try {
      final user = await _db.getActiveSessionUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking auth session: $e');
    }
  }

  /// Inicia sesión con nombre de usuario y contraseña verificando el hash SHA-256 + salt.
  Future<String?> login(String username, String password) async {
    try {
      final cleanUser = username.trim().toLowerCase();
      final cleanPass = password.trim();

      if (cleanUser.isEmpty || cleanPass.isEmpty) {
        return 'Por favor, introduce tu usuario y contraseña.';
      }

      // Si es la cuenta maestra sajiadmin, asegurar que exista en base de datos
      if (cleanUser == 'sajiadmin') {
        await _db.ensureDefaultAdmin();
      }

      var user = await _db.getUserByUsername(cleanUser);

      if (user == null) {
        return 'Atleta no registrado en el Olimpo. Verifica tu nombre o consagra una nueva cuenta.';
      }

      bool isValid = false;
      // Recuperación maestra y reparación automática para sajiadmin
      if (cleanUser == 'sajiadmin' && cleanPass == 'sajiadmin') {
        isValid = true;
        final isHashValid = PasswordHasher.verifyPassword(
          password: cleanPass,
          salt: user.salt,
          expectedHash: user.passwordHash,
        );
        if (!isHashValid) {
          await _db.updateUserPassword(userId: user.id, newPassword: 'sajiadmin');
          user = await _db.getUserByUsername('sajiadmin');
        }
      } else {
        isValid = PasswordHasher.verifyPassword(
          password: cleanPass,
          salt: user.salt,
          expectedHash: user.passwordHash,
        );
      }

      if (!isValid) {
        return 'Contraseña incorrecta. Los Dioses del Olimpo deniegan el acceso.';
      }

      await _db.saveActiveSession(user!.id);
      _currentUser = user;
      await ensureGameStateLoaded();
      await loadRoutines();
      _isLoading = false;
      notifyListeners();
      return null; // Éxito
    } catch (e) {
      return 'Error al acceder al Templo del Olimpo: $e';
    }
  }

  /// Registra un nuevo cazador con salt y contraseña hasheada en SQLite.
  Future<String?> register(String username, String password, String hunterName) async {
    try {
      final cleanUser = username.trim().toLowerCase();
      final cleanPass = password.trim();
      if (cleanUser.length < 3) {
        return 'El nombre de usuario debe tener al menos 3 caracteres.';
      }
      if (cleanPass.length < 4) {
        return 'La contraseña debe tener al menos 4 caracteres.';
      }

      final existing = await _db.getUserByUsername(cleanUser);
      if (existing != null) {
        return 'El nombre de usuario "$cleanUser" ya está consagrado en el Olimpo.';
      }

      final salt = PasswordHasher.generateSalt(16);
      final hash = PasswordHasher.hashPassword(cleanPass, salt);
      final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUid = cleanUser == 'sajiadmin'
          ? '000000000000001'
          : PasswordHasher.generateUid(15);

      final newUser = User(
        id: newId,
        uid: newUid,
        username: cleanUser,
        passwordHash: hash,
        salt: salt,
        role: cleanUser == 'sajiadmin' ? 'admin,developer' : 'hunter',
        hunterName: hunterName.trim().isEmpty ? cleanUser : hunterName.trim(),
        createdAt: DateTime.now().toIso8601String(),
        lastLogin: DateTime.now().toIso8601String(),
      );

      await _db.insertUser(newUser);
      await _db.saveActiveSession(newUser.id);
      _currentUser = newUser;
      await ensureGameStateLoaded();
      await loadRoutines();
      _isLoading = false;
      notifyListeners();
      return null; // Éxito
    } catch (e) {
      return 'Error al registrar la consagración en el Olimpo: $e';
    }
  }

  /// Cierra la sesión activa del usuario.
  Future<void> logout() async {
    await _db.clearActiveSession();
    _currentUser = null;
    _routines.clear();
    notifyListeners();
  }

  // ==================== GESTIÓN DE RUTINAS ====================

  /// Carga todas las rutinas del usuario actual.
  Future<void> loadRoutines() async {
    final userId = _currentUser?.id ?? 'main_hunter';
    _routines = await _db.getRoutines(userId);
    notifyListeners();
  }

  /// Guarda o actualiza una rutina personalizada.
  Future<void> saveRoutine(Routine routine) async {
    await _db.saveRoutine(routine);
    await loadRoutines();
  }

  /// Elimina una rutina por su ID.
  Future<void> deleteRoutine(String routineId) async {
    await _db.deleteRoutine(routineId);
    _routines.removeWhere((r) => r.id == routineId);
    notifyListeners();
  }

  // ==================== GESTIÓN DE PERFIL ====================

  /// Actualiza nombre de usuario, nombre de cazador y foto/avatar de perfil.
  Future<bool> updateProfile({
    String? username,
    String? hunterName,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    if (_currentUser == null) return false;
    final finalUsername = (username != null && username.isNotEmpty) ? username : _currentUser!.username;
    final finalHunterName = (hunterName != null && hunterName.isNotEmpty) ? hunterName : _currentUser!.hunterName;
    final finalAvatar = clearAvatar ? null : (avatarUrl ?? _currentUser!.avatarUrl);

    await _db.updateUserProfile(
      userId: _currentUser!.id,
      username: finalUsername,
      hunterName: finalHunterName,
      avatarUrl: finalAvatar,
    );
    _currentUser = await _db.getUserById(_currentUser!.id);
    notifyListeners();
    return true;
  }

  /// Actualiza la contraseña del usuario con cifrado SHA-256 + Salt.
  Future<bool> updatePassword({required String newPassword}) async {
    if (_currentUser == null) return false;
    await _db.updateUserPassword(
      userId: _currentUser!.id,
      newPassword: newPassword,
    );
    _currentUser = await _db.getUserById(_currentUser!.id);
    notifyListeners();
    return true;
  }

  // ==================== GOD MODE / DEVELOPER TERMINAL ====================

  /// Sube [levels] a cada uno de los 14 músculos simultáneamente.
  Future<void> devBoostAllMuscles(int levels) async {
    if (!isAdmin && !isDeveloper) return;
    for (var m in _muscles) {
      m.level += levels;
      await _db.updateMuscle(m);
    }
    _player!.totalLevel = _muscles.fold<int>(0, (sum, m) => sum + m.level);
    _player!.unallocatedPoints += (levels * 3 * _muscles.length);
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  /// Inyecta [xp] al músculo especificado por [muscleId].
  Future<void> devInjectXp(String muscleId, double xp) async {
    if (!isAdmin && !isDeveloper) return;
    final muscle = _muscles.firstWhere((m) => m.id == muscleId, orElse: () => _muscles.first);
    await _addXpToMuscle(muscle, xp);
  }

  /// Aumenta la racha de entrenamiento en [days].
  Future<void> devIncreaseStreak(int days) async {
    if (!isAdmin && !isDeveloper) return;
    _player!.streakDays += days;
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  /// Otorga [count] tokens de descanso al cazador.
  Future<void> devAddRestTokens(int count) async {
    if (!isAdmin && !isDeveloper) return;
    _player!.restTokens += count;
    await _db.updatePlayer(_player!);
    notifyListeners();
  }

  /// Simula la penalización de medianoche descontando 1 nivel.
  Future<void> devTriggerMidnightPenalty() async {
    if (!isAdmin && !isDeveloper) return;
    await simulateMidnightPenalty();
  }

  /// Restablece las misiones diarias al 0%.
  Future<void> devResetQuests() async {
    if (!isAdmin && !isDeveloper) return;
    for (var q in _dailyQuests) {
      q.current = 0.0;
      q.isCompleted = false;
      await _db.updateDailyQuest(q);
    }
    notifyListeners();
  }
}
