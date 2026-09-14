import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/system_theme.dart';
import '../../providers/game_provider.dart';
import '../home/home_screen.dart';

/// Pantalla de Autenticación Holográfica (Iniciar Sesión y Despertar de Cazadores).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginTab = true;
  bool _obscurePassword = true;
  bool _isProcessing = false;
  String? _errorMessage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hunterNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _hunterNameController.dispose();
    super.dispose();
  }

  void _fillSajiAdmin() {
    setState(() {
      _isLoginTab = true;
      _usernameController.text = 'sajiadmin';
      _passwordController.text = 'sajiadmin';
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final game = Provider.of<GameProvider>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final hunterName = _hunterNameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, completa todos los campos requeridos.');
      return;
    }

    if (!_isLoginTab && hunterName.isEmpty) {
      setState(() => _errorMessage = 'Ingresa el nombre de tu atleta olímpico.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    String? error;
    if (_isLoginTab) {
      error = await game.login(username, password);
    } else {
      error = await game.register(username, password, hunterName);
    }

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Navegación exitosa a HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // System Icon / Emblem
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SystemTheme.neonCyan.withOpacity(0.12),
                        border: Border.all(color: SystemTheme.neonCyan, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: SystemTheme.neonCyan.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shield_outlined, size: 48, color: SystemTheme.neonCyan),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // System Header
                  Center(
                    child: Text(
                      '[SISTEMA DEL OLIMPO]',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        letterSpacing: 2.0,
                        color: SystemTheme.neonCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'IDENTIFICACIÓN DE CAZADOR',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab switcher: Iniciar Sesión vs Despertar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1322),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _tabButton(
                            title: 'INICIAR SESIÓN',
                            isSelected: _isLoginTab,
                            onTap: () => setState(() {
                              _isLoginTab = true;
                              _errorMessage = null;
                            }),
                          ),
                        ),
                        Expanded(
                          child: _tabButton(
                            title: 'DESPERTAR',
                            isSelected: !_isLoginTab,
                            onTap: () => setState(() {
                              _isLoginTab = false;
                              _errorMessage = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick fill sajiadmin chip
                  if (_isLoginTab) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _fillSajiAdmin,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SystemTheme.spartanGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: SystemTheme.spartanGold.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 14, color: SystemTheme.spartanGold),
                              const SizedBox(width: 4),
                              Text(
                                'Rápido: sajiadmin (Admin/Dev)',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: SystemTheme.spartanGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Form Fields
                  if (!_isLoginTab) ...[
                    _inputField(
                      controller: _hunterNameController,
                      label: 'NOMBRE DEL ATLETA / HÉROE',
                      hint: 'Ej. Aquiles / Leónidas / Heracles',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                  ],

                  _inputField(
                    controller: _usernameController,
                    label: 'NOMBRE DE USUARIO',
                    hint: 'Nombre único para acceder al Sistema',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  _inputField(
                    controller: _passwordController,
                    label: 'CONTRASEÑA',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error message banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SystemTheme.dangerRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SystemTheme.dangerRed.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: SystemTheme.dangerRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemTheme.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: SystemTheme.neonCyan.withOpacity(0.4),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            _isLoginTab ? 'ACCEDER AL MONTE OLIMPO' : 'CONSAGRARSE Y ASCENDER AL OLIMPO',
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Footer note
                  Center(
                    child: Text(
                      'Tus datos y contraseñas se almacenan cifrados con SHA-256 en tu base de datos SQLite local.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? SystemTheme.neonCyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SystemTheme.neonCyan : Colors.transparent,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? SystemTheme.neonCyan : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.rajdhani(color: Colors.white30),
            prefixIcon: Icon(icon, color: SystemTheme.neonCyan, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: SystemTheme.neonCyan.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SystemTheme.neonCyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
