import 'package:flutter_test/flutter_test.dart';
import 'package:olimpia_leveling/models/muscle.dart';
import 'package:olimpia_leveling/models/exercise.dart';
import 'package:olimpia_leveling/models/rank.dart';
import 'package:olimpia_leveling/models/daily_quest.dart';
import 'package:olimpia_leveling/models/player.dart';
import 'package:olimpia_leveling/models/achievement.dart';
import 'package:olimpia_leveling/models/routine.dart';
import 'package:olimpia_leveling/core/calculator/one_rm_calculator.dart';

void main() {
  group('Modelos y Lógica de Olimpia Leveling', () {
    test('Los 8 rangos están en orden correcto de skinnybitch a god of olimpus', () {
      final ranks = RankTier.allRanks;
      expect(ranks.length, 8);
      expect(ranks.first.name, 'SKINNYBITCH');
      expect(ranks.last.name, 'GOD OF OLIMPUS');

      // Check level thresholds
      expect(RankTier.getRankForLevel(4).name, 'SKINNYBITCH');
      expect(RankTier.getRankForLevel(5).name, 'HUMAN');
      expect(RankTier.getRankForLevel(14).name, 'HUMAN');
      expect(RankTier.getRankForLevel(15).name, 'NORMAL GYM BUDDY');
      expect(RankTier.getRankForLevel(29).name, 'NORMAL GYM BUDDY');
      expect(RankTier.getRankForLevel(30).name, 'GYMBRO');
      expect(RankTier.getRankForLevel(49).name, 'GYMBRO');
      expect(RankTier.getRankForLevel(50).name, 'SOLDIER');
      expect(RankTier.getRankForLevel(64).name, 'SOLDIER');
      expect(RankTier.getRankForLevel(65).name, 'SPARTAN');
      expect(RankTier.getRankForLevel(79).name, 'SPARTAN');
      expect(RankTier.getRankForLevel(80).name, 'HERCULES');
      expect(RankTier.getRankForLevel(98).name, 'HERCULES');
      expect(RankTier.getRankForLevel(99).name, 'GOD OF OLIMPUS');
      expect(RankTier.getRankForLevel(100).name, 'GOD OF OLIMPUS');
    });

    test('Cálculo de XP de ejercicio por peso y repeticiones (Press inclinado)', () {
      final inclineBench = Exercise(
        id: 'press_inclinado',
        name: 'Press Inclinado',
        description: 'Deltoides anterior y pecho superior',
        primaryMuscle: 'deltoides',
        primaryXpPerKg: 5.0,
        secondaryMuscle: 'pecho',
        secondaryXpPerKg: 2.0,
        baseXp: 20.0,
      );

      final xp = inclineBench.calculateXp(weightKg: 60.0, reps: 10);
      expect(xp['deltoides'], 320.0);
      expect(xp['pecho'], 130.0);
    });

    test('Fórmula recursiva de XP para subir de nivel (15% compuesto desde nivel 6)', () {
      final m1 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 1);
      expect(m1.xpForNextLevel, 100.0);

      final m2 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 2);
      expect(m2.xpForNextLevel, 200.0);

      final m3 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 3);
      expect(m3.xpForNextLevel, 300.0);

      final m4 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 4);
      expect(m4.xpForNextLevel, 400.0);

      final m5 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 5);
      expect(m5.xpForNextLevel, 1000.0); // Del 5 al 6 hacen falta 1000 XP

      final m6 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 6);
      expect(m6.xpForNextLevel, 1150.0); // 1000 * 1.15

      final m7 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 7);
      expect(m7.xpForNextLevel, 1322.5); // 1150 * 1.15
    });

    test('Multiplicador de racha diaria de XP (7 días -> +5%, 30 días -> +10%)', () {
      final p1 = Player(streakDays: 3, lastActiveDate: '2026-09-14');
      expect(p1.streakXpMultiplier, 1.0);
      expect(p1.streakBonusPercentage, 0);

      final p7 = Player(streakDays: 7, lastActiveDate: '2026-09-14');
      expect(p7.streakXpMultiplier, 1.05);
      expect(p7.streakBonusPercentage, 5);

      final p30 = Player(streakDays: 30, lastActiveDate: '2026-09-14');
      expect(p30.streakXpMultiplier, 1.10);
      expect(p30.streakBonusPercentage, 10);
    });

    test('Misiones diarias seleccionables y comprobación de finalización', () {
      final quest = DailyQuest(
        id: 'q_flex',
        name: '100 Flexiones',
        target: 100.0,
        current: 0.0,
        unit: 'reps',
        isSelected: true,
        date: '2026-09-14',
      );

      expect(quest.isSelected, true);
      expect(quest.isCompleted, false);
      quest.addProgress(50.0);
      expect(quest.current, 50.0);
      expect(quest.isCompleted, false);

      quest.addProgress(50.0);
      expect(quest.current, 100.0);
      expect(quest.isCompleted, true);
    });

    test('Penalización de medianoche descuenta 1 nivel', () {
      final player = Player(
        totalLevel: 5,
        lastActiveDate: '2026-09-13',
      );

      expect(player.rank.name, 'HUMAN');
      player.totalLevel -= 1;
      expect(player.totalLevel, 4);
      expect(player.rank.name, 'SKINNYBITCH');
    });

    test('Logros y títulos mitológicos iniciales cargan correctamente', () {
      final achs = Achievement.getDefaultAchievements();
      expect(achs.length, greaterThanOrEqualTo(6));
      expect(achs.any((a) => a.title == 'El Despanchizado'), true);
      expect(achs.any((a) => a.title == 'Devorador de Hierro'), true);
      expect(achs.any((a) => a.title == 'Dios del Olimpo'), true);
    });

    test('Fórmula de Poder de Combate (Combat Power)', () {
      final player = Player(
        totalLevel: 50,
        strength: 20,
        agility: 15,
        endurance: 18,
        discipline: 25,
        lastActiveDate: '2026-09-14',
      );
      // (50 * 100) + (20 * 15) + (15 * 10) + (18 * 12) + (25 * 8)
      // 5000 + 300 + 150 + 216 + 200 = 5866
      expect(player.combatPower, 5866);
    });

    test('Regla de balance muscular para Mazmorras de Ascenso (-2 rangos)', () {
      // Current rank is 2 (NORMAL GYM BUDDY), targeting rank 3 (GYMBRO).
      // Target rank = 3. Minimum allowed muscle rank = max(0, 3 - 2) = 1 (HUMAN).
      // Muscle with rank 0 (Skinnybitch, level 2) should block ascension!
      final balancedMuscles = [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 15), // Rank 2
        Muscle(id: 'espalda', name: 'Espalda', category: 'back', level: 8), // Rank 1
      ];

      const targetRankIndex = 3;
      final minAllowedRank = (targetRankIndex - 2).clamp(0, 7);
      final lagging = balancedMuscles.where((m) => m.rankIndex < minAllowedRank).toList();
      expect(lagging.isEmpty, true);

      // Now introduce an underdeveloped muscle (rank 0, level 2)
      final unbalancedMuscles = [
        ...balancedMuscles,
        Muscle(id: 'gemelos', name: 'Gemelos', category: 'back', level: 2), // Rank 0
      ];
      final blockedLagging = unbalancedMuscles.where((m) => m.rankIndex < minAllowedRank).toList();
      expect(blockedLagging.length, 1);
      expect(blockedLagging.first.name, 'Gemelos');
    });

    test('Tokens de descanso (Rest Day Tokens) protegen la racha', () {
      final player = Player(
        streakDays: 12,
        restTokens: 2,
        isRestDayUsedToday: false,
        lastActiveDate: '2026-09-14',
      );

      expect(player.restTokens, 2);
      expect(player.isRestDayUsedToday, false);

      // Consume 1 token
      player.restTokens -= 1;
      player.isRestDayUsedToday = true;

      expect(player.restTokens, 1);
      expect(player.isRestDayUsedToday, true);
    });

    test('Estimador Científico de 1RM (Fórmulas de Epley y Brzycki)', () {
      // 1 rep should equal the weight itself
      expect(OneRmCalculator.epley(weight: 100.0, reps: 1), 100.0);
      expect(OneRmCalculator.brzycki(weight: 100.0, reps: 1), 100.0);
      expect(OneRmCalculator.estimate(weight: 100.0, reps: 1), 100.0);

      // 100kg x 10 reps
      // Epley: 100 * (1 + 10/30) = 133.33 kg
      final epley = OneRmCalculator.epley(weight: 100.0, reps: 10);
      expect(epley, closeTo(133.33, 0.05));

      // Brzycki: 100 * (36 / (37 - 10)) = 100 * (36 / 27) = 133.33 kg
      final brzycki = OneRmCalculator.brzycki(weight: 100.0, reps: 10);
      expect(brzycki, closeTo(133.33, 0.05));

      // Estimate average
      final est = OneRmCalculator.estimate(weight: 100.0, reps: 10);
      expect(est, closeTo(133.33, 0.05));
    });

    test('Cálculo de Tonelaje y Detección de Récord Personal (PR)', () {
      final logs = [
        {'weight': 100.0, 'reps': 5}, // 500 kg
        {'weight': 100.0, 'reps': 5}, // 500 kg
        {'weight': 110.0, 'reps': 3}, // 330 kg
      ];

      double totalVolume = 0.0;
      for (var log in logs) {
        totalVolume += (log['weight'] as double) * (log['reps'] as int);
      }
      expect(totalVolume, 1330.0);

      // PR detection check: Previous max was 100kg, new lift is 110kg -> PR detected!
      const previousMax = 100.0;
      const newWeight = 110.0;
      final isNewPr = newWeight > previousMax;
      expect(isNewPr, true);

      // Award +50 XP bonus on PR
      const basePrimaryXp = 320.0;
      const prBonusXp = 50.0;
      final totalAwarded = basePrimaryXp + (isNewPr ? prBonusXp : 0.0);
      expect(totalAwarded, 370.0);
    });

    test('Serialización y deserialización completa de Player (JSON/SQLite)', () {
      final original = Player(
        id: 'main_hunter',
        totalLevel: 35,
        strength: 25,
        agility: 20,
        endurance: 18,
        discipline: 22,
        unallocatedPoints: 5,
        streakDays: 14,
        lastActiveDate: '2026-09-14',
        completedDailyDate: '2026-09-14',
        equippedTitle: 'Hijo de Ares',
        selectedDailyQuestId: 'quest_flexiones',
        restTokens: 3,
        isRestDayUsedToday: true,
      );

      final map = original.toMap();
      expect(map['equipped_title'], 'Hijo de Ares');
      expect(map['selected_daily_quest_id'], 'quest_flexiones');
      expect(map['rest_tokens'], 3);
      expect(map['is_rest_day_used_today'], 1);

      final deserialized = Player.fromMap(map);
      expect(deserialized.equippedTitle, 'Hijo de Ares');
      expect(deserialized.selectedDailyQuestId, 'quest_flexiones');
      expect(deserialized.restTokens, 3);
      expect(deserialized.isRestDayUsedToday, true);
      expect(deserialized.totalLevel, 35);
      expect(deserialized.combatPower, original.combatPower);
    });

    test('Serialización y deserialización de DailyQuest con is_selected', () {
      final quest = DailyQuest(
        id: 'quest_1',
        name: '100 Sentadillas',
        target: 100.0,
        current: 75.0,
        unit: 'reps',
        isCompleted: false,
        isSelected: true,
        date: '2026-09-14',
      );

      final map = quest.toMap();
      expect(map['is_selected'], 1);
      expect(map['is_completed'], 0);

      final restored = DailyQuest.fromMap(map);
      expect(restored.isSelected, true);
      expect(restored.isCompleted, false);
      expect(restored.progress, 0.75);
    });

    test('Serialización y copyWith de Muscle', () {
      final muscle = Muscle(
        id: 'deltoides',
        name: 'Deltoides',
        category: 'both',
        level: 10,
        currentXp: 250.0,
      );

      final map = muscle.toMap();
      expect(map['id'], 'deltoides');
      expect(map['level'], 10);

      final restored = Muscle.fromMap(map);
      expect(restored.name, 'Deltoides');
      expect(restored.rankIndex, 1); // HUMAN
      expect(restored.rankName, 'HUMAN');

      final copied = muscle.copyWith(level: 15);
      expect(copied.level, 15);
      expect(copied.rankIndex, 2); // NORMAL GYM BUDDY
    });

    test('RankTier.getRankForHunterLevel escala de nivel 0 a 100 con God of Olimpus en 99-100', () {
      expect(RankTier.getRankForHunterLevel(0).name, 'SKINNYBITCH');
      expect(RankTier.getRankForHunterLevel(4).name, 'SKINNYBITCH');
      expect(RankTier.getRankForHunterLevel(5).name, 'HUMAN');
      expect(RankTier.getRankForHunterLevel(14).name, 'HUMAN');
      expect(RankTier.getRankForHunterLevel(15).name, 'NORMAL GYM BUDDY');
      expect(RankTier.getRankForHunterLevel(29).name, 'NORMAL GYM BUDDY');
      expect(RankTier.getRankForHunterLevel(30).name, 'GYMBRO');
      expect(RankTier.getRankForHunterLevel(49).name, 'GYMBRO');
      expect(RankTier.getRankForHunterLevel(50).name, 'SOLDIER');
      expect(RankTier.getRankForHunterLevel(64).name, 'SOLDIER');
      expect(RankTier.getRankForHunterLevel(65).name, 'SPARTAN');
      expect(RankTier.getRankForHunterLevel(79).name, 'SPARTAN');
      expect(RankTier.getRankForHunterLevel(80).name, 'HERCULES');
      expect(RankTier.getRankForHunterLevel(98).name, 'HERCULES');
      expect(RankTier.getRankForHunterLevel(99).name, 'GOD OF OLIMPUS');
      expect(RankTier.getRankForHunterLevel(100).name, 'GOD OF OLIMPUS');
    });

    test('Niveles de prueba física semanal de ascenso (4, 14, 29, 49, 64, 79, 98)', () {
      expect(RankTier.isTrialLevel(4), true);
      expect(RankTier.isTrialLevel(14), true);
      expect(RankTier.isTrialLevel(29), true);
      expect(RankTier.isTrialLevel(49), true);
      expect(RankTier.isTrialLevel(64), true);
      expect(RankTier.isTrialLevel(79), true);
      expect(RankTier.isTrialLevel(98), true);

      // Niveles no prueba
      expect(RankTier.isTrialLevel(0), false);
      expect(RankTier.isTrialLevel(5), false);
      expect(RankTier.isTrialLevel(15), false);
      expect(RankTier.isTrialLevel(30), false);
      expect(RankTier.isTrialLevel(99), false);
      expect(RankTier.isTrialLevel(100), false);
    });

    test('Nivel 99 a 100 requiere 20 veces más XP que nivel 98 a 99', () {
      final m98 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 98);
      final xp98 = m98.xpForNextLevel;

      final m99 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 99);
      final xp99 = m99.xpForNextLevel;

      expect(xp99, closeTo(xp98 * 20.0, 0.01));

      final m100 = Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 100);
      expect(m100.xpForNextLevel, 0.0);
    });

    test('Mecánica Drop Set multiplica la XP x2 (1 salto), x3 (2 saltos), x4 (3+ saltos)', () {
      final exercise = Exercise(
        id: 'curl_biceps',
        name: 'Curl Bíceps',
        description: 'Aislamiento de bíceps',
        primaryMuscle: 'biceps',
        primaryXpPerKg: 5.0,
        baseXp: 20.0,
      );
      // Base: (30 * 5 * 10)/10 + 20 = 150 + 20 = 170
      final xp0 = exercise.calculateXp(weightKg: 30, reps: 10, dropsetDrops: 0);
      expect(xp0['biceps'], 170.0);

      final xp1 = exercise.calculateXp(weightKg: 30, reps: 10, dropsetDrops: 1);
      expect(xp1['biceps'], 340.0); // 170 * 2

      final xp2 = exercise.calculateXp(weightKg: 30, reps: 10, dropsetDrops: 2);
      expect(xp2['biceps'], 510.0); // 170 * 3

      final xp3 = exercise.calculateXp(weightKg: 30, reps: 10, dropsetDrops: 3);
      expect(xp3['biceps'], 680.0); // 170 * 4

      final xp5 = exercise.calculateXp(weightKg: 30, reps: 10, dropsetDrops: 5);
      expect(xp5['biceps'], 680.0); // Capped at max 4x
    });

    test('Ejercicio con hasta 4 músculos distribuye XP correctamente a todos ellos', () {
      final multiExercise = Exercise(
        id: 'clean_and_press',
        name: 'Clean and Press',
        description: 'Movimiento compuesto olímpico completo',
        primaryMuscle: 'deltoides',
        primaryXpPerKg: 4.0,
        tips: 'Mantén la espalda recta y el core activado.',
        imageUrl: 'https://images.unsplash.com/photo-example.jpg',
        gifUrl: 'https://media.giphy.com/media/example/giphy.gif',
        youtubeUrl: 'https://www.youtube.com/watch?v=example',
        musclesXp: [
          MuscleXpEntry(muscle: 'deltoides', xp: 4.0),
          MuscleXpEntry(muscle: 'trapecio', xp: 3.0),
          MuscleXpEntry(muscle: 'cuadriceps', xp: 3.5),
          MuscleXpEntry(muscle: 'lumbares', xp: 2.5),
        ],
        baseXp: 30.0,
      );

      final xp = multiExercise.calculateXp(weightKg: 50.0, reps: 10);
      expect(xp.length, 4);
      // deltoides (primario): (50 * 4.0 * 10) / 10 + 30 = 200 + 30 = 230
      expect(xp['deltoides'], 230.0);
      // trapecio (secundario, base/2 = 15): (50 * 3.0 * 10) / 10 + 15 = 150 + 15 = 165
      expect(xp['trapecio'], 165.0);
      // cuadriceps (secundario, base/2 = 15): (50 * 3.5 * 10) / 10 + 15 = 175 + 15 = 190
      expect(xp['cuadriceps'], 190.0);
      // lumbares (secundario, base/2 = 15): (50 * 2.5 * 10) / 10 + 15 = 125 + 15 = 140
      expect(xp['lumbares'], 140.0);

      // Verificación de toMap y fromMap
      final map = multiExercise.toMap();
      expect(map['tips'], 'Mantén la espalda recta y el core activado.');
      expect(map['youtube_url'], 'https://www.youtube.com/watch?v=example');

      final restored = Exercise.fromMap(map);
      expect(restored.musclesXp.length, 4);
      expect(restored.tips, multiExercise.tips);
      expect(restored.youtubeUrl, multiExercise.youtubeUrl);
    });

    test('Modelo Routine y RoutineExercise serialización y manipulación', () {
      final routine = Routine(
        id: 'dia_pecho_biceps',
        userId: 'admin_1',
        name: 'Día de Pecho y Bíceps',
        createdAt: '2026-09-14T20:00:00Z',
        exercises: [
          RoutineExercise(
            exerciseId: 'press_banca',
            exerciseName: 'Press de Banca',
            primaryMuscle: 'pecho',
            sets: 4,
            targetReps: 10,
            targetWeightKg: 80.0,
            restSeconds: 90,
          ),
          RoutineExercise(
            exerciseId: 'curl_biceps',
            exerciseName: 'Curl de Bíceps',
            primaryMuscle: 'biceps',
            sets: 3,
            targetReps: 12,
            targetWeightKg: 15.0,
            restSeconds: 60,
          ),
        ],
      );

      expect(routine.exercises.length, 2);
      expect(routine.exercises.first.exerciseName, 'Press de Banca');
      expect(routine.exercises.first.restSeconds, 90);

      final map = routine.toMap();
      final restored = Routine.fromMap(map);

      expect(restored.id, 'dia_pecho_biceps');
      expect(restored.userId, 'admin_1');
      expect(restored.name, 'Día de Pecho y Bíceps');
      expect(restored.exercises.length, 2);
      expect(restored.exercises[1].primaryMuscle, 'biceps');
      expect(restored.exercises[1].targetWeightKg, 15.0);
    });
  });
}
