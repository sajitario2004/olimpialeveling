# Olimpia Leveling - Cliente Móvil & Desktop (Flutter)

> Aplicación cliente multiplataforma (Android, iOS, macOS) desarrollada en **Flutter 3.x / Dart 3.x** con estética holográfica inspirada en el "Sistema" de **Solo Leveling** y la mitología del **Olimpo**.

![Version](https://img.shields.io/badge/version-0.2.1-blue.svg)
![Tests](https://img.shields.io/badge/flutter_test-69%2F69_passed-brightgreen.svg)
![Analyze](https://img.shields.io/badge/flutter_analyze-0_issues-brightgreen.svg)

---

## 🏛️ Estructura y Módulos Principales

- **`lib/main.dart`**: Punto de entrada, configuración de proveedores reactivos (`MultiProvider`) e inicialización de SQLite.
- **`lib/core/`**:
  - `database/database_helper.dart`: Base de datos SQLite local (usuarios, sesiones, historial de rutinas, series, notas y ajustes).
  - `sharing/routine_share_service.dart`: Serializador y codificador alfanumérico URL-safe para compartir rutinas por WhatsApp (`OLM:...`).
  - `security/password_hasher.dart`: Hashing criptográfico SHA-256 con salt seguro y generador de UID de 15 caracteres.
  - `audio/audio_service.dart`: Reproductor de efectos de sonido del Sistema con inicialización resiliente.
  - `calculator/one_rm_calculator.dart`: Estimador científico de 1 repetición máxima (Epley y Brzycki).
  - `theme/system_theme.dart`: Paleta de colores neón del Sistema y tipografías Orbitron / Rajdhani.
- **`lib/models/`**:
  - `muscle.dart`: Los 14 músculos anatómicos con curva de XP recursiva del 15% y mapa de calor.
  - `player.dart`: Cazador con atributos, Poder de Combate (CP), racha y tokens de descanso.
  - `rank.dart`: Los 8 rangos del Olimpo con niveles de prueba y ascensión suprema a God of Olimpus.
  - `user.dart`: Cazador autenticado con roles (`admin`, `developer`, `hunter`) y UID único.
  - `routine.dart`: Rutinas personalizadas con tipos de serie (`normal`, `calentamiento`, `fallo`), notas y miniaturas.
  - `exercise.dart`: Ejercicios con multimedia, equipamiento, agarre, soporte para hasta 4 músculos y Drop Sets.
- **`lib/features/`**:
  - `body_map/`: Mapa holográfico frontal y dorsal con mapa de calor por nivel muscular.
  - `profile/`: Perfil del cazador, tarjeta de última rutina completada, modal de crónicas, carrusel de PRs y compartir por WhatsApp.
  - `exercises/`: Biblioteca y buscador de ejercicios con filtros por equipamiento/agarre y previsualizaciones.
  - `calculator/`: Calculadora olímpica interactiva directa e inversa de discos y barras.
  - `routines/`: Editor con reordenación Drag & Drop y sesión guiada interactiva con Wake Lock, pausa, undo y temporizador háptico.
  - `dungeons/`: Mazmorras de ascenso semanal con regla de balance muscular ($T - 2$) y Prueba Suprema.
  - `developer/`: Terminal del Desarrollador (God Mode) para pruebas rápidas de rangos y récords personales.
  - `settings/`: Conmutador de unidades (KG / LBS), Wake Lock y vibración háptica.

---

## 🚀 Ejecución y Comandos

### Instalar dependencias
```bash
flutter pub get
```

### Compilar APK para Android (Release)
```bash
DEVELOPER_DIR=/Library/Developer/CommandLineTools flutter build apk --release
```

### Ejecutar en macOS Desktop
```bash
DEVELOPER_DIR=/Library/Developer/CommandLineTools flutter run -d macos
```

### Ejecutar suite de pruebas
```bash
DEVELOPER_DIR=/Library/Developer/CommandLineTools flutter test
```
