import 'package:flutter/material.dart';

class RankTier {
  final String id;
  final String name;
  final int minLevel;
  final Color color;
  final String quote;

  const RankTier({
    required this.id,
    required this.name,
    required this.minLevel,
    required this.color,
    required this.quote,
  });

  static const List<RankTier> allRanks = [
    RankTier(
      id: 'skinnybitch',
      name: 'SKINNYBITCH',
      minLevel: 14,
      color: Color(0xFF94A3B8),
      quote: 'El punto de partida de la ascensión.',
    ),
    RankTier(
      id: 'human',
      name: 'HUMAN',
      minLevel: 25,
      color: Color(0xFF38BDF8),
      quote: 'Superando la debilidad ordinaria.',
    ),
    RankTier(
      id: 'normal_gym_buddy',
      name: 'NORMAL GYM BUDDY',
      minLevel: 55,
      color: Color(0xFF06B6D4),
      quote: 'Constancia forjada en el gimnasio.',
    ),
    RankTier(
      id: 'gymbro',
      name: 'GYMBRO',
      minLevel: 95,
      color: Color(0xFF10B981),
      quote: 'Hermano del hierro respetado por todos.',
    ),
    RankTier(
      id: 'soldier',
      name: 'SOLDIER',
      minLevel: 150,
      color: Color(0xFFEAB308),
      quote: 'Disciplina férrea y determinación implacable.',
    ),
    RankTier(
      id: 'spartan',
      name: 'SPARTAN',
      minLevel: 220,
      color: Color(0xFFF97316),
      quote: '¡Gloria en la batalla contra el peso!',
    ),
    RankTier(
      id: 'hercules',
      name: 'HERCULES',
      minLevel: 300,
      color: Color(0xFFEF4444),
      quote: 'Fuerza mitológica legendaria.',
    ),
    RankTier(
      id: 'god_of_olimpus',
      name: 'GOD OF OLIMPUS',
      minLevel: 400,
      color: Color(0xFFA855F7),
      quote: 'Ascensión divina consumada en el Olimpo.',
    ),
  ];

  static RankTier getRankForLevel(int totalLevel) {
    for (int i = allRanks.length - 1; i >= 0; i--) {
      if (totalLevel >= allRanks[i].minLevel) {
        return allRanks[i];
      }
    }
    return allRanks.first;
  }

  /// Devuelve el rango para la escala de Nivel de Cazador de 1 a 100.
  /// En el nivel 100 se desbloquea GOD OF OLIMPUS.
  static RankTier getRankForHunterLevel(int hunterLevel) {
    if (hunterLevel >= 100) return allRanks.last; // GOD OF OLIMPUS
    if (hunterLevel >= 85) return allRanks[6]; // HERCULES
    if (hunterLevel >= 70) return allRanks[5]; // SPARTAN
    if (hunterLevel >= 55) return allRanks[4]; // SOLDIER
    if (hunterLevel >= 40) return allRanks[3]; // GYMBRO
    if (hunterLevel >= 25) return allRanks[2]; // NORMAL GYM BUDDY
    if (hunterLevel >= 10) return allRanks[1]; // HUMAN
    return allRanks.first; // SKINNYBITCH
  }
}
