import 'rank.dart';

class Player {
  final String id;
  int totalLevel;
  int strength;
  int agility;
  int endurance;
  int discipline;
  int unallocatedPoints;
  int streakDays;
  String lastActiveDate;
  String? completedDailyDate;
  String? equippedTitle;
  String? selectedDailyQuestId;
  int restTokens;
  bool isRestDayUsedToday;
  bool hasCompletedSupremeTrial;

  Player({
    this.id = 'main_hunter',
    this.totalLevel = 14, // 14 muscles at level 1 each
    this.strength = 10,
    this.agility = 10,
    this.endurance = 10,
    this.discipline = 10,
    this.unallocatedPoints = 0,
    this.streakDays = 1,
    required this.lastActiveDate,
    this.completedDailyDate,
    this.equippedTitle,
    this.selectedDailyQuestId,
    this.restTokens = 1,
    this.isRestDayUsedToday = false,
    this.hasCompletedSupremeTrial = false,
  });

  RankTier get rank => RankTier.getRankForLevel(
        totalLevel,
        hasCompletedSupremeTrial: hasCompletedSupremeTrial,
      );

  int get rankIndex {
    final currentRank = rank;
    return RankTier.allRanks.indexWhere((r) => r.id == currentRank.id).clamp(0, 7);
  }

  /// Poder de Combate (Combat Power - CP) calculado a partir de nivel y atributos
  int get combatPower {
    return (totalLevel * 100) + (strength * 15) + (agility * 10) + (endurance * 12) + (discipline * 8);
  }

  /// Multiplicador de XP por racha continuada (7 días -> +5%, 30 días -> +10%)
  double get streakXpMultiplier {
    if (streakDays >= 30) return 1.10;
    if (streakDays >= 7) return 1.05;
    return 1.0;
  }

  int get streakBonusPercentage {
    if (streakDays >= 30) return 10;
    if (streakDays >= 7) return 5;
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_level': totalLevel,
      'strength': strength,
      'agility': agility,
      'endurance': endurance,
      'discipline': discipline,
      'unallocated_points': unallocatedPoints,
      'streak_days': streakDays,
      'last_active_date': lastActiveDate,
      'completed_daily_date': completedDailyDate,
      'equipped_title': equippedTitle,
      'selected_daily_quest_id': selectedDailyQuestId,
      'rest_tokens': restTokens,
      'is_rest_day_used_today': isRestDayUsedToday ? 1 : 0,
      'has_completed_supreme_trial': hasCompletedSupremeTrial ? 1 : 0,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] ?? 'main_hunter',
      totalLevel: map['total_level'] ?? 14,
      strength: map['strength'] ?? 10,
      agility: map['agility'] ?? 10,
      endurance: map['endurance'] ?? 10,
      discipline: map['discipline'] ?? 10,
      unallocatedPoints: map['unallocated_points'] ?? 0,
      streakDays: map['streak_days'] ?? 1,
      lastActiveDate: map['last_active_date'] ?? DateTime.now().toIso8601String().split('T')[0],
      completedDailyDate: map['completed_daily_date'],
      equippedTitle: map['equipped_title'],
      selectedDailyQuestId: map['selected_daily_quest_id'],
      restTokens: map['rest_tokens'] ?? 1,
      isRestDayUsedToday: (map['is_rest_day_used_today'] == 1 || map['is_rest_day_used_today'] == true),
      hasCompletedSupremeTrial: (map['has_completed_supreme_trial'] == 1 || map['has_completed_supreme_trial'] == true),
    );
  }
}
