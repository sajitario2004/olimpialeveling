import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/muscle.dart';
import '../../models/exercise.dart';
import '../../models/player.dart';
import '../../models/daily_quest.dart';
import '../../models/user.dart';
import '../../models/routine.dart';
import '../security/password_hasher.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('olimpia_leveling.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (io.Platform.isMacOS || io.Platform.isLinux || io.Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  static Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (_) {
      // La columna ya existe
    }
  }

  Future<void> _createAuthTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        uid TEXT UNIQUE,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'hunter',
        hunter_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_login TEXT,
        avatar_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS auth_sessions (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        logged_in_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedDefaultAdmin(Database db) async {
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['sajiadmin'],
    );
    if (existing.isEmpty) {
      final salt = PasswordHasher.generateSalt(16);
      final hash = PasswordHasher.hashPassword('sajiadmin', salt);
      await db.insert('users', {
        'id': 'user_sajiadmin_root',
        'uid': '000000000000001',
        'username': 'sajiadmin',
        'password_hash': hash,
        'salt': salt,
        'role': 'admin,developer',
        'hunter_name': 'Saji (Arquitecto del Olimpo)',
        'created_at': DateTime.now().toIso8601String(),
        'last_login': null,
        'avatar_url': null,
      });
    }
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'players', 'equipped_title', 'TEXT');
      await _addColumnIfNotExists(db, 'players', 'selected_daily_quest_id', 'TEXT');
      await _addColumnIfNotExists(db, 'players', 'rest_tokens', 'INTEGER NOT NULL DEFAULT 1');
      await _addColumnIfNotExists(db, 'players', 'is_rest_day_used_today', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfNotExists(db, 'daily_quests', 'is_selected', 'INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await _createAuthTables(db);
      await _seedDefaultAdmin(db);
    }
    if (oldVersion < 4) {
      await _addColumnIfNotExists(db, 'users', 'avatar_url', 'TEXT');
      await _addColumnIfNotExists(db, 'exercises', 'tips', 'TEXT');
      await _addColumnIfNotExists(db, 'exercises', 'image_url', 'TEXT');
      await _addColumnIfNotExists(db, 'exercises', 'gif_url', 'TEXT');
      await _addColumnIfNotExists(db, 'exercises', 'youtube_url', 'TEXT');
      await _addColumnIfNotExists(db, 'exercises', 'muscles_xp_json', 'TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS routines (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          exercises_json TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      await _addColumnIfNotExists(db, 'users', 'uid', 'TEXT');
      await db.execute("UPDATE users SET uid = '000000000000001' WHERE username = 'sajiadmin' AND (uid IS NULL OR uid = '')");
      await _addColumnIfNotExists(db, 'players', 'has_completed_supreme_trial', 'INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await _createAuthTables(db);
    await _seedDefaultAdmin(db);

    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        total_level INTEGER NOT NULL,
        strength INTEGER NOT NULL,
        agility INTEGER NOT NULL,
        endurance INTEGER NOT NULL,
        discipline INTEGER NOT NULL,
        unallocated_points INTEGER NOT NULL,
        streak_days INTEGER NOT NULL,
        last_active_date TEXT NOT NULL,
        completed_daily_date TEXT,
        equipped_title TEXT,
        selected_daily_quest_id TEXT,
        rest_tokens INTEGER NOT NULL DEFAULT 1,
        is_rest_day_used_today INTEGER NOT NULL DEFAULT 0,
        has_completed_supreme_trial INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE muscles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        level INTEGER NOT NULL,
        current_xp REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        tips TEXT,
        primary_muscle TEXT NOT NULL,
        primary_xp_per_kg REAL NOT NULL,
        secondary_muscle TEXT,
        secondary_xp_per_kg REAL,
        base_xp REAL NOT NULL,
        image_url TEXT,
        gif_url TEXT,
        youtube_url TEXT,
        muscles_xp_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        exercises_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_quests (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target REAL NOT NULL,
        current REAL NOT NULL,
        unit TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        is_selected INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        xp_awarded REAL NOT NULL,
        muscle_id TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final nowStr = DateTime.now().toIso8601String().split('T')[0];
    
    // Seed initial player
    final initialPlayer = Player(
      id: 'main_hunter',
      totalLevel: 14, // 14 muscles at level 1
      strength: 10,
      agility: 10,
      endurance: 10,
      discipline: 10,
      unallocatedPoints: 0,
      streakDays: 1,
      lastActiveDate: nowStr,
    );
    await db.insert('players', initialPlayer.toMap());

    // Seed the 14 muscles
    final defaultMuscles = [
      Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 1),
      Muscle(id: 'triceps', name: 'Tríceps', category: 'back', level: 1),
      Muscle(id: 'biceps', name: 'Bíceps', category: 'front', level: 1),
      Muscle(id: 'antebrazo', name: 'Antebrazo', category: 'front', level: 1),
      Muscle(id: 'dorsales', name: 'Dorsales', category: 'back', level: 1),
      Muscle(id: 'trapecio', name: 'Trapecio', category: 'back', level: 1),
      Muscle(id: 'lumbar', name: 'Lumbar', category: 'back', level: 1),
      Muscle(id: 'deltoides', name: 'Deltoides', category: 'both', level: 1),
      Muscle(id: 'cuadriceps', name: 'Cuádriceps', category: 'front', level: 1),
      Muscle(id: 'isquiotibiales', name: 'Isquiotibiales', category: 'back', level: 1),
      Muscle(id: 'gluteos', name: 'Glúteos', category: 'back', level: 1),
      Muscle(id: 'gemelos', name: 'Gemelos', category: 'both', level: 1),
      Muscle(id: 'abdominales', name: 'Abdominales', category: 'front', level: 1),
      Muscle(id: 'oblicuos', name: 'Oblicuos', category: 'front', level: 1),
    ];

    for (var m in defaultMuscles) {
      await db.insert('muscles', m.toMap());
    }

    // Seed default exercises
    final defaultExercises = [
      Exercise(
        id: 'press_inclinado',
        name: 'Press Inclinado con Barra / Mancuernas',
        description: 'Deltoides anterior y parte superior del pecho',
        primaryMuscle: 'deltoides',
        primaryXpPerKg: 5.0,
        secondaryMuscle: 'pecho',
        secondaryXpPerKg: 2.0,
        baseXp: 20.0,
      ),
      Exercise(
        id: 'press_banca_plano',
        name: 'Press de Banca Plano',
        description: 'Masa pectoral completa y tríceps',
        primaryMuscle: 'pecho',
        primaryXpPerKg: 5.0,
        secondaryMuscle: 'triceps',
        secondaryXpPerKg: 2.0,
        baseXp: 25.0,
      ),
      Exercise(
        id: 'dominadas',
        name: 'Dominadas Pronas / Neutras',
        description: 'Tracción vertical y bíceps',
        primaryMuscle: 'dorsales',
        primaryXpPerKg: 4.0,
        secondaryMuscle: 'biceps',
        secondaryXpPerKg: 2.5,
        baseXp: 30.0,
      ),
      Exercise(
        id: 'sentadilla',
        name: 'Sentadilla Trasera',
        description: 'Potencia de cuádriceps y glúteos',
        primaryMuscle: 'cuadriceps',
        primaryXpPerKg: 5.0,
        secondaryMuscle: 'gluteos',
        secondaryXpPerKg: 3.0,
        baseXp: 30.0,
      ),
      Exercise(
        id: 'peso_muerto',
        name: 'Peso Muerto Convencional',
        description: 'Cadena posterior: lumbar e isquios',
        primaryMuscle: 'lumbar',
        primaryXpPerKg: 4.0,
        secondaryMuscle: 'isquiotibiales',
        secondaryXpPerKg: 3.0,
        baseXp: 35.0,
      ),
      Exercise(
        id: 'curl_biceps',
        name: 'Curl de Bíceps',
        description: 'Aislamiento de brazos y flexores',
        primaryMuscle: 'biceps',
        primaryXpPerKg: 6.0,
        secondaryMuscle: 'antebrazo',
        secondaryXpPerKg: 2.5,
        baseXp: 15.0,
      ),
      Exercise(
        id: 'fondos_paralelas',
        name: 'Fondos en Paralelas (Dips)',
        description: 'Tríceps y pectoral inferior',
        primaryMuscle: 'triceps',
        primaryXpPerKg: 4.5,
        secondaryMuscle: 'pecho',
        secondaryXpPerKg: 2.5,
        baseXp: 25.0,
      ),
      Exercise(
        id: 'elevaciones_laterales',
        name: 'Elevaciones Laterales',
        description: 'Deltoides lateral para hombros 3D',
        primaryMuscle: 'deltoides',
        primaryXpPerKg: 7.0,
        secondaryMuscle: 'trapecio',
        secondaryXpPerKg: 1.5,
        baseXp: 15.0,
      ),
      Exercise(
        id: 'crunch_abdominal',
        name: 'Crunch Abdominal / Rueda',
        description: 'Fuerza de core y recto abdominal',
        primaryMuscle: 'abdominales',
        primaryXpPerKg: 4.0,
        secondaryMuscle: 'oblicuos',
        secondaryXpPerKg: 2.0,
        baseXp: 15.0,
      ),
      Exercise(
        id: 'elevacion_talones',
        name: 'Elevación de Talones de Pie',
        description: 'Pantorrillas y gemelos',
        primaryMuscle: 'gemelos',
        primaryXpPerKg: 4.0,
        secondaryMuscle: 'antebrazo',
        secondaryXpPerKg: 0.5,
        baseXp: 15.0,
      ),
    ];

    for (var ex in defaultExercises) {
      await db.insert('exercises', ex.toMap());
    }
  }

  // --- CRUD METHODS ---

  Future<Player> getPlayer() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players', where: 'id = ?', whereArgs: ['main_hunter']);
    if (maps.isNotEmpty) {
      return Player.fromMap(maps.first);
    }
    final defaultPlayer = Player(id: 'main_hunter', totalLevel: 14, lastActiveDate: DateTime.now().toIso8601String().split('T')[0]);
    await db.insert('players', defaultPlayer.toMap());
    return defaultPlayer;
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update('players', player.toMap(), where: 'id = ?', whereArgs: [player.id]);
  }

  Future<List<Muscle>> getAllMuscles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('muscles');
    return maps.map((m) => Muscle.fromMap(m)).toList();
  }

  Future<void> updateMuscle(Muscle muscle) async {
    final db = await database;
    await db.update('muscles', muscle.toMap(), where: 'id = ?', whereArgs: [muscle.id]);
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return maps.map((e) => Exercise.fromMap(e)).toList();
  }

  Future<List<Exercise>> getExercisesForMuscle(String muscleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'primary_muscle = ? OR secondary_muscle = ?',
      whereArgs: [muscleId, muscleId],
    );
    return maps.map((e) => Exercise.fromMap(e)).toList();
  }

  Future<List<DailyQuest>> getDailyQuestsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('daily_quests', where: 'date = ?', whereArgs: [date]);
    return maps.map((q) => DailyQuest.fromMap(q)).toList();
  }

  Future<void> insertDailyQuests(List<DailyQuest> quests) async {
    final db = await database;
    final batch = db.batch();
    for (var q in quests) {
      batch.insert('daily_quests', q.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateDailyQuest(DailyQuest quest) async {
    final db = await database;
    await db.update('daily_quests', quest.toMap(), where: 'id = ?', whereArgs: [quest.id]);
  }

  Future<void> logWorkout({
    required String exerciseId,
    required double weight,
    required int reps,
    required double xpAwarded,
    required String muscleId,
  }) async {
    final db = await database;
    await db.insert('workout_logs', {
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'xp_awarded': xpAwarded,
      'muscle_id': muscleId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<double> getMaxWeightForExercise(String exerciseId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(weight) as max_weight FROM workout_logs WHERE exercise_id = ?',
      [exerciseId],
    );
    if (result.isNotEmpty && result.first['max_weight'] != null) {
      return (result.first['max_weight'] as num).toDouble();
    }
    return 0.0;
  }

  /// Obtiene un mapa con todos los récords personales (ejercicio_id -> max_weight).
  Future<Map<String, double>> getAllPersonalRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT exercise_id, MAX(weight) as max_weight FROM workout_logs GROUP BY exercise_id',
    );
    final Map<String, double> prMap = {};
    for (final row in result) {
      final exId = row['exercise_id'] as String?;
      final maxWeight = (row['max_weight'] as num?)?.toDouble();
      if (exId != null && maxWeight != null) {
        prMap[exId] = maxWeight;
      }
    }
    return prMap;
  }

  /// Permite al desarrollador establecer o modificar directamente un récord personal.
  Future<void> devSetPersonalRecord(String exerciseId, double weightKg) async {
    final db = await database;
    // Si se quiere reducir o cambiar el PR, borramos los registros que superen este nuevo récord
    await db.delete(
      'workout_logs',
      where: 'exercise_id = ? AND weight > ?',
      whereArgs: [exerciseId, weightKg],
    );
    // Insertamos una marca de referencia con el nuevo récord
    await db.insert('workout_logs', {
      'exercise_id': exerciseId,
      'weight': weightKg,
      'reps': 1,
      'xp_awarded': 0.0,
      'muscle_id': 'pecho',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getWorkoutLogs({int limit = 50}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT w.*, e.name as exercise_name, m.name as muscle_name 
      FROM workout_logs w
      LEFT JOIN exercises e ON w.exercise_id = e.id
      LEFT JOIN muscles m ON w.muscle_id = m.id
      ORDER BY w.id DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<double> getTodayVolume(String datePrefix) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(weight * reps) as total_volume FROM workout_logs WHERE timestamp LIKE ?',
      ['$datePrefix%'],
    );
    if (result.isNotEmpty && result.first['total_volume'] != null) {
      return (result.first['total_volume'] as num).toDouble();
    }
    return 0.0;
  }

  // ==================== GESTIÓN DE USUARIOS Y AUTENTICACIÓN ====================

  /// Busca un usuario por su nombre de usuario (case-insensitive).
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'LOWER(username) = LOWER(?)',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Busca un usuario por su ID único.
  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Registra un nuevo usuario en la base de datos.
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  /// Actualiza la fecha de último inicio de sesión del usuario.
  Future<void> updateLastLogin(String userId) async {
    final db = await database;
    await db.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Guarda la sesión activa en la tabla de auth_sessions (solo 1 sesión activa).
  Future<void> saveActiveSession(String userId) async {
    final db = await database;
    await db.delete('auth_sessions');
    await db.insert('auth_sessions', {
      'user_id': userId,
      'logged_in_at': DateTime.now().toIso8601String(),
    });
    await updateLastLogin(userId);
  }

  /// Obtiene el usuario de la sesión activa, si existe.
  Future<User?> getActiveSessionUser() async {
    final db = await database;
    final sessions = await db.query('auth_sessions', limit: 1);
    if (sessions.isNotEmpty) {
      final userId = sessions.first['user_id'] as String;
      return await getUserById(userId);
    }
    return null;
  }

  /// Cierra la sesión activa borrando los registros de auth_sessions.
  Future<void> clearActiveSession() async {
    final db = await database;
    await db.delete('auth_sessions');
  }

  /// Obtiene las rutinas guardadas de un usuario.
  Future<List<Routine>> getRoutines(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routines',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Routine.fromMap(m)).toList();
  }

  /// Guarda una nueva rutina o reemplaza una existente.
  Future<void> saveRoutine(Routine routine) async {
    final db = await database;
    await db.insert(
      'routines',
      routine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Elimina una rutina por su ID.
  Future<void> deleteRoutine(String routineId) async {
    final db = await database;
    await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [routineId],
    );
  }

  /// Actualiza los datos de perfil de usuario (nombre de usuario, nombre de cazador y avatar).
  Future<void> updateUserProfile({
    required String userId,
    required String username,
    required String hunterName,
    String? avatarUrl,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'username': username,
        'hunter_name': hunterName,
        if (avatarUrl != null) ...{'avatar_url': avatarUrl},
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Actualiza la contraseña del usuario cifrándola con un nuevo salt criptográfico.
  Future<void> updateUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    final db = await database;
    final salt = PasswordHasher.generateSalt(16);
    final hash = PasswordHasher.hashPassword(newPassword, salt);
    await db.update(
      'users',
      {
        'password_hash': hash,
        'salt': salt,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
