import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../providers/game_provider.dart';
import '../dungeons/rank_dungeon_sheet.dart';

class HunterStatsSheet extends StatelessWidget {
  const HunterStatsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final player = game.player;
        if (player == null) return const SizedBox.shrink();

        final rank = player.rank;

        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF090D1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: rank.color.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: rank.color.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
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
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Window Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[SISTEMA // VENTANA DE ESTADO]',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: SystemTheme.neonCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'CAZADOR DEL OLIMPO',
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: rank.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rank.color),
                      ),
                      child: Text(
                        'NIVEL ${player.totalLevel}',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: rank.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rank Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rank.color.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rank.color.withOpacity(0.2),
                          border: Border.all(color: rank.color, width: 2),
                          boxShadow: [BoxShadow(color: rank.color.withOpacity(0.5), blurRadius: 10)],
                        ),
                        child: Center(
                          child: Text(
                            rank.name[0],
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: rank.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RANGO ACTUAL: ${rank.name}',
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: rank.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rank.quote,
                              style: GoogleFonts.rajdhani(
                                fontSize: 12,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Combat Power (CP) Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131B2E), Color(0xFF1E1B4B)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SystemTheme.spartanGold.withOpacity(0.8), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: SystemTheme.spartanGold.withOpacity(0.15), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on, color: SystemTheme.spartanGold, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'PODER DE COMBATE (CP)',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: SystemTheme.spartanGold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Fórmula: Nivel Total x100 + Atributos',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${player.combatPower}',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Unallocated points alert
                if (player.unallocatedPoints > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SystemTheme.spartanGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SystemTheme.spartanGold),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '⚡ PUNTOS DISPONIBLES PARA ASIGNAR:',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: SystemTheme.spartanGold,
                          ),
                        ),
                        Text(
                          '+${player.unallocatedPoints}',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: SystemTheme.spartanGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Attributes List
                Text(
                  'ATRIBUTOS DEL CAZADOR',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                _statRow(
                  context,
                  game,
                  statKey: 'strength',
                  name: 'FUERZA (STR)',
                  desc: 'Poder de carga y levantamiento pesado',
                  value: player.strength,
                  canAdd: player.unallocatedPoints > 0,
                  color: const Color(0xFFEF4444),
                ),
                _statRow(
                  context,
                  game,
                  statKey: 'agility',
                  name: 'AGILIDAD (AGI)',
                  desc: 'Velocidad, calistenia y rango de movimiento',
                  value: player.agility,
                  canAdd: player.unallocatedPoints > 0,
                  color: const Color(0xFF00F0FF),
                ),
                _statRow(
                  context,
                  game,
                  statKey: 'endurance',
                  name: 'RESISTENCIA (END)',
                  desc: 'Capacidad cardiovascular y aguante muscular',
                  value: player.endurance,
                  canAdd: player.unallocatedPoints > 0,
                  color: const Color(0xFF10B981),
                ),
                _statRow(
                  context,
                  game,
                  statKey: 'discipline',
                  name: 'DISCIPLINA (DIS)',
                  desc: 'Firmeza mental, constancia y racha inquebrantable',
                  value: player.discipline,
                  canAdd: player.unallocatedPoints > 0,
                  color: const Color(0xFFA855F7),
                ),
                const SizedBox(height: 16),

                // Ascension Dungeon Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: SystemTheme.spartanGold,
                    side: const BorderSide(color: SystemTheme.spartanGold, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.shield_outlined, color: SystemTheme.spartanGold),
                  label: Text(
                    'MAZMORRA DE ASCENSO SEMANAL',
                    style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const RankDungeonSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(
    BuildContext context,
    GameProvider game, {
    required String statKey,
    required String name,
    required String desc,
    required int value,
    required bool canAdd,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '$value',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: canAdd ? color : Colors.white24,
                  size: 26,
                ),
                onPressed: canAdd ? () => game.allocateStatPoint(statKey) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
