# Olimpia Leveling - Cliente Móvil & Desktop (Flutter)

> Aplicación cliente multiplataforma (Android, iOS, macOS) desarrollada en **Flutter 3.x / Dart 3.x** con estética holográfica inspirada en el "Sistema" de **Solo Leveling** y la mitología del **Olimpo**.

![Version](https://img.shields.io/badge/version-0.1.1-blue.svg)
![Tests](https://img.shields.io/badge/flutter_test-60%2F60_passed-brightgreen.svg)
![Analyze](https://img.shields.io/badge/flutter_analyze-0_issues-brightgreen.svg)

---

## 🏛️ Estructura y Módulos Principales

- **`lib/main.dart`**: Punto de entrada, configuración de proveedores reactivos (`MultiProvider`) e inicialización de SQLite.
- **`lib/core/`**:
  - `database/database_helper.dart`: Base de datos SQLite v5 local (usuarios, sesiones, historial de series, rutinas y PRs).
  - `security/password_hasher.dart`: Hashing criptográfico SHA-256 con salt seguro y generador de UID de 15 caracteres.
  - `audio/audio_service.dart`: Reproductor de efectos de sonido del Sistema con inicialización resiliente.
  - `calculator/one_rm_calculator.dart`: Estimador científico de 1 repetición máxima (Epley y Brzycki).
  - `theme/system_theme.dart`: Paleta de colores neón del Sistema y tipografías Orbitron / Rajdhani.
- **`lib/models/`**:
  - `muscle.dart`: Los 14 músculos anatómicos con curva de XP recursiva del 15% y mapa de calor.
  - `player.dart`: Cazador con atributos, Poder de Combate (CP), racha y tokens de descanso.
  - `rank.dart`: Los 8 rangos del Olimpo con niveles de prueba y ascensión suprema a God of Olimpus.
  - `user.dart`: Cazador autenticado con roles (`admin`, `developer`, `hunter`) y UID único.
  - `routine.dart`: Rutinas personalizadas compuestas de múltiples ejercicios.
  - `exercise.dart`: Ejercicios con multimedia y soporte para hasta 4 músculos y Drop Sets.
- **`lib/features/`**:
  - `body_map/`: Mapa holográfico frontal y dorsal con mapa de calor por nivel muscular.
  - `profile/`: Perfil del cazador (nivel 0-100 azul/dorado), chip de UID copiable, carrusel de PRs y gestor de rutinas.
  - `exercises/`: Biblioteca y buscador de ejercicios en tiempo real con previsualizaciones y enlaces a YouTube.
  - `dungeons/`: Mazmorras de ascenso semanal con regla de balance muscular y Prueba Suprema del Olimpo.
  - `developer/`: Terminal del Desarrollador (God Mode) para pruebas rápidas de rangos y récords personales.

---

## 🚀 Ejecución y Comandos

### Instalar dependencias
```bash
flutter pub get
```

### Ejecutar en tu dispositivo o simulador
```bash
# En macOS Desktop:
flutter run -d macos

# En dispositivo móvil o simulador:
flutter run
```

### Ejecutar suite de pruebas unitarias y de widgets
```bash
flutter test
```

### Análisis estático de código
```bash
flutter analyze
```

