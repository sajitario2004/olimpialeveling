import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/system_theme.dart';

/// Diálogo interactivo para recortar, escalar y posicionar la foto de perfil antes de guardarla.
class AvatarAdjustDialog extends StatefulWidget {
  final File imageFile;

  const AvatarAdjustDialog({super.key, required this.imageFile});

  @override
  State<AvatarAdjustDialog> createState() => _AvatarAdjustDialogState();
}

class _AvatarAdjustDialogState extends State<AvatarAdjustDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformCtrl = TransformationController();
  double _currentScale = 1.0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.2).clamp(0.5, 4.0);
      _transformCtrl.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.2).clamp(0.5, 4.0);
      _transformCtrl.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformCtrl.value = Matrix4.identity();
    });
  }

  Future<void> _saveCroppedImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('No se pudo capturar el área del avatar.');
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Error al procesar los bytes de la imagen.');
      }

      final pngBytes = byteData.buffer.asUint8List();

      final appDocDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDocDir.path}/avatars');
      if (!avatarDir.existsSync()) {
        avatarDir.createSync(recursive: true);
      }

      final filePath = '${avatarDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = File(filePath);
      await savedFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.of(context).pop(filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el avatar: $e'),
            backgroundColor: SystemTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0B1120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SystemTheme.neonCyan, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TÍTULO
            Row(
              children: [
                const Icon(Icons.crop, color: SystemTheme.neonCyan, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AJUSTAR FOTO DE PERFIL',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Arrastra para mover la imagen o pellizca para hacer zoom y centrarla en el círculo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // ÁREA DE ENCUADRE INTERACTIVA
            Stack(
              alignment: Alignment.center,
              children: [
                // RepaintBoundary que será capturado como PNG
                RepaintBoundary(
                  key: _cropKey,
                  child: Container(
                    width: 250,
                    height: 250,
                    color: Colors.black,
                    child: ClipOval(
                      child: InteractiveViewer(
                        transformationController: _transformCtrl,
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(100),
                        child: Center(
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // GUÍA VISUAL CIRCULAR
                IgnorePointer(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SystemTheme.neonCyan,
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SystemTheme.neonCyan.withOpacity(0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // CONTROLES DE ZOOM RÁPIDO
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: SystemTheme.neonCyan),
                  tooltip: 'Alejar',
                  onPressed: _zoomOut,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  tooltip: 'Reiniciar encuadre',
                  onPressed: _resetZoom,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: SystemTheme.neonCyan),
                  tooltip: 'Acercar',
                  onPressed: _zoomIn,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ACCIONES
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    child: Text('CANCELAR', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemTheme.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    onPressed: _isProcessing ? null : _saveCroppedImage,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            'APLICAR FOTO',
                            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
