import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/system_theme.dart';
import '../../../core/audio/audio_service.dart';
import '../../../models/exercise.dart';
import '../../../models/routine.dart';
import '../../../providers/game_provider.dart';

/// Pantalla de sesión activa de entrenamiento guiada ejercicio por ejercicio y serie por serie.
class RoutineSessionScreen extends StatefulWidget {
  final Routine routine;

  const RoutineSessionScreen({super.key, required this.routine});

  @override
  State<RoutineSessionScreen> createState() => _RoutineSessionScreenState();
}

class _RoutineSessionScreenState extends State<RoutineSessionScreen> {
  int _exerciseIndex = 0;
  int _currentSet = 1;

  // Estado dentro de la serie
  bool _isReviewingSet = false; // El usuario pulsó "Terminar Serie" y está ajustando repeticiones/descanso
  bool _isResting = false;      // El temporizador de descanso está contando
  int _restSecondsRemaining = 0;
  Timer? _timer;

  // Valores de la serie actual
  late int _actualReps;
  late double _actualWeight;
  int _addedBonusRest = 0;
  int _dropsetDrops = 0;

  // Estadísticas acumuladas de la sesión
  double _sessionTotalXp = 0.0;
  int _totalSetsCompleted = 0;
  bool _isFinished = false;

  RoutineExercise get _currentRoutineExercise =>
      widget.routine.exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _resetCurrentSetValues();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetCurrentSetValues() {
    final current = _currentRoutineExercise;
    _actualReps = current.targetReps;
    _actualWeight = current.targetWeightKg;
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

    // Sumar los puntos de XP correspondientes a los músculos
    await game.logWorkout(
      exercise: fullExercise,
      weightKg: _actualWeight,
      reps: _actualReps,
      dropsetDrops: _dropsetDrops,
    );

    // Reproducir feedback sonoro
    AudioService.instance.playLevelUp();

    final xpGainMap = fullExercise.calculateXp(
      weightKg: _actualWeight,
      reps: _actualReps,
      dropsetDrops: _dropsetDrops,
    );
    final xpGain = xpGainMap.values.fold(0.0, (a, b) => a + b);
    _sessionTotalXp += xpGain;
    _totalSetsCompleted += 1;

    // Iniciar cuenta atrás del temporizador de descanso
    final totalRest = currentEx.restSeconds + _addedBonusRest;
    setState(() {
      _isReviewingSet = false;
      _isResting = true;
      _restSecondsRemaining = totalRest;
    });

    _startRestTimer();
  }

  void _startRestTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_restSecondsRemaining > 1) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        _timer?.cancel();
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
      if (_exerciseIndex < widget.routine.exercises.length - 1) {
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

    final current = _currentRoutineExercise;
    final totalExercises = widget.routine.exercises.length;

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

  /// ESTADO 1: Realizando la serie
  Widget _buildActiveSetView() {
    final current = _currentRoutineExercise;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: 16),

        Text(
          current.exerciseName,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MÚSCULO: ${current.primaryMuscle.toUpperCase()}',
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 32),

        // TARJETA DE PESO Y REPETICIONES OBJETIVO
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatBox(
              label: 'PESO OBJETIVO',
              value: '${current.targetWeightKg.toStringAsFixed(0)} kg',
              icon: Icons.fitness_center,
            ),
            const SizedBox(width: 16),
            _buildStatBox(
              label: 'REPETICIONES',
              value: '${current.targetReps} reps',
              icon: Icons.repeat,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(
              'Descanso programado: ${_formatSeconds(current.restSeconds)} min',
              style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),

        const Spacer(),

        // BOTÓN: TERMINAR SERIE
        SizedBox(
          width: double.infinity,
          height: 60,
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
                const Icon(Icons.check_circle_outline, size: 26),
                const SizedBox(width: 10),
                Text(
                  'TERMINAR SERIE',
                  style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ESTADO 2: Ajuste de repeticiones reales, peso y botón +15s
  Widget _buildReviewingView() {
    final current = _currentRoutineExercise;
    final totalRestPreview = current.restSeconds + _addedBonusRest;

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
          const SizedBox(height: 24),

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

          // AJUSTE DE PESO REAL
          _buildAdjuster(
            label: 'PESO UTILIZADO',
            value: '${_actualWeight.toStringAsFixed(1)} kg',
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
          Text(label, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
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
