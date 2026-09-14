import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../../models/muscle.dart';
import '../body_map/widgets/anatomical_body_view.dart';
import '../body_map/widgets/muscle_detail_sheet.dart';
import '../quests/daily_quest_sheet.dart';
import '../stats/hunter_stats_sheet.dart';
import '../level_up/level_up_dialog.dart';
import '../exercises/exercise_library_screen.dart';
import '../achievements/achievements_screen.dart';
import '../settings/settings_screen.dart';
import '../dungeons/rank_dungeon_sheet.dart';
import '../history/workout_history_sheet.dart';
import '../developer/developer_terminal_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final player = game.player;

        // Check for Level Up, Penalty, and Anti-cheat warnings
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (game.lastLevelUpEvent != null) {
            final event = game.lastLevelUpEvent!;
            game.clearLevelUpEvent();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => LevelUpDialog(
                event: event,
                onDismiss: () => Navigator.of(ctx).pop(),
              ),
            );
          }

          if (game.penaltyAlert != null) {
            final alertMsg = game.penaltyAlert!;
            game.clearPenaltyAlert();
            _showPenaltyDialog(context, alertMsg);
          }

          if (game.antiCheatWarning != null) {
            final warnMsg = game.antiCheatWarning!;
            game.clearAntiCheatWarning();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(warnMsg, style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 4),
              ),
            );
          }

          if (game.prAlert != null) {
            final prMsg = game.prAlert!;
            game.clearPrAlert();
            _showPrDialog(context, prMsg);
          }
        });

        if (player == null || game.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: SystemTheme.neonCyan),
            ),
          );
        }

        final rank = player.rank;

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: AppBar(
              backgroundColor: const Color(0xFF0C1322),
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3), width: 1.2),
                  ),
                ),
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: rank.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: rank.color),
                      ),
                      child: Text(
                        rank.name,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: rank.color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Total Level
                    Text(
                      'NV. ${player.totalLevel}',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    if (player.equippedTitle != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '«${player.equippedTitle}»',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          color: SystemTheme.spartanGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                // Server Sync Indicator
                Tooltip(
                  message: game.isServerOnline
                      ? 'Servidor Python conectado'
                      : 'Modo Local SQLite (servidor Python desconectado)',
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: game.isServerOnline ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: game.isServerOnline ? Colors.green : Colors.amber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: game.isServerOnline ? Colors.green : Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.isServerOnline ? 'SERVER' : 'OFFLINE',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: game.isServerOnline ? Colors.green : Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Developer Terminal / God Mode button (only for admin / developer)
                if (game.currentUser?.hasPrivilegedAccess ?? false)
                  IconButton(
                    icon: const Icon(Icons.terminal, color: SystemTheme.spartanGold),
                    tooltip: 'Terminal de Desarrollador // God Mode',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const DeveloperTerminalDialog(),
                    ),
                  ),

                // Battle History button
                IconButton(
                  icon: const Icon(Icons.history_outlined, color: Colors.white70),
                  tooltip: 'Historial de Batalla',
                  onPressed: () => _openWorkoutHistory(context),
                ),

                // Quests button
                IconButton(
                  icon: const Icon(Icons.assignment_turned_in_outlined, color: SystemTheme.neonCyan),
                  tooltip: 'Misiones Diarias',
                  onPressed: () => _openDailyQuests(context),
                ),

                // Ascension Dungeon button
                IconButton(
                  icon: const Icon(Icons.shield_outlined, color: SystemTheme.spartanGold),
                  tooltip: 'Mazmorra de Ascenso Semanal',
                  onPressed: () => _openRankDungeon(context),
                ),

                // Stats / Status window button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      tooltip: 'Ventana de Estado',
                      onPressed: () => _openHunterStats(context),
                    ),
                    if (player.unallocatedPoints > 0)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: SystemTheme.spartanGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${player.unallocatedPoints}',
                            style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildMainBodyTab(context, game),
              const ExerciseLibraryScreen(),
              const AchievementsScreen(),
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C1322),
              border: Border(
                top: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3), width: 1.2),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (idx) => setState(() => _currentTabIndex = idx),
              backgroundColor: const Color(0xFF0C1322),
              selectedItemColor: SystemTheme.neonCyan,
              unselectedItemColor: Colors.white38,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.accessibility_new),
                  label: 'Cuerpo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: 'Biblioteca',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events),
                  label: 'Títulos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainBodyTab(BuildContext context, GameProvider game) {
    final player = game.player!;
    final streakBonus = player.streakBonusPercentage;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              // Top Motivational Solo Leveling Subheader
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF090E1A),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SystemTheme.spartanGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SystemTheme.spartanGold.withOpacity(0.5)),
                            ),
                            child: Text(
                              'CP: ${player.combatPower} ⚡',
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: SystemTheme.spartanGold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '14 MÚSCULOS // TOCA PARA ENTRENAR',
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              color: Colors.white54,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          if (streakBonus > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: Text(
                                '+$streakBonus% XP',
                                style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            ),
                          Text(
                            'RACHA: ${player.streakDays} DÍAS 🔥',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Centerpiece: Front and Back Anatomical Bodies side-by-side
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AnatomicalBodyView(
                    muscles: game.muscles,
                    onMuscleSelected: (muscle) => _openMuscleDetail(context, muscle),
                  ),
                ),
              ),

              // Bottom Daily Quest Bar
              _buildBottomQuestBar(context, game),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomQuestBar(BuildContext context, GameProvider game) {
    final quests = game.dailyQuests;
    final anyDone = quests.isNotEmpty && quests.any((q) => q.isCompleted);

    return InkWell(
      onTap: () => _openDailyQuests(context),
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: anyDone ? SystemTheme.hunterGreen : SystemTheme.neonCyan.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (anyDone ? SystemTheme.hunterGreen : SystemTheme.neonCyan).withOpacity(0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              anyDone ? Icons.verified : Icons.warning_amber_rounded,
              color: anyDone ? SystemTheme.hunterGreen : Colors.orangeAccent,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anyDone ? 'PRUEBA DIARIA: COMPLETADA POR HOY' : '4 PRUEBAS DIARIAS DISPONIBLES (ELIGE 1)',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: anyDone ? SystemTheme.hunterGreen : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '100 Flexiones • 100 Sentadillas • 100 Abdominales • 10 km',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  void _openMuscleDetail(BuildContext context, Muscle muscle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: MuscleDetailSheet(muscle: muscle),
        ),
      ),
    );
  }

  void _openDailyQuests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: const DailyQuestSheet(),
        ),
      ),
    );
  }

  void _openHunterStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: const HunterStatsSheet(),
        ),
      ),
    );
  }

  void _openRankDungeon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: const RankDungeonSheet(),
        ),
      ),
    );
  }

  void _openWorkoutHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: const WorkoutHistorySheet(),
        ),
      ),
    );
  }

  void _showPrDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystemTheme.spartanGold, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: SystemTheme.spartanGold, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '¡NUEVO RÉCORD PERSONAL (PR)!',
                style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: SystemTheme.spartanGold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('¡GLORIA AL OLIMPO!', style: GoogleFonts.orbitron(color: SystemTheme.spartanGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPenaltyDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystemTheme.dangerRed, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.dangerous, color: SystemTheme.dangerRed),
            const SizedBox(width: 8),
            Text(
              'PENALIZACIÓN DEL SISTEMA',
              style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: SystemTheme.dangerRed),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('ENTENDIDO', style: GoogleFonts.orbitron(color: SystemTheme.dangerRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
