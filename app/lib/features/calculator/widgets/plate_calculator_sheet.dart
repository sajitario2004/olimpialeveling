import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/system_theme.dart';

class PlateCalculatorSheet extends StatefulWidget {
  final double initialWeight;

  const PlateCalculatorSheet({super.key, this.initialWeight = 80.0});

  @override
  State<PlateCalculatorSheet> createState() => _PlateCalculatorSheetState();
}

class _PlateCalculatorSheetState extends State<PlateCalculatorSheet> {
  late double _targetWeight;
  double _barWeight = 20.0;
  bool _isInverseMode = false; // False: Peso -> Discos, True: Inversa (Discos -> Peso)

  // Discos reglamentarios: 20, 10, 5, 2.5, 1.25 (más 25 si peso muy alto)
  final List<double> _availablePlates = [25.0, 20.0, 10.0, 5.0, 2.5, 1.25];

  // Conteo de discos por lado en modo inverso
  final Map<double, int> _inversePlatesCount = {
    20.0: 0,
    10.0: 0,
    5.0: 0,
    2.5: 0,
    1.25: 0,
  };

  @override
  void initState() {
    super.initState();
    _targetWeight = widget.initialWeight;
    _syncInverseFromWeight();
  }

  void _syncInverseFromWeight() {
    double neededPerSide = (_targetWeight - _barWeight) / 2.0;
    for (var k in _inversePlatesCount.keys) {
      _inversePlatesCount[k] = 0;
    }
    if (neededPerSide <= 0) return;
    for (var plate in [20.0, 10.0, 5.0, 2.5, 1.25]) {
      if (neededPerSide >= plate) {
        int count = (neededPerSide / plate).floor();
        _inversePlatesCount[plate] = count;
        neededPerSide -= count * plate;
      }
    }
  }

  void _syncWeightFromInverse() {
    double perSide = 0.0;
    _inversePlatesCount.forEach((plate, count) {
      perSide += plate * count;
    });
    setState(() {
      _targetWeight = _barWeight + (perSide * 2.0);
    });
  }

  Map<double, int> _calculatePlatesPerSide() {
    if (_isInverseMode) {
      final Map<double, int> res = {};
      _inversePlatesCount.forEach((k, v) {
        if (v > 0) res[k] = v;
      });
      return res;
    }

    double neededPerSide = (_targetWeight - _barWeight) / 2.0;
    if (neededPerSide <= 0) return {};

    final Map<double, int> plates = {};
    for (var plate in _availablePlates) {
      if (neededPerSide >= plate) {
        int count = (neededPerSide / plate).floor();
        plates[plate] = count;
        neededPerSide -= count * plate;
      }
    }
    return plates;
  }

  Color _getPlateColor(double plate) {
    if (plate >= 25.0) return const Color(0xFFEF4444); // Red
    if (plate >= 20.0) return const Color(0xFF3B82F6); // Blue
    if (plate >= 15.0) return const Color(0xFFEAB308); // Yellow
    if (plate >= 10.0) return const Color(0xFF10B981); // Green
    if (plate >= 5.0) return const Color(0xFFE2E8F0);  // White
    if (plate >= 2.5) return const Color(0xFF94A3B8);  // Silver
    return const Color(0xFF64748B);                     // Grey
  }

