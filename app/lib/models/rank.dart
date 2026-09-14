import 'package:flutter/material.dart';

class RankTier {
  final String id;
  final String name;
  final int minLevel;
  final int maxLevel;
  final Color color;
  final String quote;

  const RankTier({
    required this.id,
    required this.name,
    required this.minLevel,
    this.maxLevel = 100,
    required this.color,
    required this.quote,
  });

  static const List<RankTier> allRanks = [
    RankTier(
      id: 'skinnybitch',
      name: 'SKINNYBITCH',
      minLevel: 0,
      maxLevel: 4,
      color: Color(0xFF94A3B8),
      quote: 'El punto de partida del despertar. Todo dios fue mortal.',
    ),
    RankTier(
      id: 'human',
      name: 'HUMAN',
      minLevel: 5,
      maxLevel: 14,
      color: Color(0xFF38BDF8),
      quote: 'Superando la debilidad ordinaria cotidiana.',
    ),
    RankTier(
      id: 'normal_gym_buddy',
      name: 'NORMAL GYM BUDDY',
      minLevel: 15,
      maxLevel: 29,
      color: Color(0xFF06B6D4),
      quote: 'Constancia forjada entrenamiento a entrenamiento.',
    ),
    RankTier(
      id: 'gymbro',
      name: 'GYMBRO',
      minLevel: 30,
      maxLevel: 49,
      color: Color(0xFF10B981),
      quote: 'Hermano del hierro respetado por todos en la sala.',
    ),
    RankTier(
      id: 'soldier',
      name: 'SOLDIER',
      minLevel: 50,
      maxLevel: 64,
      color: Color(0xFFEAB308),
      quote: 'Disciplina militar espartana. El dolor es debilidad abandonando el cuerpo.',
    ),
    RankTier(
      id: 'spartan',
      name: 'SPARTAN',
      minLevel: 65,
      maxLevel: 79,
      color: Color(0xFFF97316),
      quote: '¡Gloria en la batalla contra el hierro! Voluntad inquebrantable.',
    ),
    RankTier(
      id: 'hercules',
      name: 'HERCULES',
      minLevel: 80,
      maxLevel: 98,
      color: Color(0xFFEF4444),
      quote: 'Fuerza mitológica legendaria sobrehumana.',
    ),
    RankTier(
      id: 'god_of_olimpus',
      name: 'GOD OF OLIMPUS',
      minLevel: 99,
      maxLevel: 100,
      color: Color(0xFFA855F7),
      quote: 'Ascensión divina consumada en el Olimpo. Cúspide de la gloria.',
    ),
  ];

  /// Niveles de Cazador que exigen superar la prueba física/semanal para pasar al siguiente nivel y rango
  static const Set<int> trialLevels = {4, 14, 29, 49, 64, 79, 98};

  static bool isTrialLevel(int level) => trialLevels.contains(level);

  /// Devuelve el rango para la escala de Nivel de Cazador de 0 a 100.
  static RankTier getRankForHunterLevel(int hunterLevel) {
    if (hunterLevel >= 99) return allRanks[7]; // GOD OF OLIMPUS (99-100)
    if (hunterLevel >= 80) return allRanks[6]; // HERCULES (80-98)
    if (hunterLevel >= 65) return allRanks[5]; // SPARTAN (65-79)
    if (hunterLevel >= 50) return allRanks[4]; // SOLDIER (50-64)
    if (hunterLevel >= 30) return allRanks[3]; // GYMBRO (30-49)
    if (hunterLevel >= 15) return allRanks[2]; // NORMAL GYM BUDDY (15-29)
    if (hunterLevel >= 5) return allRanks[1];  // HUMAN (5-14)
    return allRanks.first;                     // SKINNYBITCH (0-4)
  }

  static RankTier getRankForLevel(int level) => getRankForHunterLevel(level);
}
