import 'dart:convert';

/// Ejercicio individual configurado dentro de una rutina.
class RoutineExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final double targetWeightKg;
  final int targetReps;
  final int restSeconds;
  final String primaryMuscle;

  const RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.sets = 3,
    this.targetWeightKg = 20.0,
    this.targetReps = 12,
    this.restSeconds = 90,
    this.primaryMuscle = 'pecho',
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets,
      'target_weight_kg': targetWeightKg,
      'target_reps': targetReps,
      'rest_seconds': restSeconds,
      'primary_muscle': primaryMuscle,
    };
  }

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      exerciseId: map['exercise_id'] ?? '',
      exerciseName: map['exercise_name'] ?? 'Ejercicio',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble() ?? 20.0,
      targetReps: (map['target_reps'] as num?)?.toInt() ?? 12,
      restSeconds: (map['rest_seconds'] as num?)?.toInt() ?? 90,
      primaryMuscle: map['primary_muscle'] ?? 'pecho',
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
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
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
