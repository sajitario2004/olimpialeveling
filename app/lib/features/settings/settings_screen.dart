import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../developer/developer_terminal_dialog.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  int _defaultRestSeconds = 90;
  late TextEditingController _serverController;

  @override
  void initState() {
    super.initState();
    final game = Provider.of<GameProvider>(context, listen: false);
    _serverController = TextEditingController(text: game.serverUrl);
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C1322),
            elevation: 0,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'AJUSTES DEL SISTEMA',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: SystemTheme.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: SystemTheme.neonCyan.withOpacity(0.3), height: 1),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // CUENTA Y PERFIL DEL CAZADOR
              _sectionHeader('IDENTIFICACIÓN DEL CAZADOR (PERFIL LOCAL)'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: game.isAdmin ? SystemTheme.spartanGold : (game.isDeveloper ? SystemTheme.neonCyan : Colors.white12),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: game.isAdmin ? SystemTheme.spartanGold.withOpacity(0.2) : SystemTheme.neonCyan.withOpacity(0.2),
                          child: Icon(
                            game.isAdmin ? Icons.shield : Icons.person,
                            color: game.isAdmin ? SystemTheme.spartanGold : SystemTheme.neonCyan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.currentUser?.hunterName ?? 'Cazador Desconocido',
                                style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${game.currentUser?.username ?? "anon"} // ${game.currentUser?.roleDisplay ?? "CAZADOR"}',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: game.isAdmin ? SystemTheme.spartanGold : SystemTheme.neonCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF131D31),
                                title: Text('¿CERRAR SESIÓN?', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
                                content: Text('Tu progreso en SQLite seguirá guardado.', style: GoogleFonts.rajdhani(color: Colors.white70)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('SALIR', style: GoogleFonts.orbitron(color: SystemTheme.dangerRed, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await game.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          child: Text('SALIR', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    if (game.currentUser?.hasPrivilegedAccess ?? false) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const DeveloperTerminalDialog(),
                          );
                        },
                        icon: const Icon(Icons.terminal, color: Colors.black, size: 18),
                        label: Text(
                          'TERMINAL DEL DESARROLLADOR // GOD MODE',
                          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SystemTheme.spartanGold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // PREFERENCIAS AUDIOVISUALES
              _sectionHeader('CONFIGURACIÓN AUDIOVISUAL & HÁPTICA'),
              _switchTile(
                title: 'Efectos de Sonido del Sistema',
                subtitle: 'Sonido "Ding!" al subir de nivel y alertas de misión',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              _switchTile(
                title: 'Respuesta Háptica / Vibración',
                subtitle: 'Vibración táctil al registrar series y finalizar descansos',
                value: _hapticsEnabled,
                onChanged: (v) => setState(() => _hapticsEnabled = v),
              ),
              const SizedBox(height: 20),

              // DESCANSO ENTRE SERIES
              _sectionHeader('TEMPORIZADOR DE RECUPERACIÓN (REST TIMER)'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Descanso por defecto',
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<int>(
                      value: _defaultRestSeconds,
                      dropdownColor: const Color(0xFF0F172A),
                      underline: const SizedBox.shrink(),
                      style: GoogleFonts.orbitron(color: SystemTheme.neonCyan, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 60, child: Text('60 segundos')),
                        DropdownMenuItem(value: 90, child: Text('90 segundos')),
                        DropdownMenuItem(value: 120, child: Text('120 segundos')),
                        DropdownMenuItem(value: 180, child: Text('180 segundos')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _defaultRestSeconds = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SERVIDOR LOCAL PYTHON
              _sectionHeader('CONEXIÓN AL PANEL PYTHON (LOCAL BACKEND)'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SystemTheme.neonCyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección IP / Puerto del Servidor',
                      style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _serverController,
                            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await game.updateServerUrl(_serverController.text.trim());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    game.isServerOnline
                                        ? '¡Conectado exitosamente al servidor Python!'
                                        : 'No se pudo contactar el servidor en esa dirección.',
                                  ),
                                  backgroundColor: game.isServerOnline ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemTheme.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          child: Text('PROBAR', style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // COPIA DE SEGURIDAD Y REINICIO
              _sectionHeader('GESTIÓN DE DATOS Y PROGRESO'),
              _actionTile(
                title: 'Exportar Copia de Seguridad (JSON)',
                subtitle: 'Guarda tus niveles, estadísticas y entrenamientos',
                icon: Icons.download,
                color: SystemTheme.neonCyan,
                onTap: () async {
                  final jsonStr = await game.exportBackupJson();
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Copia de seguridad copiada al portapapeles en formato JSON!'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
              ),
              _actionTile(
                title: 'Reiniciar Cuenta / Nuevo Despertar',
                subtitle: 'Restablecer todos los niveles a 1 y renacer como Skinnybitch',
                icon: Icons.restart_alt,
                color: SystemTheme.dangerRed,
                onTap: () => _confirmResetDialog(context, game),
              ),
              const SizedBox(height: 20),

              // LEGAL Y SALUD (APP STORE & GOOGLE PLAY COMPLIANCE)
              _sectionHeader('INFORMACIÓN LEGAL & COMPLIANCE DE TIENDAS'),
              _legalTile(
                title: 'Términos y Condiciones de Uso',
                onTap: () => _showTextModal(context, 'TÉRMINOS Y CONDICIONES', _termsAndConditionsText),
              ),
              _legalTile(
                title: 'Política de Privacidad (Datos 100% Locales)',
                onTap: () => _showTextModal(context, 'POLÍTICA DE PRIVACIDAD', _privacyPolicyText),
              ),
              _legalTile(
                title: 'Descargo de Responsabilidad Médica y Salud',
                onTap: () => _showTextModal(context, 'DESCARGO DE SALUD', _medicalDisclaimerText),
              ),
              const SizedBox(height: 30),

              // Footer Version
              Center(
                child: Text(
                  'OLIMPIA LEVELING // VERSIÓN 0.0.1 (ALPHA BUILD)',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: SystemTheme.neonCyan,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: SystemTheme.neonCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _legalTile({required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          title: Text(title, style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.open_in_new, color: Colors.white30, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }

  void _confirmResetDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystemTheme.dangerRed, width: 2),
        ),
        title: Text('¿REINICIAR TODO EL PROGRESO?', style: GoogleFonts.orbitron(color: SystemTheme.dangerRed, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text(
          'Esta acción borrará todos tus niveles, experiencia y marcas personales, devolviéndote al rango inicial SKINNYBITCH. Esta acción es irreversible.',
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCELAR', style: GoogleFonts.orbitron(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await game.resetAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progreso reiniciado. Has renacido como Skinnybitch Nivel 1.'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: SystemTheme.dangerRed),
            child: Text('REINICIAR', style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTextModal(BuildContext context, String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF090D1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.orbitron(color: SystemTheme.neonCyan, fontSize: 14, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _termsAndConditionsText = '''
TÉRMINOS Y CONDICIONES DE OLIMPIA LEVELING

1. ACEPTACIÓN DE LOS TÉRMINOS
Al descargar, instalar o utilizar Olimpia Leveling, aceptas quedar legalmente vinculado por los presentes Términos y Condiciones. Si no estás de acuerdo con alguna de las cláusulas, debes desinstalar y cesar el uso de la aplicación.

2. NATURALEZA DEL SERVICIO
Olimpia Leveling es una herramienta de gamificación y registro personal de entrenamientos físicos inspirada en temáticas de RPG y ficción. Las mecánicas de "subida de nivel", "rangos", "penalizaciones" y "estadísticas" son elementos puramente lúdicos destinados a fomentar la motivación personal.

3. USO RESPONSABLE Y LIMITACIÓN DE RESPONSABILIDAD
El usuario es el único responsable de la intensidad, técnica, peso levantado y seguridad durante la realización de los ejercicios registrados. Ni los desarrolladores ni los creadores de Olimpia Leveling serán responsables bajo ninguna circunstancia de lesiones físicas, accidentes, daños materiales o perjuicios de salud derivados directa o indirectamente del uso de la aplicación o del cumplimiento de las "misiones diarias".

4. DERECHOS DE PROPIEDAD
Todo el código, diseño gráfico, elementos de interfaz y lógica de negocio pertenecen a Olimpia Leveling. Las referencias estéticas están protegidas como obras creativas derivadas y de entretenimiento.
''';

  static const String _privacyPolicyText = '''
POLÍTICA DE PRIVACIDAD DE OLIMPIA LEVELING

Última actualización: Septiembre 2026.

1. COMPROMISO DE PRIVACIDAD ABSOLUTA
En Olimpia Leveling respetamos al 100% tu privacidad. Creemos firmemente que tus datos de salud, rendimiento físico y hábitos personales te pertenecen exclusivamente a ti.

2. ALMACENAMIENTO 100% LOCAL (ON-DEVICE)
- Todos los datos relativos a tu nivel, series registradas, repeticiones, pesos levantados, misiones y marcas personales se almacenan de forma local en tu dispositivo móvil a través de una base de datos SQLite cifrada por el sistema operativo.
- La aplicación NO envía tus datos personales a servidores externos de terceros, compañías publicitarias ni redes de rastreo analítico.

3. CONEXIÓN LOCAL OPCIONAL (PYTHON DASHBOARD)
Si decides conectar la aplicación a un servidor local de Python en tu red WiFi, la comunicación se realiza exclusivamente entre tu dispositivo y tu ordenador dentro de tu propia red de área local privada. Ningún dato sale a la nube pública.

4. DERECHOS DEL USUARIO (RGPD / CCPA)
Tienes el control total de tus datos:
- Puedes exportar una copia completa en formato JSON en cualquier momento desde la sección de Ajustes.
- Puedes eliminar todos tus datos de forma instantánea pulsando "Reiniciar Cuenta" o simplemente desinstalando la app.
''';

  static const String _medicalDisclaimerText = '''
DESCARGO DE RESPONSABILIDAD MÉDICA Y DE SALUD

ATENCIÓN: POR FAVOR LEE ESTE AVISO ANTES DE COMENZAR CUALQUIER ENTRENAMIENTO

1. NO CONSTITUYE CONSEJO MÉDICO
El contenido, las sugerencias de ejercicios, las misiones diarias y las métricas mostradas en Olimpia Leveling tienen propósitos exclusivamente informativos y de entretenimiento. La aplicación no es un dispositivo médico ni un sustituto de la consulta médica, el diagnóstico profesional ni la supervisión de un entrenador certificado.

2. CONSULTA PREVIA OBLIGATORIA
Antes de iniciar cualquier programa de ejercicios, especialmente levantamiento de cargas pesadas o retos de alta intensidad (como las misiones diarias de 100 repeticiones o carreras prolongadas), debes consultar con tu médico o profesional sanitario para verificar que estás en condiciones óptimas para el esfuerzo físico.

3. ESCUCHA A TU CUERPO
Si en algún momento sientes mareo, dolor agudo en articulaciones, dificultad respiratoria inusual o molestias anormales, DETÉN EL EJERCICIO INMEDIATAMENTE y acude a un centro de salud. Ningún rango ficticio ni misión diaria vale más que tu salud física y bienestar.
''';
}
