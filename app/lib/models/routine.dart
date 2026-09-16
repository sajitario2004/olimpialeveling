import 'dart:convert';

/// Configuración de una serie individual dentro de un ejercicio de rutina.
class RoutineSet {
  final int setNumber;
  final double weightKg;
  final int reps;
  final int restSeconds;
  final String setType; // 'normal', 'calentamiento', 'fallo'
  final String notes;

  const RoutineSet({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.restSeconds = 90,
    this.setType = 'normal',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'rest_seconds': restSeconds,
      'set_type': setType,
      'notes': notes,
    };
  }

  factory RoutineSet.fromMap(Map<String, dynamic> map) {
    return RoutineSet(
      setNumber: (map['set_number'] as num?)?.toInt() ?? 1,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 20.0,
      reps: (map['reps'] as num?)?.toInt() ?? 12,
      restSeconds: (map['rest_seconds'] as num?)?.toInt() ?? 90,
      setType: map['set_type'] as String? ?? 'normal',
      notes: map['notes'] as String? ?? '',
    );
  }

  RoutineSet copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    int? restSeconds,
    String? setType,
    String? notes,
  }) {
    return RoutineSet(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      setType: setType ?? this.setType,
      notes: notes ?? this.notes,
    );
  }
}

/// Ejercicio individual configurado dentro de una rutina con soporte para series personalizadas.
class RoutineExercise {
  final String exerciseId;
  final String exerciseName;
  final int _sets;
  final double _targetWeightKg;
  final int _targetReps;
  final int _restSeconds;
  final String primaryMuscle;
  final List<RoutineSet> individualSets;
  final String notes;
  final String? imageUrl;

  const RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    int sets = 3,
    double targetWeightKg = 20.0,
    int targetReps = 12,
    int restSeconds = 90,
    this.primaryMuscle = 'pecho',
    this.individualSets = const [],
    this.notes = '',
    this.imageUrl,
  })  : _sets = sets,
        _targetWeightKg = targetWeightKg,
        _targetReps = targetReps,
        _restSeconds = restSeconds;

  int get sets => individualSets.isNotEmpty ? individualSets.length : _sets;
  double get targetWeightKg => individualSets.isNotEmpty ? individualSets.first.weightKg : _targetWeightKg;
  int get targetReps => individualSets.isNotEmpty ? individualSets.first.reps : _targetReps;
  int get restSeconds => individualSets.isNotEmpty ? individualSets.first.restSeconds : _restSeconds;

  RoutineSet getSet(int setNumber) {
    if (individualSets.isNotEmpty) {
      final index = setNumber - 1;
      if (index >= 0 && index < individualSets.length) {
        return individualSets[index];
      }
    }
    return RoutineSet(
      setNumber: setNumber,
      weightKg: targetWeightKg,
      reps: targetReps,
      restSeconds: restSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    final setsList = individualSets.isNotEmpty
        ? individualSets
        : List.generate(
            sets,
            (i) => RoutineSet(
              setNumber: i + 1,
              weightKg: targetWeightKg,
              reps: targetReps,
              restSeconds: restSeconds,
            ),
          );

    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': setsList.length,
      'target_weight_kg': setsList.isNotEmpty ? setsList.first.weightKg : targetWeightKg,
      'target_reps': setsList.isNotEmpty ? setsList.first.reps : targetReps,
      'rest_seconds': setsList.isNotEmpty ? setsList.first.restSeconds : restSeconds,
      'primary_muscle': primaryMuscle,
      'individual_sets': setsList.map((s) => s.toMap()).toList(),
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    final setsCount = (map['sets'] as num?)?.toInt() ?? 3;
    final defaultWeight = (map['target_weight_kg'] as num?)?.toDouble() ?? 20.0;
    final defaultReps = (map['target_reps'] as num?)?.toInt() ?? 12;
    final defaultRest = (map['rest_seconds'] as num?)?.toInt() ?? 90;

    List<RoutineSet> setsList = [];
    if (map['individual_sets'] != null) {
      try {
        final decodedSets = map['individual_sets'] as List;
        setsList = decodedSets
            .map((s) => RoutineSet.fromMap(Map<String, dynamic>.from(s)))
            .toList();
      } catch (_) {}
    }

    if (setsList.isEmpty) {
      setsList = List.generate(
        setsCount,
        (i) => RoutineSet(
          setNumber: i + 1,
          weightKg: defaultWeight,
          reps: defaultReps,
          restSeconds: defaultRest,
        ),
      );
    }

    return RoutineExercise(
      exerciseId: map['exercise_id'] ?? '',
      exerciseName: map['exercise_name'] ?? 'Ejercicio',
      sets: setsList.length,
      targetWeightKg: setsList.isNotEmpty ? setsList.first.weightKg : defaultWeight,
      targetReps: setsList.isNotEmpty ? setsList.first.reps : defaultReps,
      restSeconds: setsList.isNotEmpty ? setsList.first.restSeconds : defaultRest,
      primaryMuscle: map['primary_muscle'] ?? 'pecho',
      individualSets: setsList,
      notes: map['notes'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
    );
  }

  RoutineExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? sets,
    double? targetWeightKg,
    int? targetReps,
    int? restSeconds,
    String? primaryMuscle,
    List<RoutineSet>? individualSets,
    String? notes,
    String? imageUrl,
  }) {
    final newSets = individualSets ?? this.individualSets;
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: newSets.isNotEmpty ? newSets.length : (sets ?? this.sets),
      targetWeightKg: newSets.isNotEmpty ? newSets.first.weightKg : (targetWeightKg ?? this.targetWeightKg),
      targetReps: newSets.isNotEmpty ? newSets.first.reps : (targetReps ?? this.targetReps),
      restSeconds: newSets.isNotEmpty ? newSets.first.restSeconds : (restSeconds ?? this.restSeconds),
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      individualSets: newSets,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Rutina completa creada por el usuario (ej: "Día de Pecho", "Día de Pierna").
class Routine {
  final String id;
  final String userId;
  final String name;
  final List<RoutineExercise> exercises;
  final String createdAt;

  const Routine({
    required this.id,
    required this.userId,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'exercises_json': jsonEncode(exercises.map((e) => e.toMap()).toList()),
      'created_at': createdAt,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    List<RoutineExercise> exList = [];
    if (map['exercises_json'] != null) {
      try {
        final decoded = jsonDecode(map['exercises_json'] as String) as List;
        exList = decoded
            .map((e) => RoutineExercise.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    return Routine(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'main_hunter',
      name: map['name'] as String,
      exercises: exList,
      createdAt: map['created_at'] as String,
    );
  }

  Routine copyWith({
    String? id,
    String? userId,
    String? name,
    List<RoutineExercise>? exercises,
    String? createdAt,
  }) {
    return Routine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
