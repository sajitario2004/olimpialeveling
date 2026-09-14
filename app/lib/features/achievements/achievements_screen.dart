import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late List<Achievement> _achievements;

  @override
  void initState() {
    super.initState();
    _achievements = Achievement.getDefaultAchievements();
  }

  void _checkUnlocks(int totalLevel, int streak) {
    for (var ach in _achievements) {
      if (ach.id == 'ach_despanchizado' && totalLevel >= 25) ach.isUnlocked = true;
      if (ach.id == 'ach_ares' && streak >= 7) ach.isUnlocked = true;
      if (ach.id == 'ach_espartano' && totalLevel >= 220) ach.isUnlocked = true;
      if (ach.id == 'ach_dios' && totalLevel >= 400) ach.isUnlocked = true;
      if (ach.id == 'ach_hierro' && totalLevel >= 55) ach.isUnlocked = true;
      if (ach.id == 'ach_hercules' && totalLevel >= 300) ach.isUnlocked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final player = game.player;
        if (player != null) {
          _checkUnlocks(player.totalLevel, player.streakDays);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C1322),
            elevation: 0,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'TÍTULOS Y LOGROS DEL OLIMPO',
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: SystemTheme.spartanGold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: SystemTheme.spartanGold.withOpacity(0.3), height: 1),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final ach = _achievements[index];
              final isEquipped = player?.equippedTitle == ach.title;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isEquipped
                        ? SystemTheme.spartanGold
                        : (ach.isUnlocked ? SystemTheme.neonCyan.withOpacity(0.4) : Colors.white12),
                    width: isEquipped ? 2 : 1,
                  ),
                  boxShadow: isEquipped
                      ? [BoxShadow(color: SystemTheme.spartanGold.withOpacity(0.2), blurRadius: 15)]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ach.isUnlocked
                            ? SystemTheme.neonCyan.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: ach.isUnlocked ? SystemTheme.neonCyan : Colors.white24,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ach.icon,
                          style: TextStyle(
                            fontSize: 22,
                            color: ach.isUnlocked ? Colors.white : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                ach.title,
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ach.isUnlocked ? Colors.white : Colors.white38,
                                ),
                              ),
                              if (isEquipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: SystemTheme.spartanGold.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: SystemTheme.spartanGold),
                                  ),
                                  child: Text(
                                    'EQUIPADO',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: SystemTheme.spartanGold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ach.description,
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: ach.isUnlocked ? Colors.white70 : Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Efecto Pasivo: ${ach.bonusDescription}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ach.isUnlocked ? SystemTheme.neonCyan : Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ach.isUnlocked)
                      IconButton(
                        icon: Icon(
                          isEquipped ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isEquipped ? SystemTheme.spartanGold : SystemTheme.neonCyan,
                        ),
                        tooltip: isEquipped ? 'Título Equipado' : 'Equipar Título',
                        onPressed: () {
                          game.equipTitle(isEquipped ? null : ach.title);
                        },
                      )
                    else
                      const Icon(Icons.lock, color: Colors.white24, size: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
