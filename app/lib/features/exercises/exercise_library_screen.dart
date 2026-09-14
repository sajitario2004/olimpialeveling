import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../body_map/widgets/muscle_detail_sheet.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _searchQuery = '';
  String _selectedMuscleFilter = 'TODOS';

  final List<String> _muscleFilters = [
    'TODOS',
    'PECHO',
    'DELTOIDES',
    'DORSALES',
    'BÍCEPS',
    'TRÍCEPS',
    'PIERNAS',
    'CORE',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final exercises = game.exercises;

        // Filter exercises
        final filtered = exercises.where((ex) {
          final matchesSearch = ex.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              ex.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              ex.primaryMuscle.toLowerCase().contains(_searchQuery.toLowerCase());

          if (!matchesSearch) return false;

          if (_selectedMuscleFilter == 'TODOS') return true;
          if (_selectedMuscleFilter == 'PECHO' && (ex.primaryMuscle == 'pecho' || ex.secondaryMuscle == 'pecho')) return true;
          if (_selectedMuscleFilter == 'DELTOIDES' && (ex.primaryMuscle == 'deltoides' || ex.secondaryMuscle == 'deltoides')) return true;
          if (_selectedMuscleFilter == 'DORSALES' && (ex.primaryMuscle == 'dorsales' || ex.secondaryMuscle == 'dorsales' || ex.primaryMuscle == 'trapecio')) return true;
          if (_selectedMuscleFilter == 'BÍCEPS' && (ex.primaryMuscle == 'biceps' || ex.secondaryMuscle == 'biceps')) return true;
          if (_selectedMuscleFilter == 'TRÍCEPS' && (ex.primaryMuscle == 'triceps' || ex.secondaryMuscle == 'triceps')) return true;
          if (_selectedMuscleFilter == 'PIERNAS' && ['cuadriceps', 'isquiotibiales', 'gluteos', 'gemelos'].contains(ex.primaryMuscle)) return true;
          if (_selectedMuscleFilter == 'CORE' && ['abdominales', 'oblicuos', 'lumbar'].contains(ex.primaryMuscle)) return true;

          return false;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C1322),
            elevation: 0,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'BIBLIOTECA DE EJERCICIOS',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: SystemTheme.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: SystemTheme.neonCyan.withOpacity(0.3), height: 1),
            ),
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Buscar por ejercicio o técnica...',
                    hintStyle: GoogleFonts.rajdhani(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: SystemTheme.neonCyan),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: SystemTheme.neonCyan, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _muscleFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _muscleFilters[index];
                    final isSelected = _selectedMuscleFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: SystemTheme.neonCyan,
                      backgroundColor: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? SystemTheme.neonCyan : Colors.white12,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMuscleFilter = filter);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Exercise List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron ejercicios con estos criterios.',
                          style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ex = filtered[index];
                          final primaryMuscle = game.getMuscle(ex.primaryMuscle);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image or GIF Preview if present
                                if ((ex.gifUrl != null && ex.gifUrl!.isNotEmpty) ||
                                    (ex.imageUrl != null && ex.imageUrl!.isNotEmpty)) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 120,
                                      width: double.infinity,
                                      color: Colors.black26,
                                      child: Image.network(
                                        ex.gifUrl?.isNotEmpty == true ? ex.gifUrl! : ex.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ex.name,
                                        style: GoogleFonts.orbitron(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SystemTheme.neonCyan.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        'Base: ${ex.baseXp.toInt()} XP',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.neonCyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ex.description,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),

                                if (ex.tips.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 15),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            ex.tips,
                                            style: GoogleFonts.rajdhani(fontSize: 11.5, color: Colors.amber),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 10),

                                // Muscles Involved Badges (Up to 4)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: ex.musclesXp.map((mEntry) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: SystemTheme.neonCyan.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        '${mEntry.muscle.toUpperCase()} (+${mEntry.xp} XP)',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 11,
                                          color: SystemTheme.neonCyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 10),

                                // Action Buttons (YouTube Tutorial & Train Now)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (ex.youtubeUrl != null && ex.youtubeUrl!.isNotEmpty)
                                      InkWell(
                                        onTap: () async {
                                          final uri = Uri.parse(ex.youtubeUrl!);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.red.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 16),
                                              const SizedBox(width: 5),
                                              Text(
                                                'Ver en YouTube',
                                                style: GoogleFonts.rajdhani(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),

                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SystemTheme.neonCyan,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      icon: const Icon(Icons.play_arrow, size: 16),
                                      label: Text(
                                        'Entrenar',
                                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        if (primaryMuscle != null) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) => MuscleDetailSheet(muscle: primaryMuscle),
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
