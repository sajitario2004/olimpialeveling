import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
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
}
