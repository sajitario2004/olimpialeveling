import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/theme/system_theme.dart';
import '../../../core/audio/audio_service.dart';
import '../../../models/exercise.dart';
import '../../../models/routine.dart';
import '../../../providers/game_provider.dart';
import '../calculator/widgets/plate_calculator_sheet.dart';

/// Pantalla de sesión activa de entrenamiento guiada ejercicio por ejercicio y serie por serie.
class RoutineSessionScreen extends StatefulWidget {
  final Routine routine;

  const RoutineSessionScreen({super.key, required this.routine});

  @override
  State<RoutineSessionScreen> createState() => _RoutineSessionScreenState();
}

class _RoutineSessionScreenState extends State<RoutineSessionScreen> {
  late List<RoutineExercise> _exercises;
  int _exerciseIndex = 0;
  int _currentSet = 1;

  // Estado de pausa de emergencia (Idea 20)
  bool _isPaused = false;

  // Estado dentro de la serie
  bool _isReviewingSet = false; // El usuario pulsó "Terminar Serie" y está ajustando repeticiones/descanso
  bool _isResting = false;      // El temporizador de descanso está contando
  int _restSecondsRemaining = 0;
  Timer? _timer;

  // Tipo de serie actual: 'normal', 'calentamiento', 'fallo' (Idea 3: x2 XP al fallo)
  String _currentSetType = 'normal';

  // Valores de la serie actual
  late int _actualReps;
  late double _actualWeight;
  int _addedBonusRest = 0;
  int _dropsetDrops = 0;

  // Undo / Deshacer última serie completada (Idea 7)
  Map<String, dynamic>? _lastLoggedSetSnapshot;

  // Estadísticas acumuladas de la sesión
  double _sessionTotalXp = 0.0;
  int _totalSetsCompleted = 0;
  bool _isFinished = false;
  late DateTime _sessionStartTime;
  bool _recordedCompletion = false;

