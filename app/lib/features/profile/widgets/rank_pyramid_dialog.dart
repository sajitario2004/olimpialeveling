import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/system_theme.dart';

/// Popup modal que muestra la jerarquía de rangos del Olimpo en forma de pirámide.
class RankPyramidDialog extends StatelessWidget {
  final int playerLevel; // 1 to 100
  final String currentRankId;

  const RankPyramidDialog({
    super.key,
    required this.playerLevel,
    required this.currentRankId,
  });

  static const List<Map<String, dynamic>> pyramidTiers = [
    {
      'id': 'god_of_olimpus',
      'name': 'GOD OF OLIMPUS',
      'levelText': 'Nivel 99 - 100 (Cúspide Divina - 20x XP)',
      'color': Color(0xFFFFD700),
      'secondaryColor': Color(0xFFA855F7),
      'quote': 'Ascensión celestial consumada. Trono del Olimpo alcanzado.',
      'widthFactor': 0.46,
    },
    {
      'id': 'hercules',
      'name': 'HERCULES',
      'levelText': 'Nivel 80 - 98 (Prueba en Nivel 98)',
      'color': Color(0xFFEF4444),
      'secondaryColor': Color(0xFFB91C1C),
      'quote': 'Fuerza mitológica legendaria sobrehumana.',
      'widthFactor': 0.54,
    },
    {
      'id': 'spartan',
      'name': 'SPARTAN',
      'levelText': 'Nivel 65 - 79 (Prueba en Nivel 79)',
      'color': Color(0xFFF97316),
      'secondaryColor': Color(0xFFC2410C),
      'quote': '¡Gloria en la batalla contra el hierro! Voluntad inquebrantable.',
      'widthFactor': 0.62,
    },
    {
      'id': 'soldier',
      'name': 'SOLDIER',
      'levelText': 'Nivel 50 - 64 (Prueba en Nivel 64)',
      'color': Color(0xFFEAB308),
      'secondaryColor': Color(0xFFA16207),
      'quote': 'Disciplina militar espartana. El dolor es debilidad abandonando el cuerpo.',
      'widthFactor': 0.70,
    },
    {
      'id': 'gymbro',
      'name': 'GYMBRO',
      'levelText': 'Nivel 30 - 49 (Prueba en Nivel 49)',
      'color': Color(0xFF10B981),
      'secondaryColor': Color(0xFF047857),
      'quote': 'Hermano del hierro respetado por todos en la sala.',
      'widthFactor': 0.78,
    },
    {
      'id': 'normal_gym_buddy',
      'name': 'NORMAL GYM BUDDY',
      'levelText': 'Nivel 15 - 29 (Prueba en Nivel 29)',
      'color': Color(0xFF06B6D4),
      'secondaryColor': Color(0xFF0E7490),
      'quote': 'Constancia forjada entrenamiento a entrenamiento.',
      'widthFactor': 0.86,
    },
    {
      'id': 'human',
      'name': 'HUMAN',
      'levelText': 'Nivel 5 - 14 (Prueba en Nivel 14)',
      'color': Color(0xFF38BDF8),
      'secondaryColor': Color(0xFF0284C7),
      'quote': 'Superando la debilidad ordinaria cotidiana.',
      'widthFactor': 0.93,
    },
    {
      'id': 'skinnybitch',
      'name': 'SKINNYBITCH',
      'levelText': 'Nivel 0 - 4 (Prueba en Nivel 4)',
      'color': Color(0xFF94A3B8),
      'secondaryColor': Color(0xFF475569),
      'quote': 'El punto de partida del despertar. Todo dios fue mortal.',
      'widthFactor': 1.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: SystemTheme.neonCyan.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER CON TÍTULO Y BOTÓN 'X' DE CIERRE ARRIBA A LA DERECHA
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 1.2),
                    ),
                    child: const Icon(Icons.military_tech, color: Colors.amber, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIRÁMIDE DEL OLIMPO',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Jerarquía de Rangos (Nivel 1 a 100)',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: SystemTheme.neonCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // BOTÓN X ARRIBA A LA DERECHA PARA CERRAR Y VOLVER AL PERFIL
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                    tooltip: 'Cerrar y volver al perfil',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // CONTENIDO CON SCROLL: PIRÁMIDE VISUAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Badge del nivel actual
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: playerLevel >= 100
                            ? Colors.amber.withOpacity(0.2)
                            : const Color(0xFF0D47A1).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: playerLevel >= 100 ? Colors.amber : const Color(0xFF1E88E5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            playerLevel >= 100 ? Icons.workspace_premium : Icons.bolt,
                            color: playerLevel >= 100 ? Colors.amber : SystemTheme.neonCyan,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            playerLevel >= 100
                                ? '¡NIVEL MÁXIMO 100 ALCANZADO // DIOS DEL OLIMPO!'
                                : 'TU PROGRESO ACTUAL: NIVEL $playerLevel / 100',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: playerLevel >= 100 ? Colors.amber : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PIRÁMIDE EN BLOQUES
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        return Column(
                          children: pyramidTiers.map((tier) {
                            final tierId = tier['id'] as String;
                            final isCurrentRank = tierId == currentRankId ||
                                (playerLevel >= 99 && tierId == 'god_of_olimpus') ||
                                (playerLevel < 5 && tierId == 'skinnybitch');
                            final color = tier['color'] as Color;
                            final widthFactor = (tier['widthFactor'] as num).toDouble();
                            final blockWidth = maxWidth * widthFactor;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.5),
                              child: Center(
                                child: Container(
                                  width: blockWidth,
                                  decoration: BoxDecoration(
                                    color: isCurrentRank
                                        ? color.withOpacity(0.22)
                                        : const Color(0xFF0D1527),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isCurrentRank ? color : color.withOpacity(0.4),
                                      width: isCurrentRank ? 2.2 : 1.0,
                                    ),
                                    boxShadow: isCurrentRank
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.35),
                                              blurRadius: 14,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.8),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    tier['name'] as String,
                                                    style: GoogleFonts.orbitron(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: color,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isCurrentRank) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      'ACTUAL',
                                                      style: GoogleFonts.orbitron(
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Text(
                                              tier['levelText'] as String,
                                              style: GoogleFonts.rajdhani(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Tarjeta informativa al pie
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: SystemTheme.neonCyan, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'REGLA DE ASCENSIÓN',
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: SystemTheme.neonCyan,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Alcanza el Nivel 100 entrenando los 14 músculos del cuerpo para coronarte como God of Olimpus. En los niveles 4, 14, 29, 49, 64, 79 y 98 debes superar la Prueba Semanal de Ascensión para desbloquear el siguiente rango. Del nivel 99 al 100 se requiere 20x más XP.',
                            style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white70),
                          ),
                        ],
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
  }
}
