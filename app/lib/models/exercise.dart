class MuscleXpEntry {
  final String muscle;
  final double xp;

  const MuscleXpEntry({required this.muscle, required this.xp});

  Map<String, dynamic> toMap() => {'muscle': muscle, 'xp': xp};

  factory MuscleXpEntry.fromMap(Map<String, dynamic> map) {
    return MuscleXpEntry(
      muscle: map['muscle'] as String,
      xp: (map['xp'] as num).toDouble(),
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String tips;
  final String primaryMuscle;
  final double primaryXpPerKg;
  final String? secondaryMuscle;
  final double? secondaryXpPerKg;
  final double baseXp;
  final String? imageUrl;
  final String? gifUrl;
  final String? youtubeUrl;
  final List<MuscleXpEntry> musclesXp;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.tips = '',
    required this.primaryMuscle,
    required this.primaryXpPerKg,
    this.secondaryMuscle,
    this.secondaryXpPerKg,
    this.baseXp = 20.0,
    this.imageUrl,
    this.gifUrl,
    this.youtubeUrl,
    List<MuscleXpEntry>? musclesXp,
  }) : musclesXp = musclesXp ?? [
          MuscleXpEntry(muscle: primaryMuscle, xp: primaryXpPerKg),
          if (secondaryMuscle != null && (secondaryXpPerKg ?? 0) > 0)
            MuscleXpEntry(muscle: secondaryMuscle, xp: secondaryXpPerKg!),
        ];

  Map<String, double> calculateXp({required double weightKg, required int reps}) {
    if (musclesXp.isNotEmpty) {
      final Map<String, double> result = {};
      for (int i = 0; i < musclesXp.length; i++) {
        final entry = musclesXp[i];
        final base = i == 0 ? baseXp : (baseXp * 0.5);
        final xp = (weightKg * entry.xp * reps) / 10.0 + base;
        result[entry.muscle] = double.parse(xp.toStringAsFixed(1));
      }
      return result;
    }

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
      'tips': tips,
      'primary_muscle': primaryMuscle,
      'primary_xp_per_kg': primaryXpPerKg,
      'secondary_muscle': secondaryMuscle,
      'secondary_xp_per_kg': secondaryXpPerKg,
      'base_xp': baseXp,
      'image_url': imageUrl,
      'gif_url': gifUrl,
      'youtube_url': youtubeUrl,
      'muscles_xp': musclesXp.map((e) => e.toMap()).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    List<MuscleXpEntry>? mList;
    if (map['muscles_xp'] != null && map['muscles_xp'] is List) {
      mList = (map['muscles_xp'] as List)
          .map((item) => MuscleXpEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final prim = map['primary_muscle'] ?? (mList != null && mList.isNotEmpty ? mList.first.muscle : 'pecho');
    final primXp = map['primary_xp_per_kg'] != null
        ? (map['primary_xp_per_kg'] as num).toDouble()
        : (mList != null && mList.isNotEmpty ? mList.first.xp : 5.0);

    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      tips: map['tips'] ?? '',
      primaryMuscle: prim,
      primaryXpPerKg: primXp,
      secondaryMuscle: map['secondary_muscle'],
      secondaryXpPerKg: (map['secondary_xp_per_kg'] as num?)?.toDouble(),
      baseXp: (map['base_xp'] as num?)?.toDouble() ?? 20.0,
      imageUrl: map['image_url'],
      gifUrl: map['gif_url'],
      youtubeUrl: map['youtube_url'],
      musclesXp: mList,
    );
  }
}
