import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/muscle.dart';
import '../../../core/theme/system_theme.dart';

class AnatomicalBodyView extends StatelessWidget {
  final List<Muscle> muscles;
  final Function(Muscle) onMuscleSelected;

  const AnatomicalBodyView({
    super.key,
    required this.muscles,
    required this.onMuscleSelected,
  });

  Muscle? _findMuscle(String id) {
    try {
      return muscles.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: SystemTheme.neonCyan.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MAPA MUSCULAR DEL SISTEMA',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SystemTheme.neonCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SystemTheme.neonCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4)),
                ),
                child: Text(
                  'INTERACTIVO',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: SystemTheme.neonCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Two bodies side-by-side
          Expanded(
            child: Row(
              children: [
                // FRONT BODY (Left)
                Expanded(
                  child: _BodyCard(
                    title: 'VISTA FRONTAL',
                    isFront: true,
                    muscles: muscles,
                    onMuscleTap: onMuscleSelected,
                    findMuscle: _findMuscle,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  color: SystemTheme.neonCyan.withOpacity(0.2),
                ),
                // BACK BODY (Right)
                Expanded(
                  child: _BodyCard(
                    title: 'VISTA DORSAL',
                    isFront: false,
                    muscles: muscles,
                    onMuscleTap: onMuscleSelected,
                    findMuscle: _findMuscle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Heatmap Legend
          _buildHeatMapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatMapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendItem(color: const Color(0xFF64748B), label: '1-4'),
            const SizedBox(width: 8),
            _LegendItem(color: const Color(0xFF00F0FF), label: '5-14'),
            const SizedBox(width: 8),
            _LegendItem(color: const Color(0xFF10B981), label: '15-29'),
            const SizedBox(width: 8),
            _LegendItem(color: const Color(0xFFF59E0B), label: '30-49'),
            const SizedBox(width: 8),
            _LegendItem(color: const Color(0xFFEF4444), label: '50-79'),
            const SizedBox(width: 8),
            _LegendItem(color: const Color(0xFFA855F7), label: '80+'),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _BodyCard extends StatelessWidget {
  final String title;
  final bool isFront;
  final List<Muscle> muscles;
  final Function(Muscle) onMuscleTap;
  final Muscle? Function(String) findMuscle;

  const _BodyCard({
    required this.title,
    required this.isFront,
    required this.muscles,
    required this.onMuscleTap,
    required this.findMuscle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Base Silhouette
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: SilhouetteBasePainter(isFront: isFront),
                  ),

                  // Interactive Muscle buttons placed anatomically
                  if (isFront) ..._buildFrontMuscles(constraints),
                  if (!isFront) ..._buildBackMuscles(constraints),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFrontMuscles(BoxConstraints c) {
    final w = c.maxWidth;
    final h = c.maxHeight;

    return [
      // Deltoides (Hombros - Izq y Der)
      _muscleZone('deltoides', 'Deltoides', left: w * 0.12, top: h * 0.19, width: w * 0.76, height: h * 0.08),
      // Pecho
      _muscleZone('pecho', 'Pecho', left: w * 0.28, top: h * 0.24, width: w * 0.44, height: h * 0.11),
      // Bíceps
      _muscleZone('biceps', 'Bíceps', left: w * 0.14, top: h * 0.28, width: w * 0.72, height: h * 0.09, isSplit: true),
      // Oblicuos
      _muscleZone('oblicuos', 'Oblicuos', left: w * 0.24, top: h * 0.36, width: w * 0.52, height: h * 0.10, isSplit: true),
      // Abdominales
      _muscleZone('abdominales', 'Abdominales', left: w * 0.35, top: h * 0.36, width: w * 0.30, height: h * 0.13),
      // Antebrazos
      _muscleZone('antebrazo', 'Antebrazo', left: w * 0.08, top: h * 0.38, width: w * 0.84, height: h * 0.11, isSplit: true),
      // Cuádriceps
      _muscleZone('cuadriceps', 'Cuádriceps', left: w * 0.22, top: h * 0.51, width: w * 0.56, height: h * 0.20),
      // Gemelos
      _muscleZone('gemelos', 'Gemelos', left: w * 0.24, top: h * 0.74, width: w * 0.52, height: h * 0.15),
    ];
  }

  List<Widget> _buildBackMuscles(BoxConstraints c) {
    final w = c.maxWidth;
    final h = c.maxHeight;

    return [
      // Trapecio
      _muscleZone('trapecio', 'Trapecio', left: w * 0.28, top: h * 0.15, width: w * 0.44, height: h * 0.10),
      // Deltoides Posterior
      _muscleZone('deltoides', 'Deltoides', left: w * 0.12, top: h * 0.19, width: w * 0.76, height: h * 0.08),
      // Dorsales
      _muscleZone('dorsales', 'Dorsales', left: w * 0.24, top: h * 0.25, width: w * 0.52, height: h * 0.14),
      // Tríceps
      _muscleZone('triceps', 'Tríceps', left: w * 0.14, top: h * 0.28, width: w * 0.72, height: h * 0.09, isSplit: true),
      // Lumbar
      _muscleZone('lumbar', 'Lumbar', left: w * 0.34, top: h * 0.38, width: w * 0.32, height: h * 0.09),
      // Glúteos
      _muscleZone('gluteos', 'Glúteos', left: w * 0.26, top: h * 0.47, width: w * 0.48, height: h * 0.11),
      // Isquiotibiales
      _muscleZone('isquiotibiales', 'Isquiotibiales', left: w * 0.24, top: h * 0.59, width: w * 0.52, height: h * 0.16),
      // Gemelos
      _muscleZone('gemelos', 'Gemelos', left: w * 0.24, top: h * 0.75, width: w * 0.52, height: h * 0.15),
    ];
  }

  Widget _muscleZone(
    String id,
    String label, {
    required double left,
    required double top,
    required double width,
    required double height,
    bool isSplit = false,
  }) {
    final muscle = findMuscle(id);
    if (muscle == null) return const SizedBox.shrink();

    final color = muscle.heatColor;

    if (isSplit) {
      final podWidth = width * 0.36;
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAnatomicalPod(muscle, color, podWidth, height),
            _buildAnatomicalPod(muscle, color, podWidth, height),
          ],
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _buildAnatomicalPod(muscle, color, width, height),
    );
  }

  Widget _buildAnatomicalPod(Muscle muscle, Color color, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: color.withOpacity(0.4),
          highlightColor: color.withOpacity(0.2),
          onTap: () => onMuscleTap(muscle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.55),
                  color.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.85),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SilhouetteBasePainter extends CustomPainter {
  final bool isFront;
  SilhouetteBasePainter({required this.isFront});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = SystemTheme.neonCyan.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.08), width: w * 0.22, height: h * 0.10), paint);

    // Torso outline
    final torsoPath = Path();
    torsoPath.moveTo(w * 0.35, h * 0.13); // Neck left
    torsoPath.lineTo(w * 0.12, h * 0.18); // Shoulder left
    torsoPath.lineTo(w * 0.08, h * 0.48); // Arm left
    torsoPath.lineTo(w * 0.18, h * 0.48); // Hand left inner
    torsoPath.lineTo(w * 0.24, h * 0.30); // Armpit left
    torsoPath.lineTo(w * 0.26, h * 0.46); // Waist left
    torsoPath.lineTo(w * 0.20, h * 0.70); // Knee left
    torsoPath.lineTo(w * 0.22, h * 0.94); // Foot left
    torsoPath.lineTo(w * 0.38, h * 0.94); // Foot inner
    torsoPath.lineTo(w * 0.45, h * 0.52); // Crotch

    // Mirror to right
    torsoPath.lineTo(w * 0.55, h * 0.52);
    torsoPath.lineTo(w * 0.62, h * 0.94);
    torsoPath.lineTo(w * 0.78, h * 0.94);
    torsoPath.lineTo(w * 0.80, h * 0.70);
    torsoPath.lineTo(w * 0.74, h * 0.46);
    torsoPath.lineTo(w * 0.76, h * 0.30);
    torsoPath.lineTo(w * 0.82, h * 0.48);
    torsoPath.lineTo(w * 0.92, h * 0.48);
    torsoPath.lineTo(w * 0.88, h * 0.18);
    torsoPath.lineTo(w * 0.65, h * 0.13);
    torsoPath.close();

    canvas.drawPath(torsoPath, glowPaint);
    canvas.drawPath(torsoPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
