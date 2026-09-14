import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../models/routine.dart';
import '../../providers/game_provider.dart';
import 'widgets/rank_pyramid_dialog.dart';
import '../routines/routine_editor_dialog.dart';
import '../routines/routine_session_screen.dart';

/// Pestaña del perfil del cazador con avatar, cambio de nombre/clave, barra de nivel (azul oscuro / dorado),
/// popup piramidal de rangos y menú scroll para gestión de rutinas.
class HunterProfileScreen extends StatelessWidget {
  const HunterProfileScreen({super.key});

  void _openRankPyramid(BuildContext context, int level, String rankId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RankPyramidDialog(
        playerLevel: level,
        currentRankId: rankId,
      ),
    );
  }

  void _openRoutineEditor(BuildContext context, {Routine? routine}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RoutineEditorDialog(initialRoutine: routine),
    );
  }

  void _confirmDeleteRoutine(BuildContext context, GameProvider game, Routine routine) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF160B0B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFF1744), width: 2),
        ),
        title: Center(
          child: Text(
            'Estas seguro de que quieres borrar esta rutina',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF1744), // ROJO CHILLÓN
              letterSpacing: 1.1,
            ),
          ),
        ),
        content: Text(
          'Se eliminará "${routine.name}" y su lista de ejercicios configurada.',
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white70),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        actions: [
          // SÍ EN VERDE
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676), // VERDE
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await game.deleteRoutine(routine.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rutina "${routine.name}" eliminada.'),
                    backgroundColor: const Color(0xFFFF1744),
                  ),
                );
              }
            },
            child: Text(
              'SÍ',
              style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
          // NO EN ROJO
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744), // ROJO
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'NO',
              style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _startRoutine(BuildContext context, Routine routine) {
    if (routine.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta rutina no contiene ejercicios. Edítala para agregar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RoutineSessionScreen(routine: routine),
      ),
    );
  }

  void _openEditProfileDialog(BuildContext context, GameProvider game) {
    final user = game.currentUser;
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final hunterNameCtrl = TextEditingController(text: user?.hunterName ?? '');
    final avatarUrlCtrl = TextEditingController(text: user?.avatarUrl ?? '');
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: SystemTheme.neonCyan, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.manage_accounts, color: SystemTheme.neonCyan),
                const SizedBox(width: 8),
                Text(
                  'EDITAR PERFIL Y CLAVE',
                  style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre de usuario', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: usernameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Nombre del Cazador (Título)', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: hunterNameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Foto / Avatar de Perfil (URL o icono)', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: avatarUrlCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'https://ejemplo.com/avatar.jpg',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text('Nueva Contraseña (dejar vacío si no deseas cambiar)', style: GoogleFonts.rajdhani(color: Colors.amber, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mínimo 4 caracteres...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('CANCELAR', style: GoogleFonts.orbitron(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SystemTheme.neonCyan,
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final newU = usernameCtrl.text.trim();
                  final newH = hunterNameCtrl.text.trim();
                  final newA = avatarUrlCtrl.text.trim().isEmpty ? null : avatarUrlCtrl.text.trim();

                  if (newU.isNotEmpty) {
                    await game.updateProfile(username: newU, hunterName: newH, avatarUrl: newA);
                  }

                  if (passwordCtrl.text.trim().length >= 4) {
                    await game.updatePassword(newPassword: passwordCtrl.text.trim());
                  }

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text('GUARDAR CAMBIOS', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final user = game.currentUser;
        final level = game.hunterLevel; // 1 a 100
        final progress = game.hunterLevelProgress; // 0.0 a 1.0
        final rank = game.hunterRank;
        final routines = game.routines;

        final isMaxLevel = level >= 100;

        // Regla de color solicitada por el usuario:
        // - Mientras se sube de nivel (< 100): tanto la barra como el número en AZUL OSCURO.
        // - Al completar todos los niveles (100): tanto la barra como el número en DORADO.
        const darkBlueColor = Color(0xFF0D47A1); // AZUL OSCURO
        const goldColor = Color(0xFFFFD700);     // DORADO

        final levelColor = isMaxLevel ? goldColor : darkBlueColor;
        final progressBarColor = isMaxLevel ? goldColor : darkBlueColor;

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TARJETA DE USUARIO / PERFIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1626),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: SystemTheme.neonCyan.withOpacity(0.08),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // FOTO DE PERFIL / AVATAR
                            Stack(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1A2744),
                                    border: Border.all(
                                      color: isMaxLevel ? goldColor : SystemTheme.neonCyan,
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isMaxLevel ? goldColor : SystemTheme.neonCyan).withOpacity(0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: user?.avatarUrl != null && user!.avatarUrl!.startsWith('http')
                                        ? Image.network(
                                            user.avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.person,
                                              size: 38,
                                              color: SystemTheme.neonCyan,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shield,
                                            size: 34,
                                            color: SystemTheme.neonCyan,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _openEditProfileDialog(context, game),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: SystemTheme.neonCyan,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, size: 13, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // NOMBRE DE USUARIO Y ROL
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user?.hunterName ?? 'Cazador del Olimpo',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.settings_outlined, color: Colors.white60, size: 20),
                                        tooltip: 'Editar nombre y contraseña',
                                        onPressed: () => _openEditProfileDialog(context, game),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '@${user?.username ?? 'cazador'} // ${user?.roleDisplay ?? 'CAZADOR'}',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 12,
                                      color: SystemTheme.neonCyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // BARRA DE PROGRESO DE NIVEL Y NIVEL DEL JUGADOR
                        // (Azul oscuro mientras sube, Dorado en Nivel 100)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMaxLevel ? goldColor.withOpacity(0.5) : darkBlueColor.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'NIVEL DEL JUGADOR: ',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '$level',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: levelColor, // Azul oscuro o Dorado
                                        ),
                                      ),
                                      if (isMaxLevel) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '★ MAX',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: goldColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    isMaxLevel ? '100 / 100 (100%)' : '${(progress * 100).toInt()}% a Nivel ${level + 1}',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isMaxLevel ? goldColor : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // BARRA DE PROGRESO
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: const Color(0xFF1E293B),
                                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // RANGO DEL JUGADOR (Al pulsar salta el popup en forma de pirámide)
                        InkWell(
                          onTap: () => _openRankPyramid(context, level, rank.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: rank.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: rank.color, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.stars, color: rank.color, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RANGO: ${rank.name}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: rank.color,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      Text(
                                        'Toca para ver la Pirámide del Olimpo',
                                        style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // MENÚ SCROLL DE RUTINAS DE ENTRENAMIENTO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RUTINAS DE ENTRENAMIENTO',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (routines.isNotEmpty)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemTheme.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            'Añadir Rutina',
                            style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _openRoutineEditor(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // SI ESTÁ VACÍO: BOTÓN "+ AÑADIR RUTINA"
                  if (routines.isEmpty)
                    InkWell(
                      onTap: () => _openRoutineEditor(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.4), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: SystemTheme.neonCyan.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: SystemTheme.neonCyan, size: 36),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '+ Añadir rutina',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SystemTheme.neonCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Crea tu plan personalizado: día de pierna, día de pecho, etc.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // LISTA CON SCROLL DE RUTINAS AÑADIDAS
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final routine = routines[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      routine.name,
                                      style: GoogleFonts.orbitron(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${routine.exercises.length} ejercicios',
                                      style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Resumen de ejercicios
                              Text(
                                routine.exercises.map((e) => e.exerciseName).join(' • '),
                                style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white60),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),

                              // LAS 3 OPCIONES: ELIMINAR, EDITAR, INICIAR RUTINA
                              Row(
                                children: [
                                  // 1. BOTÓN ELIMINAR (Diálogo rojo chillón con confirmación)
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFF1744),
                                      side: const BorderSide(color: Color(0xFFFF1744)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: Text(
                                      'Eliminar',
                                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => _confirmDeleteRoutine(context, game, routine),
                                  ),
                                  const SizedBox(width: 8),

                                  // 2. BOTÓN EDITAR ("en amarillo tirando a naranja")
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFFA000), // AMARILLO-NARANJA
                                      side: const BorderSide(color: Color(0xFFFFA000)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: Text(
                                      'Editar',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFFA000),
                                      ),
                                    ),
                                    onPressed: () => _openRoutineEditor(context, routine: routine),
                                  ),
                                  const Spacer(),

                                  // 3. BOTÓN INICIAR RUTINA
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SystemTheme.neonCyan,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 4,
                                    ),
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: Text(
                                      'INICIAR',
                                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900),
                                    ),
                                    onPressed: () => _startRoutine(context, routine),
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
        );
      },
    );
  }
}