  RoutineExercise get _currentRoutineExercise => _exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.routine.exercises);
    _sessionStartTime = DateTime.now();
    _resetCurrentSetValues();

    // Pantalla activa (Wake Lock - Idea 16)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = context.read<GameProvider>();
      if (game.wakeLockEnabled) {
        WakelockPlus.enable();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _resetCurrentSetValues() {
    final current = _currentRoutineExercise;
    final setConfig = current.getSet(_currentSet);
    _actualReps = setConfig.reps;
    _actualWeight = setConfig.weightKg;
    _currentSetType = setConfig.setType;
    _addedBonusRest = 0;
    _dropsetDrops = 0;
  }

  void _onFinishSetPressed() {
    setState(() {
      _isReviewingSet = true;
    });
  }

  void _addBonusRestTime(int seconds) {
    setState(() {
      _addedBonusRest += seconds;
      if (_isResting) {
        _restSecondsRemaining += seconds;
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$seconds s añadidos al descanso'),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: SystemTheme.neonCyan.withOpacity(0.9),
      ),
    );
  }

  void _proceedToNextSetWithRest() async {
    final game = context.read<GameProvider>();
    final currentEx = _currentRoutineExercise;

    // Buscar el Exercise completo en la biblioteca
    final fullExercise = game.exercises.firstWhere(
      (e) => e.id == currentEx.exerciseId,
      orElse: () => Exercise(
        id: currentEx.exerciseId,
        name: currentEx.exerciseName,
        description: '',
        primaryMuscle: currentEx.primaryMuscle,
        primaryXpPerKg: 5.0,
      ),
    );

    // Sumar los puntos de XP correspondientes a los músculos (con x2 XP al fallo - Idea 3)
    await game.logWorkout(
      exercise: fullExercise,
      weightKg: _actualWeight,
      reps: _actualReps,
      dropsetDrops: _dropsetDrops,
      setType: _currentSetType,
    );

    // Reproducir feedback sonoro
    AudioService.instance.playLevelUp();

    final xpGainMap = fullExercise.calculateXp(
      weightKg: _actualWeight,
      reps: _actualReps,
      dropsetDrops: _dropsetDrops,
      setType: _currentSetType,
    );
    final xpGain = xpGainMap.values.fold(0.0, (a, b) => a + b);

    // Guardar snapshot para Deshacer (Undo - Idea 7)
    _lastLoggedSetSnapshot = {
      'exercise': fullExercise,
      'weightKg': _actualWeight,
      'reps': _actualReps,
      'dropsetDrops': _dropsetDrops,
      'setType': _currentSetType,
      'xpGain': xpGain,
      'exerciseIndex': _exerciseIndex,
      'currentSet': _currentSet,
    };

    _sessionTotalXp += xpGain;
    _totalSetsCompleted += 1;

    // Detector de Récord Personal (Idea 14)
    if (game.prAlert != null && mounted) {
      final prMsg = game.prAlert!;
      game.clearPrAlert();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF131C31),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SystemTheme.spartanGold, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.bolt, color: SystemTheme.spartanGold, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡RÉCORD PERSONAL!',
                  style: GoogleFonts.orbitron(color: SystemTheme.spartanGold, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            prMsg,
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.spartanGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text('¡BENDICIÓN DIVINA!', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    // Iniciar cuenta atrás del temporizador de descanso
    final setConfig = currentEx.getSet(_currentSet);
    final totalRest = setConfig.restSeconds + _addedBonusRest;
    setState(() {
      _isReviewingSet = false;
      _isResting = true;
      _restSecondsRemaining = totalRest;
    });

    _startRestTimer();
  }

  // Deshacer última serie (Idea 7)
  void _undoLastSet() async {
    if (_lastLoggedSetSnapshot == null) return;
    final snapshot = _lastLoggedSetSnapshot!;
    final game = context.read<GameProvider>();
    await game.undoLastWorkout(
      exercise: snapshot['exercise'] as Exercise,
      weightKg: snapshot['weightKg'] as double,
      reps: snapshot['reps'] as int,
      dropsetDrops: snapshot['dropsetDrops'] as int,
      setType: snapshot['setType'] as String,
    );

    setState(() {
      _sessionTotalXp = (_sessionTotalXp - (snapshot['xpGain'] as double)).clamp(0.0, double.infinity);
      _totalSetsCompleted = (_totalSetsCompleted - 1).clamp(0, 9999);
      _exerciseIndex = snapshot['exerciseIndex'] as int;
      _currentSet = snapshot['currentSet'] as int;
      _timer?.cancel();
      _isResting = false;
      _isReviewingSet = false;
      _lastLoggedSetSnapshot = null;
      _resetCurrentSetValues();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Serie deshecha. Se ha revertido la XP ganada.', style: GoogleFonts.rajdhani()),
          backgroundColor: Colors.amber.shade900,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Sustituir ejercicio por alternativa (Idea 11)
  void _openSubstituteExerciseModal() {
    final game = context.read<GameProvider>();
    final currentMuscle = _currentRoutineExercise.primaryMuscle.toLowerCase();
    final alternatives = game.exercises.where((e) =>
      e.primaryMuscle.toLowerCase() == currentMuscle &&
      e.id != _currentRoutineExercise.exerciseId
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: SystemTheme.neonCyan, width: 1.2),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                'SUSTITUIR POR ALTERNATIVA',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SystemTheme.neonCyan,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ejercicios alternativos para ${currentMuscle.toUpperCase()}:',
                style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (alternatives.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No hay más ejercicios para este grupo muscular en la biblioteca.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: Colors.white38),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: alternatives.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (c, idx) {
                      final alt = alternatives[idx];
                      return ListTile(
                        leading: (alt.imageUrl != null && alt.imageUrl!.isNotEmpty) ||
                                (alt.gifUrl != null && alt.gifUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  alt.imageUrl?.isNotEmpty == true ? alt.imageUrl! : alt.gifUrl!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: SystemTheme.neonCyan),
                                ),
                              )
                            : const Icon(Icons.fitness_center, color: SystemTheme.neonCyan),
                        title: Text(alt.name, style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Equipo: ${(alt.equipment ?? "Libre").toUpperCase()}', style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemTheme.neonCyan.withOpacity(0.2),
                            foregroundColor: SystemTheme.neonCyan,
                          ),
                          onPressed: () {
                            final oldSets = _currentRoutineExercise.individualSets;
                            setState(() {
                              _exercises[_exerciseIndex] = RoutineExercise(
                                exerciseId: alt.id,
                                exerciseName: alt.name,
                                primaryMuscle: alt.primaryMuscle,
                                sets: _currentRoutineExercise.sets,
                                targetReps: _currentRoutineExercise.targetReps,
                                targetWeightKg: _currentRoutineExercise.targetWeightKg,
                                restSeconds: _currentRoutineExercise.restSeconds,
                                notes: _currentRoutineExercise.notes,
                                imageUrl: alt.imageUrl ?? alt.gifUrl ?? '',
                                individualSets: oldSets,
                              );
                              _resetCurrentSetValues();
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ejercicio sustituido por ${alt.name}'),
                                backgroundColor: SystemTheme.neonCyan.withOpacity(0.8),
                              ),
                            );
                          },
                          child: Text('Sustituir', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
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

  // Notas del ejercicio (Idea 9)
  void _openExerciseNotesDialog() {
    final current = _currentRoutineExercise;
    final ctrl = TextEditingController(text: current.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131C31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: SystemTheme.neonCyan)),
        title: Row(
          children: [
            const Icon(Icons.sticky_note_2, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Notas: ${current.exerciseName}',
                style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: GoogleFonts.rajdhani(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Añade sensaciones, ajuste de máquina o técnica...',
            hintStyle: TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Color(0xFF1E293B),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SystemTheme.neonCyan, foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _exercises[_exerciseIndex] = current.copyWith(notes: ctrl.text.trim());
              });
              Navigator.pop(ctx);
            },
            child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Calculadora inversa de discos (Idea 4)
  void _openPlateCalculator() async {
    final double? chosenWeight = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlateCalculatorSheet(initialWeight: _actualWeight),
    );
    if (chosenWeight != null && chosenWeight > 0) {
      setState(() {
        _actualWeight = chosenWeight;
      });
    }
  }

  void _showRoutineOverviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: SystemTheme.neonCyan, width: 1.2),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'TABLA COMPLETA DE LA RUTINA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: SystemTheme.neonCyan,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.routine.exercises.asMap().entries.map((entry) {
                    final exIndex = entry.key;
                    final ex = entry.value;
                    final isCurrentEx = exIndex == _exerciseIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C31),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrentEx ? SystemTheme.neonCyan : Colors.white12,
                          width: isCurrentEx ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${exIndex + 1} ${ex.exerciseName}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentEx ? SystemTheme.neonCyan : Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                ex.primaryMuscle.toUpperCase(),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...ex.individualSets.map((s) {
                            final isDone = exIndex < _exerciseIndex || (isCurrentEx && s.setNumber < _currentSet);
                            final isRunning = isCurrentEx && s.setNumber == _currentSet;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Serie ${s.setNumber}: ${s.weightKg} kg x ${s.reps} reps (pausa ${s.restSeconds}s)',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 13,
                                      color: isRunning ? SystemTheme.neonCyan : (isDone ? Colors.greenAccent : Colors.white70),
                                      fontWeight: isRunning ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isDone)
                                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14)
                                  else if (isRunning)
                                    Text('EN CURSO', style: GoogleFonts.orbitron(color: SystemTheme.neonCyan, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startRestTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_isPaused) return; // Congela el temporizador durante la pausa de emergencia (Idea 20)

      if (_restSecondsRemaining > 1) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        _timer?.cancel();
        // Vibración háptica diferenciada al finalizar el descanso (Idea 19)
        final game = context.read<GameProvider>();
        if (game.restVibrationEnabled) {
          HapticFeedback.heavyImpact();
          HapticFeedback.vibrate();
        }
        AudioService.instance.playPenaltyAlert();
        _advanceToNextSetOrExercise();
      }
    });
  }

  void _skipRestAndStartNow() {
    _timer?.cancel();
    _advanceToNextSetOrExercise();
  }

  void _advanceToNextSetOrExercise() {
    _timer?.cancel();
    final currentEx = _currentRoutineExercise;

    if (_currentSet < currentEx.sets) {
      // Siguiente serie del mismo ejercicio
      setState(() {
        _currentSet++;
        _isResting = false;
        _isReviewingSet = false;
        _resetCurrentSetValues();
      });
    } else {
      // Pasamos al siguiente ejercicio de la rutina
      if (_exerciseIndex < _exercises.length - 1) {
        setState(() {
          _exerciseIndex++;
          _currentSet = 1;
          _isResting = false;
          _isReviewingSet = false;
          _resetCurrentSetValues();
        });
      } else {
        // ¡RUTINA COMPLETADA!
        setState(() {
          _isResting = false;
          _isReviewingSet = false;
          _isFinished = true;
        });

        // Registrar en historial de rutinas completadas (Idea 1)
        if (!_recordedCompletion) {
          _recordedCompletion = true;
          final durationSec = DateTime.now().difference(_sessionStartTime).inSeconds;
          context.read<GameProvider>().recordCompletedRoutine(
            routineId: widget.routine.id,
            routineName: widget.routine.name,
            durationSeconds: durationSec,
            totalXp: _sessionTotalXp,
            exercisesCount: _exercises.length,
            setsCount: _totalSetsCompleted,
          );
        }
      }
    }
  }

  String _formatSeconds(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildFinishedSummary();
    }
    if (_isPaused) {
      return _buildPausedView();
    }

    final current = _currentRoutineExercise;
    final totalExercises = _exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1322),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF131C31),
                title: Text('¿Salir de la sesión?', style: GoogleFonts.orbitron(color: Colors.white)),
                content: Text(
                  'El progreso completado hasta ahora ya ha sido sumado a tus músculos.',
                  style: GoogleFonts.rajdhani(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('CONTINUAR RUTINA', style: GoogleFonts.orbitron(color: SystemTheme.neonCyan)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('SALIR', style: GoogleFonts.orbitron(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.routine.name.toUpperCase(),
              style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan),
            ),
            Text(
              'Ejercicio ${_exerciseIndex + 1} de $totalExercises',
              style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
        actions: [
          // Pausar sesión (Idea 20)
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: SystemTheme.spartanGold),
            tooltip: 'Pausar sesión (Emergencia)',
            onPressed: () => setState(() => _isPaused = true),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined, color: SystemTheme.neonCyan),
            tooltip: 'Ver tabla de la rutina',
            onPressed: () => _showRoutineOverviewModal(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '+${_sessionTotalXp.toStringAsFixed(0)} XP',
                style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // BARRA DE PROGRESO DE LA RUTINA
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ((_exerciseIndex * current.sets) + _currentSet - 1) /
                      (totalExercises * current.sets),
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(SystemTheme.neonCyan),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),

              // CONTENIDO PRINCIPAL DEPENDIENDO DEL ESTADO
              Expanded(
                child: _isResting
                    ? _buildRestingView()
                    : _isReviewingSet
                        ? _buildReviewingView()
                        : _buildActiveSetView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PANTALLA DE PAUSA DE EMERGENCIA (Idea 20)
  Widget _buildPausedView() {
    final current = _currentRoutineExercise;
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SystemTheme.spartanGold.withOpacity(0.15),
                  border: Border.all(color: SystemTheme.spartanGold, width: 2),
                ),
                child: const Icon(Icons.pause, color: SystemTheme.spartanGold, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'SESIÓN EN PAUSA',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SystemTheme.spartanGold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'LOS DIOSES DEL OLIMPO ESPERAN',
                style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white54, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'El cronómetro y los descansos están congelados. Tómate el respiro que necesites sin penalizaciones.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Text(
                      current.exerciseName,
                      style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Serie $_currentSet de ${current.sets} • ${_actualWeight.toStringAsFixed(1)} kg x $_actualReps reps',
                      style: GoogleFonts.rajdhani(fontSize: 13, color: SystemTheme.neonCyan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SystemTheme.neonCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: Text(
                    'REANUDAR ENTRENAMIENTO',
                    style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => setState(() => _isPaused = false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ESTADO 1: Realizando la serie con tabla de series
  Widget _buildActiveSetView() {
    final current = _currentRoutineExercise;
    final setConfig = current.getSet(_currentSet);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: SystemTheme.neonCyan.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5)),
          ),
          child: Text(
            'SERIE $_currentSet DE ${current.sets}',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: SystemTheme.neonCyan,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // CABECERA DEL EJERCICIO CON MINIATURA (Idea de usuario)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (current.imageUrl != null && current.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  color: const Color(0xFF1E293B),
                  child: Image.network(
                    current.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, size: 18, color: SystemTheme.neonCyan),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                current.exerciseName,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'MÚSCULO: ${current.primaryMuscle.toUpperCase()}',
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 6),

        // ACCIONES RÁPIDAS: SUSTITUIR, NOTAS, CALCULADORA
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: SystemTheme.neonCyan,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: Text('Sustituir', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
              onPressed: _openSubstituteExerciseModal,
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: current.notes.isNotEmpty ? Colors.amber : Colors.white60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(current.notes.isNotEmpty ? Icons.sticky_note_2 : Icons.note_add_outlined, size: 16),
              label: Text(current.notes.isNotEmpty ? 'Ver Nota' : '+ Nota', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
              onPressed: _openExerciseNotesDialog,
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: SystemTheme.spartanGold,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.calculate_outlined, size: 16),
              label: Text('Discos', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
              onPressed: _openPlateCalculator,
            ),
          ],
        ),

        // NOTA DEL EJERCICIO SI TIENE (Idea 9)
        if (current.notes.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sticky_note_2, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Nota: ${current.notes}',
                    style: GoogleFonts.rajdhani(color: Colors.amber, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],

        // SUGERENCIA SOBRECARGA PROGRESIVA (Idea 15)
        if (_currentSet > 1) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SystemTheme.spartanGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SystemTheme.spartanGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: SystemTheme.spartanGold, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Sobrecarga progresiva: +2.5 kg o +1 rep si alcanzaste la serie previa',
                  style: GoogleFonts.rajdhani(fontSize: 11, color: SystemTheme.spartanGold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],

        // SELECTOR DE TIPO DE SERIE (NORMAL / CALENTAMIENTO / FALLO X2 XP) (Idea 3)
        _buildSetTypeSelector(),

        // TARJETA DE PESO Y REPETICIONES OBJETIVO DE ESTA SERIE ESPECÍFICA
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _openPlateCalculator,
              borderRadius: BorderRadius.circular(14),
              child: _buildStatBox(
                label: 'PESO OBJETIVO',
                value: '${setConfig.weightKg.toStringAsFixed(setConfig.weightKg.truncateToDouble() == setConfig.weightKg ? 0 : 1)} kg',
                icon: Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 14),
            _buildStatBox(
              label: 'REPETICIONES',
              value: '${setConfig.reps} reps',
              icon: Icons.repeat,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(
              'Descanso programado: ${_formatSeconds(setConfig.restSeconds)} min',
              style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // TABLA VISUAL DE TODAS LAS SERIES DEL EJERCICIO
        Expanded(
          child: _buildSetsTable(current),
        ),

        // BOTÓN UNDO RÁPIDO SI HAY SERIE PREVIA (Idea 7)
        if (_lastLoggedSetSnapshot != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.undo, size: 15),
              label: Text(
                'Deshacer última serie (#${_lastLoggedSetSnapshot!["currentSet"]})',
                style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              onPressed: _undoLastSet,
            ),
          ),
        ],

        const SizedBox(height: 8),

        // BOTÓN: TERMINAR SERIE
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SystemTheme.neonCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: SystemTheme.neonCyan.withOpacity(0.5),
            ),
            onPressed: _onFinishSetPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 24),
                const SizedBox(width: 10),
                Text(
                  'TERMINAR SERIE',
                  style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildSetTypeOption(
            type: 'normal',
            label: 'NORMAL',
            badge: 'x1 XP',
            color: SystemTheme.neonCyan,
          ),
          _buildSetTypeOption(
            type: 'calentamiento',
            label: 'CALENT.',
            badge: 'x0.5 XP',
            color: Colors.amber,
          ),
          _buildSetTypeOption(
            type: 'fallo',
            label: 'AL FALLO',
            badge: 'x2 XP ⚡',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSetTypeOption({
    required String type,
    required String label,
    required String badge,
    required Color color,
  }) {
    final isSelected = _currentSetType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentSetType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.22) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 9.0,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white60,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                badge,
                style: GoogleFonts.rajdhani(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetsTable(RoutineExercise current) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text('SERIE', style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan)),
                ),
                Expanded(
                  child: Center(
                    child: Text('PESO', style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('REPS', style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ),
                SizedBox(
                  width: 58,
                  child: Center(
                    child: Text('PAUSA', style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ),
                SizedBox(
                  width: 78,
                  child: Center(
                    child: Text('ESTADO', style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: current.individualSets.length,
              itemBuilder: (context, idx) {
                final s = current.individualSets[idx];
                final isCurrent = s.setNumber == _currentSet;
                final isDone = s.setNumber < _currentSet;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? SystemTheme.neonCyan.withOpacity(0.12) : Colors.transparent,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      left: isCurrent ? const BorderSide(color: SystemTheme.neonCyan, width: 3.5) : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          '#${s.setNumber}',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? SystemTheme.neonCyan : (isDone ? Colors.greenAccent : Colors.white60),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${s.weightKg.toStringAsFixed(s.weightKg.truncateToDouble() == s.weightKg ? 0 : 1)} kg',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${s.reps}',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 58,
                        child: Center(
                          child: Text(
                            '${s.restSeconds}s',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 78,
                        child: Center(
                          child: isDone
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                    SizedBox(width: 4),
                                    Text('LISTO', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : isCurrent
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SystemTheme.neonCyan.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: SystemTheme.neonCyan, width: 1),
                                      ),
                                      child: Text('ACTUAL', style: GoogleFonts.orbitron(color: SystemTheme.neonCyan, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                    )
                                  : Text('PENDIENTE', style: GoogleFonts.rajdhani(color: Colors.white30, fontSize: 10)),
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
  }

  /// ESTADO 2: Ajuste de repeticiones reales, peso y botón +15s
  Widget _buildReviewingView() {
    final current = _currentRoutineExercise;
    final setConfig = current.getSet(_currentSet);
    final totalRestPreview = setConfig.restSeconds + _addedBonusRest;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CONFIGURAR SERIE Y DESCANSO',
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajusta si hiciste menos o más repeticiones o añade tiempo al descanso.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // SELECTOR DE TIPO DE SERIE (NORMAL / CALENTAMIENTO / FALLO X2 XP) (Idea 3)
          _buildSetTypeSelector(),
          const SizedBox(height: 12),

          // AJUSTE DE REPETICIONES REALES
          _buildAdjuster(
            label: 'REPETICIONES COMPLETADAS',
            value: '$_actualReps reps',
            onMinus: () {
              if (_actualReps > 1) setState(() => _actualReps--);
            },
            onPlus: () => setState(() => _actualReps++),
          ),
          const SizedBox(height: 16),

          // AJUSTE DE PESO REAL (CON ACCESO DIRECTO A CALCULADORA DE DISCOS)
          _buildAdjuster(
            label: 'PESO UTILIZADO',
            value: '${_actualWeight.toStringAsFixed(1)} kg',
            trailing: InkWell(
              onTap: _openPlateCalculator,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.calculate_outlined, color: SystemTheme.spartanGold, size: 20),
              ),
            ),
            onMinus: () {
              if (_actualWeight >= 2.5) setState(() => _actualWeight -= 2.5);
            },
            onPlus: () => setState(() => _actualWeight += 2.5),
          ),
          const SizedBox(height: 16),

          // SELECCIÓN DE DROP SET (SALTOS DE PESO)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF131C31),
              borderRadius: BorderRadius.circular(16),
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
                      color: _dropsetDrops > 0 ? SystemTheme.neonCyan : Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MECÁNICA DROP SET (SALTOS DE PESO)',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _dropsetDrops > 0 ? SystemTheme.neonCyan : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Si redujiste el peso sin descanso tras el fallo, selecciona los saltos para multiplicar la XP:',
                  style: GoogleFonts.rajdhani(fontSize: 11.5, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDropsetOptionChip(0, 'Normal', 'x1 XP'),
                    _buildDropsetOptionChip(1, '1 Salto', 'x2 XP'),
                    _buildDropsetOptionChip(2, '2 Saltos', 'x3 XP'),
                    _buildDropsetOptionChip(3, '3+ Saltos', 'x4 XP'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // BOTONES DE AÑADIR TIEMPO AL CONTADOR (+15s)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131C31),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TIEMPO DE DESCANSO:',
                      style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      _formatSeconds(totalRestPreview),
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SystemTheme.neonCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: SystemTheme.neonCyan,
                          side: const BorderSide(color: SystemTheme.neonCyan),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_alarm, size: 18),
                        label: Text('+15s descanso', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _addBonusRestTime(15),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_alarm, size: 18),
                        label: Text('+30s descanso', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _addBonusRestTime(30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // BOTÓN: PASAR A LA SIGUIENTE SERIE
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              onPressed: _proceedToNextSetWithRest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PASAR A LA SIGUIENTE SERIE',
                    style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ESTADO 3: Temporizador de descanso activo
  Widget _buildRestingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TIEMPO DE DESCANSO',
          style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: SystemTheme.neonCyan),
        ),
        const SizedBox(height: 24),

        // CÍRCULO DEL TEMPORIZADOR
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: SystemTheme.neonCyan, width: 4),
            boxShadow: [
              BoxShadow(
                color: SystemTheme.neonCyan.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatSeconds(_restSecondsRemaining),
                  style: GoogleFonts.orbitron(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'RESTANTES',
                  style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white60, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // BOTÓN: AÑADIR DE 15 EN 15 SEGUNDOS
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: SystemTheme.neonCyan,
            side: const BorderSide(color: SystemTheme.neonCyan, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add),
          label: Text(
            '+15s MÁS DE DESCANSO',
            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _addBonusRestTime(15),
        ),

        // DESHACER SERIE REGISTRADA (Idea 7)
        if (_lastLoggedSetSnapshot != null) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            icon: const Icon(Icons.undo, size: 16),
            label: Text(
              'Deshacer serie registrada (#${_lastLoggedSetSnapshot!["currentSet"]})',
              style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: _undoLastSet,
          ),
        ],

        const Spacer(),

        // BOTÓN: SALTAR DESCANSO Y COMENZAR SERIE
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _skipRestAndStartNow,
            child: Text(
              'COMENZAR SIGUIENTE SERIE AHORA →',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// ESTADO 4: Resumen final al completar la rutina
  Widget _buildFinishedSummary() {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                '¡RUTINA COMPLETADA!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El Sistema ha recompensado tu disciplina.',
                style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Series Realizadas', '$_totalSetsCompleted series'),
                    const Divider(color: Colors.white12, height: 20),
                    _buildSummaryRow('Ejercicios Concluidos', '${widget.routine.exercises.length}'),
                    const Divider(color: Colors.white12, height: 20),
                    _buildSummaryRow(
                      'XP Total Acumulada',
                      '+${_sessionTotalXp.toStringAsFixed(0)} XP',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SystemTheme.neonCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'REGRESAR AL PERFIL',
                    style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({required String label, required String value, required IconData icon}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: SystemTheme.neonCyan, size: 22),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDropsetOptionChip(int drops, String label, String multiplier) {
    final isSelected = _dropsetDrops == drops;
    return InkWell(
      onTap: () => setState(() => _dropsetDrops = drops),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SystemTheme.neonCyan.withOpacity(0.18) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? SystemTheme.neonCyan : Colors.white24,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? SystemTheme.neonCyan : Colors.white70,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              multiplier,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.amber : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjuster({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131C31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                onPressed: onMinus,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 70),
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white70)),
        Text(
          val,
          style: GoogleFonts.orbitron(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.amber : Colors.white,
          ),
        ),
      ],
    );
  }
}
