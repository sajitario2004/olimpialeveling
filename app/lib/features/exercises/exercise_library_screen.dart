import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/system_theme.dart';
import '../../models/exercise.dart';
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
  String _selectedEquipmentFilter = 'TODOS';
  String _selectedGripFilter = 'TODOS';

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

  final List<String> _equipmentFilters = [
    'TODOS',
    'BARRA',
    'MANCUERNA',
    'POLEA',
    'MÁQUINA',
    'CORPORAL',
  ];

  final List<String> _gripFilters = [
    'TODOS',
    'PRONO',
    'SUPINO',
    'NEUTRO',
  ];

  bool _matchesEquipment(Exercise ex) {
    if (_selectedEquipmentFilter == 'TODOS') return true;
    final eq = (ex.equipment ?? '').toLowerCase();
    final name = ex.name.toLowerCase();
    if (_selectedEquipmentFilter == 'BARRA') return eq.contains('barra') || name.contains('barra');
    if (_selectedEquipmentFilter == 'MANCUERNA') return eq.contains('mancuerna') || name.contains('mancuerna');
    if (_selectedEquipmentFilter == 'POLEA') return eq.contains('polea') || name.contains('polea');
    if (_selectedEquipmentFilter == 'MÁQUINA') return eq.contains('maquina') || eq.contains('máquina') || name.contains('maquina') || name.contains('máquina') || name.contains('prensa');
    if (_selectedEquipmentFilter == 'CORPORAL') return eq.contains('corporal') || name.contains('dominadas') || name.contains('flexiones') || name.contains('fondos');
    return true;
  }

  bool _matchesGrip(Exercise ex) {
    if (_selectedGripFilter == 'TODOS') return true;
    final gr = (ex.grip ?? '').toLowerCase();
    final name = ex.name.toLowerCase();
    if (_selectedGripFilter == 'PRONO') return gr.contains('prono') || name.contains('prono');
    if (_selectedGripFilter == 'SUPINO') return gr.contains('supino') || name.contains('supino');
    if (_selectedGripFilter == 'NEUTRO') return gr.contains('neutro') || name.contains('neutro');
    return true;
  }

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
          if (!_matchesEquipment(ex)) return false;
          if (!_matchesGrip(ex)) return false;

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

              // Filter Chips 1: Músculos
              SizedBox(
                height: 36,
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
                          fontSize: 10,
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
              const SizedBox(height: 8),

              // Filter Chips 2: Equipamiento / Barra (Idea 5)
              SizedBox(
                height: 32,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _equipmentFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final filter = _equipmentFilters[index];
                    final isSelected = _selectedEquipmentFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter == 'TODOS' ? 'EQUIPO: TODOS' : filter,
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.amber.shade200,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.amber,
                      backgroundColor: const Color(0xFF0F172A),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: isSelected ? Colors.amber : Colors.white12,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedEquipmentFilter = filter);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Filter Chips 3: Tipo de Agarre (Idea 5)
              SizedBox(
                height: 32,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _gripFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final filter = _gripFilters[index];
                    final isSelected = _selectedGripFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter == 'TODOS' ? 'AGARRE: TODOS' : 'AGARRE: $filter',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.tealAccent.shade100,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.tealAccent,
                      backgroundColor: const Color(0xFF0F172A),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: isSelected ? Colors.tealAccent : Colors.white12,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedGripFilter = filter);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

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
                          final hasThumb = (ex.imageUrl != null && ex.imageUrl!.isNotEmpty) ||
                              (ex.gifUrl != null && ex.gifUrl!.isNotEmpty);

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
                                Row(
                                  children: [
                                    // Thumbnail de imagen al lado del nombre (Idea del usuario)
                                    if (hasThumb) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          color: const Color(0xFF1E293B),
                                          child: Image.network(
                                            ex.imageUrl?.isNotEmpty == true ? ex.imageUrl! : ex.gifUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.fitness_center,
                                              color: SystemTheme.neonCyan,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: GoogleFonts.orbitron(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (ex.equipment != null || ex.grip != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '${ex.equipment ?? "General"} • ${ex.grip ?? "Estándar"}'.toUpperCase(),
                                              style: GoogleFonts.rajdhani(
                                                fontSize: 10.5,
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
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
                                const SizedBox(height: 8),
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
