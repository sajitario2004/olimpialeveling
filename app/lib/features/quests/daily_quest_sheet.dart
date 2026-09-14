import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../providers/game_provider.dart';

class DailyQuestSheet extends StatefulWidget {
  const DailyQuestSheet({super.key});

  @override
  State<DailyQuestSheet> createState() => _DailyQuestSheetState();
}

class _DailyQuestSheetState extends State<DailyQuestSheet> {
  late Timer _timer;
  Duration _timeUntilMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (mounted) {
      setState(() {
        _timeUntilMidnight = midnight.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final quests = game.dailyQuests;
        final hasAnyCompleted = quests.isNotEmpty && quests.any((q) => q.isCompleted);
        final streakMultiplier = game.player?.streakBonusPercentage ?? 0;

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
            border: Border.all(
              color: hasAnyCompleted ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (hasAnyCompleted ? SystemTheme.hunterGreen : SystemTheme.neonCyan).withOpacity(0.2),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (hasAnyCompleted ? SystemTheme.hunterGreen : SystemTheme.neonCyan).withOpacity(0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/system_banner.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[SISTEMA // MISIÓN DIARIA]',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
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
                              'ELIGE TU PRUEBA HEROICA',
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
                    const SizedBox(width: 8),
                    // Countdown timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(_timeUntilMidnight),
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Explanatory badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: SystemTheme.neonCyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Elige 1 de las 4 misiones como tu meta del día. Completar tu misión salvará tu nivel a medianoche y aumentará tu racha diaria.',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Streak Bonus Banner
                if (streakMultiplier > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🔥 BONUS DE RACHA ACTIVO: ',
                            style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          Text(
                            '+$streakMultiplier% XP en todos los entrenamientos',
                            style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Rest Day Token Banner / Button
                if (game.player?.isRestDayUsedToday == true)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.nightlight_round, color: Colors.tealAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🛡️ TOKEN DE DESCANSO ACTIVADO: La recuperación muscular es sagrada. Tu racha y nivel están protegidos hoy.',
                            style: GoogleFonts.rajdhani(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else if ((game.player?.restTokens ?? 0) > 0 && !hasAnyCompleted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final used = await game.useRestDayToken();
                        if (used && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Token de descanso consumido! Tu racha y nivel están protegidos hoy.'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.nightlight_round, color: Colors.tealAccent, size: 18),
                      label: Text(
                        'USAR TOKEN DE DESCANSO (${game.player?.restTokens} disponibles)',
                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.tealAccent),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),

                // Status Banner
                if (hasAnyCompleted)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SystemTheme.hunterGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SystemTheme.hunterGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: SystemTheme.hunterGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '¡MISIÓN DIARIA SUPERADA! Has protegido tu nivel por hoy. Racha actual: ${game.player?.streakDays ?? 1} días.',
                            style: GoogleFonts.rajdhani(
                              color: SystemTheme.hunterGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SystemTheme.dangerRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SystemTheme.dangerRed.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: SystemTheme.dangerRed, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PENALIZACIÓN: Si no completas al menos una de las 4 pruebas antes de medianoche, perderás 1 NIVEL.',
                            style: GoogleFonts.rajdhani(
                              color: SystemTheme.dangerRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                Text(
                  'LAS 4 PRUEBAS DEL OLIMPO',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                ...quests.map((quest) {
                  final isSelected = quest.isSelected;

                  return InkWell(
                    onTap: () => game.selectDailyQuest(quest.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: quest.isCompleted
                              ? SystemTheme.hunterGreen
                              : (isSelected ? SystemTheme.neonCyan : Colors.white12),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? SystemTheme.neonCyan : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  quest.name,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: quest.isCompleted
                                        ? SystemTheme.hunterGreen
                                        : (isSelected ? Colors.white : Colors.white70),
                                  ),
                                ),
                              ),
                              Text(
                                '${quest.current.toStringAsFixed(0)} / ${quest.target.toStringAsFixed(0)} ${quest.unit}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: quest.isCompleted ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: quest.progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF1E293B),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                quest.isCompleted ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!quest.isCompleted)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => game.addProgressToQuest(quest.id, 10),
                                  child: Text('+10 ${quest.unit}', style: GoogleFonts.orbitron(fontSize: 11, color: SystemTheme.neonCyan)),
                                ),
                                TextButton(
                                  onPressed: () => game.addProgressToQuest(quest.id, quest.target - quest.current),
                                  child: Text('COMPLETAR', style: GoogleFonts.orbitron(fontSize: 11, color: SystemTheme.hunterGreen)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Simulation Button for Penalty Testing
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await game.simulateMidnightPenalty();
                  },
                  icon: const Icon(Icons.bolt, color: Colors.orangeAccent, size: 16),
                  label: Text(
                    'PROBAR PENALIZACIÓN DE MEDIANOCHE (-1 NIVEL)',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orangeAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
