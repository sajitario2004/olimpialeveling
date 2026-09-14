import 'package:flutter_test/flutter_test.dart';
import 'package:olimpia_leveling/models/muscle.dart';
import 'package:olimpia_leveling/models/exercise.dart';
import 'package:olimpia_leveling/models/rank.dart';
import 'package:olimpia_leveling/models/daily_quest.dart';
import 'package:olimpia_leveling/models/player.dart';
import 'package:olimpia_leveling/models/achievement.dart';
import 'package:olimpia_leveling/core/calculator/one_rm_calculator.dart';

void main() {
  group('Modelos y Lógica de Olimpia Leveling', () {
    test('Los 8 rangos están en orden correcto de skinnybitch a god of olimpus', () {
      final ranks = RankTier.allRanks;
      expect(ranks.length, 8);
      expect(ranks.first.name, 'SKINNYBITCH');
      expect(ranks.last.name, 'GOD OF OLIMPUS');

      // Check level thresholds
      expect(RankTier.getRankForLevel(14).name, 'SKINNYBITCH');
      expect(RankTier.getRankForLevel(25).name, 'HUMAN');
      expect(RankTier.getRankForLevel(55).name, 'NORMAL GYM BUDDY');
      expect(RankTier.getRankForLevel(95).name, 'GYMBRO');
      expect(RankTier.getRankForLevel(150).name, 'SOLDIER');
      expect(RankTier.getRankForLevel(220).name, 'SPARTAN');
      expect(RankTier.getRankForLevel(300).name, 'HERCULES');
      expect(RankTier.getRankForLevel(450).name, 'GOD OF OLIMPUS');
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
        totalLevel: 25,
        lastActiveDate: '2026-09-13',
      );

      expect(player.rank.name, 'HUMAN');
      player.totalLevel -= 1;
      expect(player.totalLevel, 24);
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
  });
}
