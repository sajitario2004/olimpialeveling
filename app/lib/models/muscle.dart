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
    if (level >= 100) return 0.0;
    if (level == 99) {
      // Para subir al nivel 100 hacen falta unas 20 veces más XP que del nivel 98 al 99
      double xp98 = 1000.0;
      for (int i = 5; i < 98; i++) {
        xp98 *= 1.15;
      }
      return double.parse((xp98 * 20.0).toStringAsFixed(1));
    }
    // A partir del nivel 6: cada nivel cuesta un 15% más que el anterior de forma recursiva
    double xp = 1000.0;
    for (int i = 5; i < level; i++) {
      xp *= 1.15;
    }
    return double.parse(xp.toStringAsFixed(1));
  }

  double get progress {
    if (level >= 100) return 1.0;
    if (xpForNextLevel <= 0) return 1.0;
    return (currentXp / xpForNextLevel).clamp(0.0, 1.0);
  }

  /// Map level to a dynamic Solo Leveling heat map color
  Color get heatColor {
    if (level < 5) return const Color(0xFF64748B); // Skinnybitch (Gris)
    if (level < 15) return const Color(0xFF38BDF8); // Human (Azul cielo)
    if (level < 30) return const Color(0xFF06B6D4); // Normal Gym Buddy (Cian)
    if (level < 50) return const Color(0xFF10B981); // Gymbro (Verde)
    if (level < 65) return const Color(0xFFEAB308); // Soldier (Oro militar)
    if (level < 80) return const Color(0xFFF97316); // Spartan (Naranja ardiente)
    if (level < 99) return const Color(0xFFEF4444); // Hercules (Rojo carmesí)
    return const Color(0xFFA855F7); // God of Olimpus (Púrpura divino)
  }

  /// Rango individual del músculo de 0 a 7
  int get rankIndex {
    if (level < 5) return 0; // skinnybitch (0..4)
    if (level < 15) return 1; // human (5..14)
    if (level < 30) return 2; // normal gym buddy (15..29)
    if (level < 50) return 3; // gymbro (30..49)
    if (level < 65) return 4; // soldier (50..64)
    if (level < 80) return 5; // spartan (65..79)
    if (level < 99) return 6; // hercules (80..98)
    return 7; // god of olimpus (99..100)
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
