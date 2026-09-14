import 'package:flutter/material.dart';

class Muscle {
  final String id;
  final String name;
  final String category; // 'front', 'back', 'both'
  int level;
  double currentXp;

  Muscle({
    required this.id,
    required this.name,
    required this.category,
    this.level = 1,
    this.currentXp = 0.0,
  });

  /// XP required to level up from current level to next level
  double get xpForNextLevel {
    if (level <= 1) return 100.0;
    if (level == 2) return 200.0;
    if (level == 3) return 300.0;
    if (level == 4) return 400.0;
    if (level == 5) return 1000.0; // Del nivel 5 al 6 hacen falta 1000 XP
    // A partir del nivel 6: cada nivel cuesta un 15% más que el anterior de forma recursiva
    double xp = 1000.0;
    for (int i = 5; i < level; i++) {
      xp *= 1.15;
    }
    return double.parse(xp.toStringAsFixed(1));
  }

  double get progress => (currentXp / xpForNextLevel).clamp(0.0, 1.0);

  /// Map level to a dynamic Solo Leveling heat map color
  Color get heatColor {
    if (level < 5) return const Color(0xFF64748B); // Slate / Skinny
    if (level < 15) return const Color(0xFF00F0FF); // Neon Cyan
    if (level < 30) return const Color(0xFF10B981); // Hunter Green
    if (level < 50) return const Color(0xFFF59E0B); // Spartan Amber
    if (level < 80) return const Color(0xFFEF4444); // Hercules Crimson
    return const Color(0xFFA855F7); // God of Olimpus Divine Purple
  }

  /// Rango individual del músculo de 0 a 7
  int get rankIndex {
    if (level < 5) return 0; // skinnybitch
    if (level < 15) return 1; // human
    if (level < 30) return 2; // normal gym buddy
    if (level < 50) return 3; // gymbro
    if (level < 75) return 4; // soldier
    if (level < 110) return 5; // spartan
    if (level < 150) return 6; // hercules
    return 7; // god of olimpus
  }

  String get rankName {
    const names = [
      'SKINNYBITCH',
      'HUMAN',
      'NORMAL GYM BUDDY',
      'GYMBRO',
      'SOLDIER',
      'SPARTAN',
      'HERCULES',
      'GOD OF OLIMPUS',
    ];
    return names[rankIndex];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'level': level,
      'current_xp': currentXp,
    };
  }

  factory Muscle.fromMap(Map<String, dynamic> map) {
    return Muscle(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? 'both',
      level: map['level'] ?? 1,
      currentXp: (map['current_xp'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Muscle copyWith({
    String? id,
    String? name,
    String? category,
    int? level,
    double? currentXp,
  }) {
    return Muscle(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
    );
  }
}