  @override
  Widget build(BuildContext context) {
    final platesPerSide = _calculatePlatesPerSide();
    final weightOnPlates = (_targetWeight - _barWeight).clamp(0.0, 1000.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF090D1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: SystemTheme.neonCyan, width: 1.5),
        boxShadow: [
          BoxShadow(color: SystemTheme.neonCyan.withOpacity(0.25), blurRadius: 25),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[CALCULADORA OLÍMPICA // SISTEMA]',
                        style: GoogleFonts.orbitron(fontSize: 10, color: SystemTheme.neonCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'CONFIGURADOR DE BARRA',
                          style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<double>(
                  initialValue: _barWeight,
                  onSelected: (val) {
                    setState(() {
                      _barWeight = val;
                      if (_isInverseMode) {
                        _syncWeightFromInverse();
                      } else {
                        _syncInverseFromWeight();
                      }
                    });
                  },
                  color: const Color(0xFF1E293B),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 20.0, child: Text('Barra Olímpica (20 kg)', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 15.0, child: Text('Barra Técnica (15 kg)', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 10.0, child: Text('Barra Z / Corta (10 kg)', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 0.0, child: Text('Sin Barra / Máquina (0 kg)', style: TextStyle(color: Colors.white))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Barra: ${_barWeight.toInt()} kg',
                          style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: SystemTheme.neonCyan, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Selector de Modo: Directo vs Inverso
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isInverseMode = false;
                        _syncInverseFromWeight();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isInverseMode ? SystemTheme.neonCyan.withOpacity(0.2) : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_isInverseMode ? SystemTheme.neonCyan : Colors.white12,
                          width: !_isInverseMode ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'PESO → DISCOS',
                          style: GoogleFonts.orbitron(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: !_isInverseMode ? SystemTheme.neonCyan : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isInverseMode = true;
                        _syncInverseFromWeight();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isInverseMode ? Colors.amber.withOpacity(0.2) : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isInverseMode ? Colors.amber : Colors.white12,
                          width: _isInverseMode ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'INVERSA: DISCOS → PESO',
                          style: GoogleFonts.orbitron(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: _isInverseMode ? Colors.amber : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weight selector & display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isInverseMode ? Colors.amber.withOpacity(0.4) : SystemTheme.neonCyan.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _isInverseMode ? 'PESO TOTAL CALCULADO' : 'PESO TOTAL A LEVANTAR',
                    style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_targetWeight.toStringAsFixed(1)} KG',
                    style: GoogleFonts.orbitron(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: _isInverseMode ? Colors.amber : SystemTheme.neonCyan,
                    ),
                  ),
                  Text(
                    '(${(weightOnPlates / 2).toStringAsFixed(1)} kg a cada lado de la barra)',
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (!_isInverseMode)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _quickWeightButton(-10),
                          _quickWeightButton(-2.5),
                          const SizedBox(width: 16),
                          _quickWeightButton(2.5),
                          _quickWeightButton(10),
                        ],
                      ),
                    )
                  else
                    // Controles de discos en modo inverso: 20, 10, 5, 2.5, 1.25
                    Column(
                      children: [
                        Text(
                          'Toca para añadir/quitar discos por lado (20, 10, 5, 2.5, 1.25 kg):',
                          style: GoogleFonts.rajdhani(fontSize: 11.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [20.0, 10.0, 5.0, 2.5, 1.25].map((plate) {
                            final count = _inversePlatesCount[plate] ?? 0;
                            final color = _getPlateColor(plate);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color.withOpacity(0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (count > 0) {
                                        setState(() {
                                          _inversePlatesCount[plate] = count - 1;
                                          _syncWeightFromInverse();
                                        });
                                      }
                                    },
                                    child: const Icon(Icons.remove_circle_outline, color: Colors.white60, size: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '$count x ${plate.toStringAsFixed(plate % 1 == 0 ? 0 : 2)}k',
                                      style: GoogleFonts.orbitron(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _inversePlatesCount[plate] = count + 1;
                                        _syncWeightFromInverse();
                                      });
                                    },
                                    child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Visual Barbell Drawing
            Text('DISTRIBUCIÓN VISUAL POR LADO', style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 10),

            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bar shaft
                    Container(width: 50, height: 12, color: const Color(0xFF64748B)),
                    // Collar
                    Container(width: 12, height: 40, color: const Color(0xFF94A3B8)),
                    // Sleeve line
                    Container(width: 8, height: 16, color: const Color(0xFFCBD5E1)),

                    // Plates stacked
                    if (platesPerSide.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text('Solo barra (${_barWeight.toInt()}kg)', style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12)),
                      )
                    else
                      ...platesPerSide.entries.expand((entry) {
                        final plateKg = entry.key;
                        final count = entry.value;
                        final color = _getPlateColor(plateKg);
                        final heightFactor = (plateKg / 25.0).clamp(0.4, 1.0);

                        return List.generate(count, (idx) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 14,
                            height: 80 * heightFactor,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.black45, width: 1),
                              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
                            ),
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  plateKg.toStringAsFixed(plateKg % 1 == 0 ? 0 : 1),
                                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                    // Sleeve tip
                    Container(width: 25, height: 14, color: const Color(0xFF475569)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Disks breakdown list
            Text('DISCOS A COLOCAR POR LADO:', style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),

            if (platesPerSide.isEmpty)
              Text('No se requieren discos adicionales para este peso.', style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 13))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: platesPerSide.entries.map((entry) {
                  final color = _getPlateColor(entry.key);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      '${entry.value}x disco de ${entry.key.toStringAsFixed(entry.key % 1 == 0 ? 0 : 1)} kg',
                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _targetWeight),
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'APLICAR PESO (${_targetWeight.toStringAsFixed(1)} KG)',
                style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickWeightButton(double delta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _targetWeight = (_targetWeight + delta).clamp(_barWeight, 500.0);
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: SystemTheme.neonCyan),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: Text(
          delta > 0 ? '+$delta' : '$delta',
          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
