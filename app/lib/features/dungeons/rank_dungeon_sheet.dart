import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../core/audio/audio_service.dart';
import '../../providers/game_provider.dart';
import '../../models/muscle.dart';
import '../../models/rank.dart';
import '../body_map/widgets/muscle_detail_sheet.dart';

class RankDungeonSheet extends StatefulWidget {
  const RankDungeonSheet({super.key});

  @override
  State<RankDungeonSheet> createState() => _RankDungeonSheetState();
}

class _RankDungeonSheetState extends State<RankDungeonSheet> {
  String _selectedDungeonType = 'pecho'; // 'pecho', 'espalda', 'pierna'

  @override
  void initState() {
    super.initState();
    AudioService.instance.playDungeonEnter();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final player = game.player;
        if (player == null) return const SizedBox.shrink();

        final bool isSupremeTrial = game.hunterLevel >= 100 && !player.hasCompletedSupremeTrial;
        final currentRankIndex = player.rankIndex;
        final nextRankIndex = isSupremeTrial ? 7 : (currentRankIndex + 1).clamp(0, 7);
        final nextRank = RankTier.allRanks[nextRankIndex];
        final isMaxRank = player.hasCompletedSupremeTrial && currentRankIndex >= 7;

        // VERIFICATION: Check -2 ranks rule
        // Target rank is nextRankIndex. Minimum allowed muscle rank is max(0, nextRankIndex - 2)
        final minAllowedMuscleRankIndex = (nextRankIndex - 2).clamp(0, 7);
        final minAllowedRank = RankTier.allRanks[minAllowedMuscleRankIndex];

        final List<Muscle> laggingMuscles = game.muscles.where((m) {
          return m.rankIndex < minAllowedMuscleRankIndex;
        }).toList();

        final bool isBlockedByImbalance = laggingMuscles.isNotEmpty;

        final Color sheetBorderColor = isBlockedByImbalance
            ? SystemTheme.dangerRed
            : (isSupremeTrial ? const Color(0xFF64B5F6) : SystemTheme.spartanGold);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF070B14),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: sheetBorderColor,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: sheetBorderColor.withOpacity(0.25),
                blurRadius: 30,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: sheetBorderColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/dungeon_gate.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isSupremeTrial
                                  ? '[SISTEMA // PRUEBA SUPREMA DE ASCENSIÓN]'
                                  : '[SISTEMA // MAZMORRA SEMANAL]',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: isBlockedByImbalance
                                    ? SystemTheme.dangerRed
                                    : (isSupremeTrial ? const Color(0xFF64B5F6) : SystemTheme.spartanGold),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isSupremeTrial ? const Color(0xFFFFD700) : nextRank.color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSupremeTrial ? const Color(0xFFFFD700) : nextRank.color),
                              ),
                              child: Text(
                                isSupremeTrial ? 'ASCENSIÓN A GOD OF OLIMPUS' : 'RUMBO A ${nextRank.name}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSupremeTrial ? const Color(0xFFFFD700) : nextRank.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isSupremeTrial ? 'PRUEBA SUPREMA DEL OLIMPO' : 'PRUEBA DE ASCENSO DE RANGO',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (isMaxRank)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: Text(
                      '¡Has alcanzado el rango supremo GOD OF OLIMPUS! Te sientas en la cima del panteón de los dioses.',
                      style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (isSupremeTrial) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D47A1).withOpacity(0.4),
                          const Color(0xFF1565C0).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars, color: Color(0xFF64B5F6), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'DESAFÍO SUPREMO: MONTE OLIMPO',
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF64B5F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Has conquistado el Nivel 100 (mostrado en azul). Supera la prueba suprema para reclamar el rango definitivo GOD OF OLIMPUS y teñir tu perfil en aura dorada.',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                    ),
                    icon: const Icon(Icons.auto_awesome, color: Colors.black),
                    label: Text(
                      'SUPERAR PRUEBA SUPREMA Y ASCENDER A DIOS',
                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                    onPressed: () async {
                      await game.completeSupremeAscensionTrial();
                      if (context.mounted) {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                            ),
                            title: Text(
                              '⚡ ¡ASCENSIÓN DIVINA LOGRADA! ⚡',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars, color: Color(0xFFFFD700), size: 64),
                                const SizedBox(height: 12),
                                Text(
                                  'Has conquistado el nivel 100 y superado la prueba suprema del Olimpo.\n\nAhora eres: GOD OF OLIMPUS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  'RECLAMAR EL TRONO',
                                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ]
                else if (isBlockedByImbalance) ...[
                  // RED WARNING: IMBALANCE DETECTED
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E0A0A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: SystemTheme.dangerRed, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.dangerous, color: SystemTheme.dangerRed, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BLOQUEO: DESCOMPENSACIÓN MUSCULAR DETECTADA',
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: SystemTheme.dangerRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los dioses exigen simetría física. Para aspirar al rango ${nextRank.name}, ningún músculo puede estar a más de 2 rangos de diferencia (Mínimo requerido: Rango ${minAllowedRank.name}).',
                          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'MÚSCULOS QUE DEBES SUBIR DE NIVEL ANTES DE LA PRUEBA:',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: laggingMuscles.map((m) {
                            return ActionChip(
                              backgroundColor: const Color(0xFF2D1515),
                              side: const BorderSide(color: Colors.redAccent),
                              label: Text(
                                '${m.name.toUpperCase()} (Nv.${m.level} • ${m.rankName})',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => MuscleDetailSheet(muscle: m),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // UNLOCKED: CHOOSE DUNGEON SET (PECHO, ESPALDA O PIERNA)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SystemTheme.spartanGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SystemTheme.spartanGold),
                    ),
                    child: Text(
                      '¡Cuerpos compensados y simétricos! Elige una de las 3 mazmorras semanales para demostrar tu valía y ascender a ${nextRank.name}.',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('SELECCIONA TU ESPECIALIZACIÓN DE MAZMORRA:', style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _dungeonTypeButton('pecho', '🛡️ PECHO', SystemTheme.neonCyan),
                      const SizedBox(width: 8),
                      _dungeonTypeButton('espalda', '⚔️ ESPALDA', SystemTheme.electricBlue),
                      const SizedBox(width: 8),
                      _dungeonTypeButton('pierna', '🏛️ PIERNAS', SystemTheme.spartanGold),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dungeon Exercises List
                  _buildDungeonWorkoutSets(context, game),
                ],

                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('CERRAR', style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dungeonTypeButton(String key, String title, Color color) {
    final isSelected = _selectedDungeonType == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedDungeonType = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.white12,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDungeonWorkoutSets(BuildContext context, GameProvider game) {
    List<Map<String, String>> exercises = [];

    if (_selectedDungeonType == 'pecho') {
      exercises = [
        {'name': 'Press de Banca Plano', 'target': '3 series x 8 repeticiones (Carga pesada)', 'muscle': 'pecho'},
        {'name': 'Press Inclinado con Barra', 'target': '3 series x 10 repeticiones', 'muscle': 'deltoides'},
        {'name': 'Fondos en Paralelas (Dips)', 'target': '3 series x 12 repeticiones', 'muscle': 'triceps'},
      ];
    } else if (_selectedDungeonType == 'espalda') {
      exercises = [
        {'name': 'Dominadas Pronas', 'target': '3 series x 8 repeticiones estrictas', 'muscle': 'dorsales'},
        {'name': 'Remo con Barra 45°', 'target': '3 series x 10 repeticiones', 'muscle': 'dorsales'},
        {'name': 'Peso Muerto Convencional', 'target': '3 series x 6 repeticiones de poder', 'muscle': 'lumbar'},
      ];
    } else {
      exercises = [
        {'name': 'Sentadilla Trasera con Barra', 'target': '3 series x 8 repeticiones profundas', 'muscle': 'cuadriceps'},
        {'name': 'Prensa de Piernas Inclinada', 'target': '3 series x 12 repeticiones', 'muscle': 'gluteos'},
        {'name': 'Elevación de Talones de Pie', 'target': '3 series x 15 repeticiones', 'muscle': 'gemelos'},
      ];
    }

    return Column(
      children: exercises.map((item) {
        final muscle = game.getMuscle(item['muscle']!);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name']!, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(item['target']!, style: GoogleFonts.rajdhani(fontSize: 12, color: SystemTheme.neonCyan, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (muscle != null) {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => MuscleDetailSheet(muscle: muscle),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SystemTheme.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text('ENTRENAR', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
