import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../home/home_screen.dart';
import '../auth/auth_screen.dart';

class SystemBootScreen extends StatefulWidget {
  const SystemBootScreen({super.key});

  @override
  State<SystemBootScreen> createState() => _SystemBootScreenState();
}

class _SystemBootScreenState extends State<SystemBootScreen> {
  String _statusText = 'INICIANDO EL SISTEMA...';
  double _bootProgress = 0.1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBootSequence();
    });
  }

  Future<void> _startBootSequence() async {
    final game = Provider.of<GameProvider>(context, listen: false);
    await game.initialize();

    if (!mounted) return;

    setState(() {
      _statusText = 'CONSAGRANDO AL GUERRERO ANTE LOS DIOSES DEL OLIMPO...';
      _bootProgress = 0.4;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _statusText = 'FORJANDO LOS 14 GRUPOS MUSCULARES EN LA FRAGUA DE HEFESTO...';
      _bootProgress = 0.8;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _statusText = 'BIENVENIDO AL MONTE OLIMPO, ATLETA SAGRADO.';
      _bootProgress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    final nextScreen = game.isAuthenticated ? const HomeScreen() : const AuthScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => nextScreen,
        transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060912),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing System Emblem
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SystemTheme.neonCyan, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: SystemTheme.neonCyan.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    size: 40,
                    color: SystemTheme.neonCyan,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1000.ms),

              const SizedBox(height: 32),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'OLIMPIA LEVELING',
                  style: GoogleFonts.orbitron(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(color: SystemTheme.neonCyan.withOpacity(0.8), blurRadius: 15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'DE SKINNYBITCH A GOD OF OLIMPUS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SystemTheme.neonCyan,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Progress bar
              SizedBox(
                width: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _bootProgress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(SystemTheme.neonCyan),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _statusText,
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
