import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../models/rank.dart';
import '../../providers/game_provider.dart';

/// Modal táctico exclusivo para cuentas con privilegios de Administrador o Desarrollador (God Mode).
class DeveloperTerminalDialog extends StatelessWidget {
  const DeveloperTerminalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final player = game.player;
        final user = game.currentUser;

        return AlertDialog(
          backgroundColor: const Color(0xFF0A0F1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SystemTheme.spartanGold, width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SystemTheme.spartanGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.terminal, color: SystemTheme.spartanGold, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TERMINAL DEL SISTEMA',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: SystemTheme.spartanGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'MODO DIOS // CAZADOR: ${user?.username.toUpperCase() ?? "ADMIN"}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoCol('NIVEL', '${player?.totalLevel ?? 0}'),
                        _infoCol('RANGO', player?.rank.name ?? 'N/A'),
                        _infoCol('RACHA', '${player?.streakDays ?? 0}D'),
                        _infoCol('TOKENS', '${player?.restTokens ?? 0}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'CONTROL DE RANGO Y RÉCORDS (TESTING)',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SystemTheme.spartanGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forzar Rango a cualquiera de los 8
                  _actionButton(
                    context: context,
                    icon: Icons.military_tech,
                    color: SystemTheme.spartanGold,
                    label: 'FORZAR RANGO (ELEGIR ENTRE LOS 8 RANGOS)',
                    onTap: () => _showRankSelector(context, game),
                  ),
                  const SizedBox(height: 8),

                  // Modificar Récords Personales (PR)
                  _actionButton(
                    context: context,
                    icon: Icons.emoji_events,
                    color: const Color(0xFF64B5F6),
                    label: 'MODIFICAR RÉCORDS PERSONALES (PR)',
                    onTap: () => _showPrEditor(context, game),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'HERRAMIENTAS DE PRUEBA RÁPIDA',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SystemTheme.neonCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action 1: Subir +5 niveles
                  _actionButton(
                    context: context,
                    icon: Icons.upgrade,
                    color: SystemTheme.neonCyan,
                    label: '+5 NIVELES A TODOS LOS MÚSCULOS',
                    onTap: () async {
                      await game.devBoostAllMuscles(5);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡+5 Niveles otorgados a los 14 músculos!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action 2: Inyectar +10,000 XP
                  _actionButton(
                    context: context,
                    icon: Icons.bolt,
                    color: Colors.amber,
                    label: '+10,000 XP A PECHO Y DORSALES',
                    onTap: () async {
                      await game.devInjectXp('pecho', 10000);
                      await game.devInjectXp('dorsales', 10000);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡+10,000 XP inyectados a Pecho y Dorsales!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action 3: +7 Días de racha
                  _actionButton(
                    context: context,
                    icon: Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    label: '+7 DÍAS DE RACHA (BONUS +5%/+10%)',
                    onTap: () async {
                      await game.devIncreaseStreak(7);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Racha incrementada en +7 días!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action 4: +5 Tokens de descanso
                  _actionButton(
                    context: context,
                    icon: Icons.shield,
                    color: SystemTheme.hunterGreen,
                    label: '+5 TOKENS DE DESCANSO PROTECTOR',
                    onTap: () async {
                      await game.devAddRestTokens(5);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡+5 Tokens de descanso añadidos!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action 5: Simular penalización
                  _actionButton(
                    context: context,
                    icon: Icons.warning_amber_rounded,
                    color: SystemTheme.dangerRed,
                    label: 'SIMULAR PENALIZACIÓN DE MEDIANOCHE (-1 NV)',
                    onTap: () async {
                      await game.devTriggerMidnightPenalty();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Penalización ejecutada: -1 Nivel en músculo con mayor XP')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Action 6: Reset Quests
                  _actionButton(
                    context: context,
                    icon: Icons.restart_alt,
                    color: Colors.purpleAccent,
                    label: 'REINICIAR MISIONES DIARIAS',
                    onTap: () async {
                      await game.devResetQuests();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Misiones diarias restablecidas a 0%')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CERRAR TERMINAL',
                style: GoogleFonts.orbitron(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoCol(String title, String val) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showRankSelector(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SystemTheme.spartanGold, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.military_tech, color: SystemTheme.spartanGold, size: 22),
              const SizedBox(width: 8),
              Text(
                'FORZAR RANGO DE PRUEBA',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: SystemTheme.spartanGold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: RankTier.allRanks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tier = RankTier.allRanks[index];
                final isCurrent = game.hunterRank.id == tier.id;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: tier.color.withOpacity(isCurrent ? 0.9 : 0.4), width: isCurrent ? 1.8 : 1.0),
                  ),
                  tileColor: tier.color.withOpacity(0.12),
                  leading: Icon(Icons.shield, color: tier.color),
                  title: Text(
                    tier.name,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : Colors.white70,
                    ),
                  ),
                  subtitle: Text(
                    'Niveles: ${tier.minLevel} - ${tier.maxLevel} // ${tier.id == "god_of_olimpus" ? "Nivel 100 Ascendido" : tier.quote}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white60),
                  ),
                  trailing: isCurrent ? Icon(Icons.check_circle, color: tier.color, size: 18) : null,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await game.devSetRank(tier.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rango forzado a: ${tier.name}'),
                          backgroundColor: tier.color,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('CANCELAR', style: GoogleFonts.orbitron(color: Colors.white60, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  void _showPrEditor(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: SystemTheme.spartanGold, size: 22),
              const SizedBox(width: 8),
              Text(
                'MODIFICAR RÉCORDS (PR)',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: FutureBuilder<Map<String, double>>(
              future: game.getAllPersonalRecords(),
              builder: (context, snapshot) {
                final prMap = snapshot.data ?? {};
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: game.exercises.map((exercise) {
                      final currentPr = prMap[exercise.id] ?? 0.0;
                      final ctrl = TextEditingController(
                        text: currentPr > 0 ? currentPr.toStringAsFixed(1) : '',
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Actual: ${currentPr > 0 ? "${currentPr.toStringAsFixed(1)} kg" : "Sin récord"}',
                                    style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: '0.0 kg',
                                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                  filled: true,
                                  fillColor: const Color(0xFF1E293B),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.save, color: SystemTheme.spartanGold, size: 20),
                              tooltip: 'Guardar PR',
                              onPressed: () async {
                                final newWeight = double.tryParse(ctrl.text.trim()) ?? 0.0;
                                await game.devSetPersonalRecord(exercise.id, newWeight);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PR de ${exercise.name} fijado en $newWeight kg'),
                                      backgroundColor: SystemTheme.hunterGreen,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'LISTO',
                style: GoogleFonts.orbitron(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }
}
