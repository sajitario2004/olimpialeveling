import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/system_theme.dart';
import '../../../core/audio/audio_service.dart';

class RestTimerSheet extends StatefulWidget {
  final int initialSeconds;
  final String exerciseName;

  const RestTimerSheet({
    super.key,
    this.initialSeconds = 90,
    required this.exerciseName,
  });

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  late int _secondsLeft;
  late int _totalSeconds;
  Timer? _timer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _totalSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isFinished = true;
        });
        AudioService.instance.playTimerBeep();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addSeconds(int s) {
    setState(() {
      _secondsLeft = (_secondsLeft + s).clamp(0, 600);
      if (_secondsLeft > _totalSeconds) _totalSeconds = _secondsLeft;
      if (_isFinished && _secondsLeft > 0) {
        _isFinished = false;
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_secondsLeft / _totalSeconds) : 0.0;
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF090D1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: _isFinished ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isFinished ? SystemTheme.hunterGreen : SystemTheme.neonCyan).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _isFinished ? '[DESCANSO COMPLETADO]' : '[TEMPORIZADOR DE RECUPERACIÓN]',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              letterSpacing: 1.5,
              color: _isFinished ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.exerciseName.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Circular progress timer
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isFinished ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _isFinished ? SystemTheme.hunterGreen : Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _isFinished ? '¡A POR LA SERIE!' : 'DESCANSO',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _addSeconds(-15),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text('-15s', style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _addSeconds(30),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SystemTheme.neonCyan),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text('+30s', style: GoogleFonts.orbitron(color: SystemTheme.neonCyan, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _addSeconds(60),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SystemTheme.spartanGold),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text('+60s', style: GoogleFonts.orbitron(color: SystemTheme.spartanGold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Close / Skip button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFinished ? SystemTheme.hunterGreen : SystemTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _isFinished ? 'CONTINUAR ENTRENANDO' : 'SALTAR DESCANSO',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
