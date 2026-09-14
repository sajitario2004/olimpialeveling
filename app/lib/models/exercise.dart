class Exercise {
  final String id;
  final String name;
  final String description;
  final String primaryMuscle;
  final double primaryXpPerKg;
  final String? secondaryMuscle;
  final double? secondaryXpPerKg;
  final double baseXp;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscle,
    required this.primaryXpPerKg,
    this.secondaryMuscle,
    this.secondaryXpPerKg,
    this.baseXp = 20.0,
  });

  Map<String, double> calculateXp({required double weightKg, required int reps}) {
    final primXp = (weightKg * primaryXpPerKg * reps) / 10.0 + baseXp;
    final Map<String, double> result = {
      primaryMuscle: double.parse(primXp.toStringAsFixed(1)),
    };

    if (secondaryMuscle != null && (secondaryXpPerKg ?? 0) > 0) {
      final secXp = (weightKg * (secondaryXpPerKg!) * reps) / 10.0 + (baseXp * 0.5);
      result[secondaryMuscle!] = double.parse(secXp.toStringAsFixed(1));
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primary_muscle': primaryMuscle,
      'primary_xp_per_kg': primaryXpPerKg,
      'secondary_muscle': secondaryMuscle,
      'secondary_xp_per_kg': secondaryXpPerKg,
      'base_xp': baseXp,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      primaryMuscle: map['primary_muscle'],
      primaryXpPerKg: (map['primary_xp_per_kg'] as num).toDouble(),
      secondaryMuscle: map['secondary_muscle'],
      secondaryXpPerKg: (map['secondary_xp_per_kg'] as num?)?.toDouble(),
      baseXp: (map['base_xp'] as num?)?.toDouble() ?? 20.0,
    );
  }
}
