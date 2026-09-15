import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../models/exercise.dart';
import '../../../models/routine.dart';
import '../../../providers/game_provider.dart';

/// Modal o pantalla para crear o editar por completo una rutina personalizada,
/// con tabla interactiva de series por ejercicio (peso, reps, descanso individuales).
class RoutineEditorDialog extends StatefulWidget {
  final Routine? initialRoutine;

  const RoutineEditorDialog({super.key, this.initialRoutine});

  @override
  State<RoutineEditorDialog> createState() => _RoutineEditorDialogState();
}

class _RoutineEditorDialogState extends State<RoutineEditorDialog> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<RoutineExercise> _selectedExercises = [];
  String _searchQuery = '';
  bool _isExerciseCatalogExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialRoutine != null) {
      _nameController.text = widget.initialRoutine!.name;
      _selectedExercises.addAll(widget.initialRoutine!.exercises);
    } else {
      _nameController.text = 'Nueva Rutina';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise ex) {
    if (_selectedExercises.any((e) => e.exerciseId == ex.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${ex.name}" ya está añadido a la rutina.'),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _selectedExercises.add(
        RoutineExercise(
          exerciseId: ex.id,
          exerciseName: ex.name,
          sets: 3,
          targetWeightKg: 20.0,
          targetReps: 12,
          restSeconds: 90,
          primaryMuscle: ex.primaryMuscle,
          individualSets: [
            const RoutineSet(setNumber: 1, weightKg: 20.0, reps: 12, restSeconds: 90),
            const RoutineSet(setNumber: 2, weightKg: 20.0, reps: 12, restSeconds: 90),
            const RoutineSet(setNumber: 3, weightKg: 20.0, reps: 12, restSeconds: 90),
          ],
        ),
      );
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _addSetToExercise(int exerciseIndex) {
    final ex = _selectedExercises[exerciseIndex];
    final lastSet = ex.individualSets.isNotEmpty
        ? ex.individualSets.last
        : const RoutineSet(setNumber: 1, weightKg: 20.0, reps: 12, restSeconds: 90);
    final newSet = RoutineSet(
      setNumber: ex.individualSets.length + 1,
      weightKg: lastSet.weightKg,
      reps: lastSet.reps,
      restSeconds: lastSet.restSeconds,
    );
    final updatedSets = List<RoutineSet>.from(ex.individualSets)..add(newSet);
    setState(() {
      _selectedExercises[exerciseIndex] = ex.copyWith(
        individualSets: updatedSets,
        sets: updatedSets.length,
      );
    });
  }

  void _removeSetFromExercise(int exerciseIndex, int setIndex) {
    final ex = _selectedExercises[exerciseIndex];
    if (ex.individualSets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un ejercicio debe tener al menos 1 serie.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final updatedSets = List<RoutineSet>.from(ex.individualSets)..removeAt(setIndex);
    final reindexed = List.generate(
      updatedSets.length,
      (i) => updatedSets[i].copyWith(setNumber: i + 1),
    );
    setState(() {
      _selectedExercises[exerciseIndex] = ex.copyWith(
        individualSets: reindexed,
        sets: reindexed.length,
      );
    });
  }

  void _updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    final ex = _selectedExercises[exerciseIndex];
    final updatedSets = List<RoutineSet>.from(ex.individualSets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(weightKg: weight);
    setState(() {
      _selectedExercises[exerciseIndex] = ex.copyWith(individualSets: updatedSets);
    });
  }

  void _updateSetReps(int exerciseIndex, int setIndex, int reps) {
    final ex = _selectedExercises[exerciseIndex];
    final updatedSets = List<RoutineSet>.from(ex.individualSets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(reps: reps);
    setState(() {
      _selectedExercises[exerciseIndex] = ex.copyWith(individualSets: updatedSets);
    });
  }

  void _updateSetRest(int exerciseIndex, int setIndex, int restSeconds) {
    final ex = _selectedExercises[exerciseIndex];
    final updatedSets = List<RoutineSet>.from(ex.individualSets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(restSeconds: restSeconds);
    setState(() {
      _selectedExercises[exerciseIndex] = ex.copyWith(individualSets: updatedSets);
    });
  }

  void _saveRoutine() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un nombre para la rutina.'),
          backgroundColor: SystemTheme.dangerRed,
        ),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un ejercicio a la rutina.'),
          backgroundColor: SystemTheme.dangerRed,
        ),
      );
      return;
    }

    final game = context.read<GameProvider>();
    final routineId = widget.initialRoutine?.id ?? 'routine_${DateTime.now().millisecondsSinceEpoch}';
    final userId = game.currentUser?.id ?? 'main_hunter';

    final routine = Routine(
      id: routineId,
      userId: userId,
      name: name,
      exercises: _selectedExercises,
      createdAt: widget.initialRoutine?.createdAt ?? DateTime.now().toIso8601String(),
    );

    await game.saveRoutine(routine);

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rutina "$name" guardada exitosamente.'),
          backgroundColor: SystemTheme.neonCyan.withOpacity(0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final allExercises = game.exercises;
    final query = _searchQuery.trim().toLowerCase();
    final displayedExercises = query.isEmpty
        ? allExercises
        : allExercises
            .where((e) =>
                e.name.toLowerCase().contains(query) ||
                e.primaryMuscle.toLowerCase().contains(query))
            .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 850),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: SystemTheme.neonCyan.withOpacity(0.12),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: SystemTheme.neonCyan, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.initialRoutine == null ? 'CREAR RUTINA' : 'EDITAR RUTINA',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // FORM BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE DE LA RUTINA
                    Text(
                      'NOMBRE DE LA RUTINA',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ej: Día de Pecho, Pierna Olímpica...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: SystemTheme.neonCyan),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // CATÁLOGO DE EJERCICIOS PARA AÑADIR (SIEMPRE DISPONIBLES)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search, color: SystemTheme.neonCyan, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'CATÁLOGO DE EJERCICIOS (${displayedExercises.length})',
                              style: GoogleFonts.orbitron(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: SystemTheme.neonCyan,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isExerciseCatalogExpanded = !_isExerciseCatalogExpanded),
                          child: Text(
                            _isExerciseCatalogExpanded ? 'Ocultar catálogo ▲' : 'Mostrar catálogo ▼',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // BUSCADOR CON LUPA
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.rajdhani(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Filtrar por nombre o músculo (o selecciona de la lista)...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: SystemTheme.neonCyan, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // LISTA DE EJERCICIOS (TODOS DISPONIBLES POR DEFECTO)
                    if (_isExerciseCatalogExpanded) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C31),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
                        ),
                        child: displayedExercises.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay ejercicios con ese criterio.',
                                  style: GoogleFonts.rajdhani(color: Colors.white54),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                itemCount: displayedExercises.length,
                                separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                                itemBuilder: (context, idx) {
                                  final ex = displayedExercises[idx];
                                  final isAlreadyAdded = _selectedExercises.any((e) => e.exerciseId == ex.id);

                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      isAlreadyAdded ? Icons.check_circle : Icons.add_circle_outline,
                                      color: isAlreadyAdded ? Colors.greenAccent : SystemTheme.neonCyan,
                                      size: 20,
                                    ),
                                    title: Text(
                                      ex.name,
                                      style: GoogleFonts.rajdhani(
                                        fontWeight: FontWeight.bold,
                                        color: isAlreadyAdded ? Colors.white54 : Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Músculo: ${ex.primaryMuscle.toUpperCase()}',
                                      style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11),
                                    ),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAlreadyAdded
                                            ? Colors.white12
                                            : SystemTheme.neonCyan.withOpacity(0.2),
                                        foregroundColor: isAlreadyAdded ? Colors.white38 : SystemTheme.neonCyan,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          side: BorderSide(
                                            color: isAlreadyAdded
                                                ? Colors.white24
                                                : SystemTheme.neonCyan.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      onPressed: isAlreadyAdded ? null : () => _addExercise(ex),
                                      child: Text(
                                        isAlreadyAdded ? 'Añadido' : '+ Añadir',
                                        style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // EJERCICIOS EN LA RUTINA CON TABLA DE SERIES PERSONALIZADAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EJERCICIOS CONFIGURADOS (${_selectedExercises.length})',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                        if (_selectedExercises.isNotEmpty)
                          Text(
                            'Personaliza cada serie',
                            style: GoogleFonts.rajdhani(fontSize: 11, color: SystemTheme.spartanGold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_selectedExercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C31),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.playlist_add, color: Colors.white38, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Aún no has añadido ejercicios.',
                                style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Selecciona ejercicios del catálogo superior para configurar series, peso y descanso.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedExercises.length,
                        itemBuilder: (context, exIdx) {
                          final item = _selectedExercises[exIdx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131C31),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: SystemTheme.neonCyan.withOpacity(0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CABECERA DEL EJERCICIO
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: SystemTheme.neonCyan.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.6)),
                                      ),
                                      child: Text(
                                        '#${exIdx + 1}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.neonCyan,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.exerciseName,
                                            style: GoogleFonts.orbitron(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Músculo: ${item.primaryMuscle.toUpperCase()} • ${item.individualSets.length} series',
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 11,
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                      tooltip: 'Eliminar ejercicio',
                                      onPressed: () => _removeExercise(exIdx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // TABLA DE SERIES PERSONALIZADAS
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A0F1D),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Column(
                                    children: [
                                      // HEADER DE LA TABLA
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B).withOpacity(0.6),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 48,
                                              child: Text(
                                                'SERIE',
                                                style: GoogleFonts.orbitron(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: SystemTheme.neonCyan,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'PESO (KG)',
                                                  style: GoogleFonts.orbitron(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'REPS',
                                                  style: GoogleFonts.orbitron(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 86,
                                              child: Center(
                                                child: Text(
                                                  'DESCANSO',
                                                  style: GoogleFonts.orbitron(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 36),
                                          ],
                                        ),
                                      ),

                                      // FILAS DE CADA SERIE
                                      ...item.individualSets.asMap().entries.map((entry) {
                                        final setIdx = entry.key;
                                        final routineSet = entry.value;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(color: Colors.white.withOpacity(0.05)),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // NÚMERO DE SERIE
                                              SizedBox(
                                                width: 48,
                                                child: Text(
                                                  '#${routineSet.setNumber}',
                                                  style: GoogleFonts.orbitron(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: SystemTheme.spartanGold,
                                                  ),
                                                ),
                                              ),

                                              // PESO EDITABLE
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: _buildInlineNumberInput(
                                                    initialValue: routineSet.weightKg.toStringAsFixed(
                                                        routineSet.weightKg.truncateToDouble() == routineSet.weightKg
                                                            ? 0
                                                            : 1),
                                                    onChanged: (val) {
                                                      final parsed = double.tryParse(val);
                                                      if (parsed != null && parsed >= 0) {
                                                        _updateSetWeight(exIdx, setIdx, parsed);
                                                      }
                                                    },
                                                    suffix: 'kg',
                                                  ),
                                                ),
                                              ),

                                              // REPETICIONES EDITABLES
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: _buildInlineNumberInput(
                                                    initialValue: routineSet.reps.toString(),
                                                    onChanged: (val) {
                                                      final parsed = int.tryParse(val);
                                                      if (parsed != null && parsed > 0) {
                                                        _updateSetReps(exIdx, setIdx, parsed);
                                                      }
                                                    },
                                                    suffix: 'reps',
                                                  ),
                                                ),
                                              ),

                                              // DESCANSO EDITABLE (DROPDOWN O DIALOG)
                                              SizedBox(
                                                width: 86,
                                                child: _buildInlineRestSelector(
                                                  currentSeconds: routineSet.restSeconds,
                                                  onChanged: (val) => _updateSetRest(exIdx, setIdx, val),
                                                ),
                                              ),

                                              // BOTÓN BORRAR SERIE
                                              SizedBox(
                                                width: 36,
                                                child: IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline,
                                                      color: Colors.redAccent, size: 18),
                                                  tooltip: 'Quitar serie',
                                                  onPressed: () => _removeSetFromExercise(exIdx, setIdx),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // BOTÓN "+ AÑADIR SERIE"
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: SystemTheme.neonCyan,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: Text(
                                      '+ Añadir Serie',
                                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => _addSetToExercise(exIdx),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // FOOTER: BOTÓN GUARDAR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('CANCELAR', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SystemTheme.neonCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                      ),
                      onPressed: _saveRoutine,
                      child: Text(
                        'GUARDAR RUTINA',
                        style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineNumberInput({
    required String initialValue,
    required ValueChanged<String> onChanged,
    required String suffix,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: TextFormField(
          initialValue: initialValue,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            suffixText: suffix,
            suffixStyle: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white38),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInlineRestSelector({
    required int currentSeconds,
    required ValueChanged<int> onChanged,
  }) {
    final validValues = [30, 45, 60, 90, 120, 150, 180];
    final value = validValues.contains(currentSeconds) ? currentSeconds : 90;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          isExpanded: true,
          underline: const SizedBox(),
          dropdownColor: const Color(0xFF131C31),
          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 16),
          items: const [
            DropdownMenuItem(value: 30, child: Text('30s')),
            DropdownMenuItem(value: 45, child: Text('45s')),
            DropdownMenuItem(value: 60, child: Text('60s')),
            DropdownMenuItem(value: 90, child: Text('90s')),
            DropdownMenuItem(value: 120, child: Text('2m')),
            DropdownMenuItem(value: 150, child: Text('2.5m')),
            DropdownMenuItem(value: 180, child: Text('3m')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
