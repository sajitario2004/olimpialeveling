import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/game_provider.dart';
import '../../../core/theme/system_theme.dart';

class LevelUpDialog extends StatelessWidget {
  final LevelUpEvent event;
  final VoidCallback onDismiss;

  const LevelUpDialog({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF070B14).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SystemTheme.neonCyan, width: 2),
            boxShadow: [
              BoxShadow(
                color: SystemTheme.neonCyan.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // System Alert Header
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active, color: SystemTheme.neonCyan, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '[NOTIFICACIÓN DEL SISTEMA]',
                      style: GoogleFonts.orbitron(
                        color: SystemTheme.neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Level Up Title with animation
              Text(
                '¡HAS SUBIDO DE NIVEL!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: SystemTheme.neonCyan, blurRadius: 15),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 16),

              // Muscle leveled
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      'MÚSCULO FORTALECIDO',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.muscleName.toUpperCase()} ➔ NIVEL ${event.muscleLevel}',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SystemTheme.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Total Level & Rank
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Text('NIVEL TOTAL', style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white60)),
                          Text(
                            '${event.totalLevel}',
                            style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: event.rank.color.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text('RANGO', style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white60)),
                          Text(
                            event.rank.name,
                            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: event.rank.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reward points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SystemTheme.spartanGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SystemTheme.spartanGold),
                ),
                child: Text(
                  '+${event.pointsAwarded} PUNTOS DE ATRIBUTO DISPONIBLES',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: SystemTheme.spartanGold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SystemTheme.neonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'ACEPTAR',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
