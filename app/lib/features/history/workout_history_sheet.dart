import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../core/calculator/one_rm_calculator.dart';
import '../../../providers/game_provider.dart';

class WorkoutHistorySheet extends StatelessWidget {
  const WorkoutHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final logs = game.workoutLogs;
        final todayVolume = game.todayVolume;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF090D1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: SystemTheme.neonCyan.withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '[SISTEMA // REGISTRO DE COMBATE]',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: SystemTheme.neonCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'HISTORIAL DE SERIES',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Summary Tonnage Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131B2E), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'TONELAJE HOY',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${todayVolume.toStringAsFixed(0)} KG',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: SystemTheme.neonCyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.white12),
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'SERIES TOTALES',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${logs.length}',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: SystemTheme.spartanGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of Logs
              Expanded(
                child: logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center_outlined, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                              'AÚN NO HAY SERIES REGISTRADAS',
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Toca cualquier músculo del mapa anatómico para registrar tu primer set.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final weight = (log['weight'] as num).toDouble();
                          final reps = (log['reps'] as num).toInt();
                          final xp = (log['xp_awarded'] as num).toDouble();
                          final exerciseName = log['exercise_name'] ?? log['exercise_id'];
                          final muscleName = log['muscle_name'] ?? log['muscle_id'];
                          final timestamp = log['timestamp'] as String? ?? '';
                          final estimated1RM = OneRmCalculator.estimate(weight: weight, reps: reps);

                          String timeFormatted = '';
                          if (timestamp.isNotEmpty) {
                            try {
                              final dt = DateTime.parse(timestamp);
                              timeFormatted = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                            } catch (_) {
                              timeFormatted = timestamp;
                            }
                          }

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
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: SystemTheme.neonCyan.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.bolt, color: SystemTheme.neonCyan, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$exerciseName',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Músculo: ${muscleName.toString().toUpperCase()} • $timeFormatted',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 11,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                       FittedBox(
                                         fit: BoxFit.scaleDown,
                                         alignment: Alignment.centerLeft,
                                         child: Row(
                                           children: [
                                             Container(
                                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                               decoration: BoxDecoration(
                                                 color: Colors.white.withOpacity(0.06),
                                                 borderRadius: BorderRadius.circular(4),
                                               ),
                                               child: Text(
                                                 '1RM: ~${estimated1RM.toStringAsFixed(1)} kg',
                                                 style: GoogleFonts.orbitron(fontSize: 9, color: SystemTheme.spartanGold),
                                               ),
                                             ),
                                             const SizedBox(width: 8),
                                             Text(
                                               'Vol: ${(weight * reps).toStringAsFixed(0)} kg',
                                               style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white38),
                                             ),
                                           ],
                                         ),
                                       ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${weight.toStringAsFixed(1)} kg',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$reps reps',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.electricBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '+${xp.toStringAsFixed(0)} XP',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.hunterGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
