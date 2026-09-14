import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/muscle.dart';
import '../../../models/exercise.dart';
import '../../../core/theme/system_theme.dart';
import '../../../providers/game_provider.dart';
import '../../timer/widgets/rest_timer_sheet.dart';
import '../../calculator/widgets/plate_calculator_sheet.dart';
import '../../../core/calculator/one_rm_calculator.dart';

class MuscleDetailSheet extends StatefulWidget {
  final Muscle muscle;

  const MuscleDetailSheet({super.key, required this.muscle});

  @override
  State<MuscleDetailSheet> createState() => _MuscleDetailSheetState();
}

class _MuscleDetailSheetState extends State<MuscleDetailSheet> {
  Exercise? _selectedExercise;
  double _weight = 60.0;
  int _reps = 10;
  int _dropsetDrops = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final game = Provider.of<GameProvider>(context, listen: false);
    final related = game.exercises.where((e) => 
      e.primaryMuscle == widget.muscle.id || e.secondaryMuscle == widget.muscle.id
    ).toList();
    if (related.isNotEmpty) {
      _selectedExercise = related.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final currentMuscle = game.getMuscle(widget.muscle.id) ?? widget.muscle;
        final relatedExercises = game.exercises.where((e) => 
          e.primaryMuscle == currentMuscle.id || e.secondaryMuscle == currentMuscle.id
        ).toList();

        // Calculate preview XP
        double previewPrimaryXp = 0;
        double previewSecondaryXp = 0;
        if (_selectedExercise != null) {
          final xpMap = _selectedExercise!.calculateXp(
            weightKg: _weight,
            reps: _reps,
            dropsetDrops: _dropsetDrops,
          );
          previewPrimaryXp = xpMap[_selectedExercise!.primaryMuscle] ?? 0;
          if (_selectedExercise!.secondaryMuscle != null) {
            previewSecondaryXp = xpMap[_selectedExercise!.secondaryMuscle!] ?? 0;
          }
        }

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
            border: Border.all(color: currentMuscle.heatColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: currentMuscle.heatColor.withOpacity(0.2),
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
                // Top drag handle
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

                // Muscle Header
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
                              'SISTEMA // ESTADO MUSCULAR',
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
                              currentMuscle.name.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: currentMuscle.heatColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: currentMuscle.heatColor, width: 1.2),
                        ),
                        child: Text(
                          'NIVEL ${currentMuscle.level}',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: currentMuscle.heatColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'EXPERIENCIA DE ASCENSIÓN',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${currentMuscle.currentXp.toStringAsFixed(1)} / ${currentMuscle.xpForNextLevel.toStringAsFixed(0)} XP',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SystemTheme.neonCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: currentMuscle.progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFF1E293B),
                        valueColor: AlwaysStoppedAnimation<Color>(currentMuscle.heatColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Exercise Selection
                Text(
                  'EJERCICIOS ASIGNADOS AL MÚSCULO',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                if (relatedExercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No hay ejercicios registrados para este músculo aún. Añádelos desde el panel web de Python.',
                      style: GoogleFonts.rajdhani(color: Colors.white60),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Exercise>(
                        value: _selectedExercise,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF111827),
                        icon: const Icon(Icons.arrow_drop_down, color: SystemTheme.neonCyan),
                        items: relatedExercises.map((ex) {
                          return DropdownMenuItem<Exercise>(
                            value: ex,
                            child: Text(
                              ex.name,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedExercise = val;
                          });
                        },
                      ),
                    ),
                  ),

                if (_selectedExercise != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.2)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Impacto: ${_selectedExercise!.primaryXpPerKg} XP/kg (${_selectedExercise!.primaryMuscle.toUpperCase()})',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SystemTheme.neonCyan,
                          ),
                        ),
                        if (_selectedExercise!.secondaryMuscle != null)
                          Text(
                            '+${_selectedExercise!.secondaryXpPerKg} XP/kg (${_selectedExercise!.secondaryMuscle!.toUpperCase()})',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SystemTheme.electricBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Weight & Reps Input
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text('PESO (KG)', style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70)),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () async {
                                    final result = await showModalBottomSheet<double>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 650),
                                          child: PlateCalculatorSheet(initialWeight: _weight),
                                        ),
                                      ),
                                    );
                                    if (result != null && mounted) {
                                      setState(() {
                                        _weight = result;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: SystemTheme.neonCyan.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.calculate_outlined, size: 12, color: SystemTheme.neonCyan),
                                        const SizedBox(width: 3),
                                        Text(
                                          'DISCOS',
                                          style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
                                  onPressed: () => setState(() => _weight = (_weight - 2.5).clamp(0.0, 500.0)),
                                ),
                                Expanded(
                                  child: Text(
                                    '${_weight.toStringAsFixed(1)} kg',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white70, size: 16),
                                  onPressed: () => setState(() => _weight += 2.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('REPETICIONES', style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70)),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
                                  onPressed: () => setState(() => _reps = (_reps - 1).clamp(1, 100)),
                                ),
                                Expanded(
                                  child: Text(
                                    '$_reps reps',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white70, size: 16),
                                  onPressed: () => setState(() => _reps += 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 1RM Estimator & PR Info Banner
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '1RM ESTIMADO',
                                style: GoogleFonts.orbitron(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: SystemTheme.neonCyan,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '~${OneRmCalculator.estimate(weight: _weight, reps: _reps).toStringAsFixed(1)} kg',
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FutureBuilder<double>(
                        future: _selectedExercise != null
                            ? game.getMaxWeightForExercise(_selectedExercise!.id)
                            : Future.value(0.0),
                        builder: (context, snapshot) {
                          final currentPr = snapshot.data ?? 0.0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: SystemTheme.spartanGold.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.emoji_events, size: 11, color: SystemTheme.spartanGold),
                                      const SizedBox(width: 4),
                                      Text(
                                        'RÉCORD (PR)',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.spartanGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    currentPr > 0 ? '${currentPr.toStringAsFixed(1)} kg' : 'Sin registro',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: currentPr > 0 ? Colors.white : Colors.white38,
                                    ),
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

                const SizedBox(height: 14),

                // DROP SET SELECTOR (SALTOS DE PESO)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101827),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _dropsetDrops > 0 ? SystemTheme.neonCyan : Colors.white12,
                      width: _dropsetDrops > 0 ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.electric_bolt,
                            size: 15,
                            color: _dropsetDrops > 0 ? SystemTheme.neonCyan : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'DROP SET (SALTOS DE PESO)',
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _dropsetDrops > 0 ? SystemTheme.neonCyan : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildDropsetChip(0, 'Normal (x1)'),
                          _buildDropsetChip(1, '1 Salto (x2 XP)'),
                          _buildDropsetChip(2, '2 Saltos (x3 XP)'),
                          _buildDropsetChip(3, '3+ Saltos (x4 XP)'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: (_selectedExercise == null || _isSaving)
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          final exName = _selectedExercise!.name;
                          await game.logWorkout(
                            exercise: _selectedExercise!,
                            weightKg: _weight,
                            reps: _reps,
                            dropsetDrops: _dropsetDrops,
                          );
                          setState(() => _isSaving = false);
                          if (context.mounted) {
                            Navigator.pop(context);
                            // Open Rest Timer immediately
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => Align(
                                alignment: Alignment.bottomCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 650),
                                  child: RestTimerSheet(
                                    initialSeconds: 90,
                                    exerciseName: exName,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SystemTheme.neonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 10,
                    shadowColor: SystemTheme.neonCyan.withOpacity(0.5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'REGISTRAR SERIE (+${(previewPrimaryXp + previewSecondaryXp).toStringAsFixed(0)} XP)',
                          style: GoogleFonts.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropsetChip(int drops, String label) {
    final isSelected = _dropsetDrops == drops;
    return ChoiceChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      selectedColor: SystemTheme.neonCyan,
      backgroundColor: const Color(0xFF1E293B),
      side: BorderSide(
        color: isSelected ? SystemTheme.neonCyan : Colors.white24,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _dropsetDrops = drops);
        }
      },
    );
  }
}
