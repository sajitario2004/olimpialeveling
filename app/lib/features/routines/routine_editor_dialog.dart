import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../models/exercise.dart';
import '../../../models/routine.dart';
import '../../../providers/game_provider.dart';

/// Modal o pantalla para crear o editar por completo una rutina personalizada.
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
        ),
      );
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
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
    final filteredExercises = _searchQuery.isEmpty
        ? []
        : allExercises
            .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.primaryMuscle.toLowerCase().contains(_searchQuery.toLowerCase()))
            .take(5)
            .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
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
                        hintText: 'Ej: Día de Pecho, Día de Pierna...',
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

                    // BUSCADOR DE EJERCICIOS PARA AÑADIR
                    Text(
                      'BUSCAR Y AÑADIR EJERCICIOS',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.rajdhani(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe para buscar (ej: press, sentadilla, curl)...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: SystemTheme.neonCyan, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // LISTA DE SUGERENCIAS DE BÚSQUEDA
                    if (filteredExercises.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C31),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: filteredExercises.map((ex) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.add_circle_outline, color: SystemTheme.neonCyan, size: 20),
                              title: Text(
                                ex.name,
                                style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Músculo: ${ex.primaryMuscle.toUpperCase()}',
                                style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 11),
                              ),
                              onTap: () => _addExercise(ex),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // EJERCICIOS AÑADIDOS A LA RUTINA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EJERCICIOS EN ESTA RUTINA (${_selectedExercises.length})',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_selectedExercises.isNotEmpty)
                          Text(
                            'Configura series y descanso',
                            style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white54),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_selectedExercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C31),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Center(
                          child: Text(
                            'Aún no has añadido ejercicios.\nUsa el buscador superior para agregar ejercicios a tu rutina.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedExercises.length,
                        itemBuilder: (context, index) {
                          final item = _selectedExercises[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131C31),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SystemTheme.neonCyan.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: SystemTheme.neonCyan,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.exerciseName,
                                        style: GoogleFonts.orbitron(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      tooltip: 'Quitar',
                                      onPressed: () => _removeExercise(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // CONFIGURACIÓN: SERIES, PESO, REPS, DESCANSO
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    // SERIES
                                    _buildNumberField(
                                      label: 'Series',
                                      value: item.sets.toString(),
                                      onChanged: (val) {
                                        final parsed = int.tryParse(val);
                                        if (parsed != null && parsed > 0) {
                                          setState(() {
                                            _selectedExercises[index] = item.copyWith(sets: parsed);
                                          });
                                        }
                                      },
                                    ),
                                    // PESO OBJETIVO
                                    _buildNumberField(
                                      label: 'Peso (kg)',
                                      value: item.targetWeightKg.toStringAsFixed(0),
                                      onChanged: (val) {
                                        final parsed = double.tryParse(val);
                                        if (parsed != null && parsed >= 0) {
                                          setState(() {
                                            _selectedExercises[index] = item.copyWith(targetWeightKg: parsed);
                                          });
                                        }
                                      },
                                    ),
                                    // REPETICIONES
                                    _buildNumberField(
                                      label: 'Reps',
                                      value: item.targetReps.toString(),
                                      onChanged: (val) {
                                        final parsed = int.tryParse(val);
                                        if (parsed != null && parsed > 0) {
                                          setState(() {
                                            _selectedExercises[index] = item.copyWith(targetReps: parsed);
                                          });
                                        }
                                      },
                                    ),
                                    // TIEMPO DE DESCANSO
                                    _buildRestPicker(
                                      label: 'Descanso',
                                      currentSeconds: item.restSeconds,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedExercises[index] = item.copyWith(restSeconds: val);
                                        });
                                      },
                                    ),
                                  ],
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
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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

  Widget _buildNumberField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white60)),
          TextFormField(
            initialValue: value,
            keyboardType: TextInputType.number,
            style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRestPicker({
    required String label,
    required int currentSeconds,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white60)),
          DropdownButton<int>(
            value: [60, 90, 120, 150, 180].contains(currentSeconds) ? currentSeconds : 90,
            isDense: true,
            isExpanded: true,
            dropdownColor: const Color(0xFF131C31),
            underline: const SizedBox(),
            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan),
            items: const [
              DropdownMenuItem(value: 60, child: Text('1:00 min')),
              DropdownMenuItem(value: 90, child: Text('1:30 min')),
              DropdownMenuItem(value: 120, child: Text('2:00 min')),
              DropdownMenuItem(value: 150, child: Text('2:30 min')),
              DropdownMenuItem(value: 180, child: Text('3:00 min')),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
