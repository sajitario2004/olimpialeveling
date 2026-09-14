# TREE.md - Árbol de Ficheros y Arquitectura del Proyecto

> **Nota**: Este archivo se mantiene sincronizado y actualizado con cada cambio y evolución del proyecto.

```
olimpialeveling/
├── CONTEXT.md                       # Documento maestro con el 100% del contexto del proyecto para cualquier IA o dev
├── TREE.md                          # Estructura de ficheros y directorios actualizada del proyecto
├── VERSIONS.md                      # Control de versiones del proyecto (SemVer: Major.Minor.Patch)
├── README.md                        # Guía de presentación, características y ejecución del proyecto
├── .gitignore                       # Archivo maestro de exclusiones para GitHub (Flutter, Python, SO)
├── skills-lock.json                 # Registro de skills instaladas mediante Skills CLI
├── .agents/                         # Skills del agente instaladas para extender capacidades
│   └── skills/
│       ├── find-skills/
│       │   └── SKILL.md             # Descubrir e instalar nuevas skills del ecosistema abierto
│       ├── flutter-apply-architecture-best-practices/
│       │   └── SKILL.md             # Buenas prácticas oficiales de arquitectura en Flutter
│       ├── flutter-build-responsive-layout/
│       │   └── SKILL.md             # Directivas oficiales para interfaces responsive y adaptabilidad
│       ├── flutter-fix-layout-issues/
│       │   └── SKILL.md             # Diagnóstico y resolución de errores visuales de Flutter (RenderFlex)
│       ├── flutter-add-widget-test/
│       │   └── SKILL.md             # Pruebas de widgets con WidgetTester, Pump y Matchers
│       ├── flutter-add-integration-test/
│       │   └── SKILL.md             # Pruebas de integración E2E automatizadas
│       ├── flutter-implement-json-serialization/
│       │   └── SKILL.md             # Serialización y mapeo JSON limpio
│       ├── flutter-setup-localization/
│       │   └── SKILL.md             # Internacionalización y localización multilingüe
│       ├── flutter-setup-declarative-routing/
│       │   └── SKILL.md             # Enrutamiento declarativo y deep linking
│       ├── flutter-add-widget-preview/
│       │   └── SKILL.md             # Previsualizaciones dinámicas de componentes
│       ├── flutter-use-http-package/
│       │   └── SKILL.md             # Peticiones HTTP REST y consumo de backend
│       ├── dart-add-unit-test/
│       │   └── SKILL.md             # Pruebas unitarias de lógica de negocio y modelos
│       ├── dart-collect-coverage/
│       │   └── SKILL.md             # Medición y reporte LCOV de cobertura de código
│       ├── dart-fix-runtime-errors/
│       │   └── SKILL.md             # Diagnóstico y resolución de errores de ejecución Dart
│       ├── dart-generate-test-mocks/
│       │   └── SKILL.md             # Generación de mocks con mockito y build_runner
│       ├── git-commit/
│       │   └── SKILL.md             # Commits atómicos según Conventional Commits
│       ├── github-issues/
│       │   └── SKILL.md             # Gestión y etiquetado estructurado de issues en GitHub
│       ├── github-release/
│       │   └── SKILL.md             # Automatización de versiones, tags y changelogs SemVer
│       ├── create-github-action-workflow-specification/
│       │   └── SKILL.md             # Especificación de workflows y CI/CD en GitHub Actions
│       ├── documentation-writer/
│       │   └── SKILL.md             # Documentación técnica estructurada según Diátaxis
│       ├── test-driven-development/
│       │   └── SKILL.md             # Metodología de desarrollo guiado por pruebas (TDD)
│       ├── pytest-coverage/
│       │   └── SKILL.md             # Cobertura y testing en backend Python
│       ├── refactor/
│       │   └── SKILL.md             # Patrones de refactorización limpia y desacoplamiento
│       ├── prd/
│       │   └── SKILL.md             # Documentos de requisitos de producto (PRDs)
│       └── excalidraw-diagram-generator/
│           └── SKILL.md             # Generación de diagramas de arquitectura en Excalidraw
│
├── app/                             # APLICACIÓN FLUTTER MULTIPLATAFORMA (iOS, Android, macOS)
│   ├── pubspec.yaml                 # Dependencias (sqflite, crypto, provider, http, audioplayers, etc.)
│   ├── analysis_options.yaml        # Reglas de linting y buenas prácticas de Dart
│   │
│   ├── assets/                      # Recursos multimedia y configuración embebida
│   │   ├── config/
│   │   │   └── game_config.json     # Configuración exportada desde Python para compilar APK offline
│   │   └── sounds/                  # Efectos sonoros del Sistema sintetizados en audio real
│   │       ├── system_level_up.wav  # Sonido "Ding!" campana cristalina al subir de nivel
│   │       └── penalty_alert.wav    # Sonido de alarma grave ante penalización del Sistema
│   │
│   ├── lib/                         # Código fuente Dart de la aplicación
│   │   ├── main.dart                # Punto de entrada de la app y configuración de MultiProvider
│   │   │
│   │   ├── core/                    # Módulos transversales y servicios centrales
│   │   │   ├── audio/
│   │   │   │   └── audio_service.dart       # Gestor de reproducción de sonidos del Sistema
│   │   │   ├── calculator/
│   │   │   │   └── one_rm_calculator.dart   # Estimador científico de 1RM (fórmulas de Epley y Brzycki)
│   │   │   ├── config/
│   │   │   │   └── game_config_service.dart # Lector de configuración de juego para el APK offline
│   │   │   ├── database/
│   │   │   │   └── database_helper.dart     # SQLite v5 con users (UID 15 caracteres), sessions, PRs y ascensión
│   │   │   ├── security/
│   │   │   │   └── password_hasher.dart     # Hashing SHA-256 con salt y generador de UID de 15 caracteres
│   │   │   ├── sync/
│   │   │   │   └── server_sync_service.dart # Sincronización REST con el servidor Python local
│   │   │   └── theme/
│   │   │       └── system_theme.dart        # Tema Solo Leveling, colores neón, fuentes Orbitron/Rajdhani
│   │   │
│   │   ├── models/                  # Modelos de datos del dominio
│   │   │   ├── achievement.dart     # Modelo de logros y títulos mitológicos desbloqueables
│   │   │   ├── daily_quest.dart     # Las 4 misiones legendarias con selector y comprobación de éxito
│   │   │   ├── exercise.dart        # Ejercicio con cálculo de XP por peso y repeticiones
│   │   │   ├── muscle.dart          # Los 14 músculos con curva de XP recursiva del 15% y mapa de calor
│   │   │   ├── player.dart          # Cazador: nivel, rango, racha, PRs y estado hasCompletedSupremeTrial
│   │   │   ├── rank.dart            # Los 8 rangos: pruebas de ascensión (4..98, 100), God of Olimpus
│   │   │   ├── routine.dart         # Modelo de rutinas y ejercicios configurados (sets, reps, peso, descanso)
│   │   │   └── user.dart            # Usuario y Cazador autenticado con roles admin/developer y UID
│   │   │
│   │   ├── providers/               # Gestores de estado reactivo
│   │   │   └── game_provider.dart   # Orquestador: auth, devSetRank, devSetPR, ascensión suprema, rutinas
│   │   │
│   │   └── features/                # Vistas y pantallas divididas por funcionalidad
│   │       ├── splash/
│   │       │   └── system_boot_screen.dart       # Pantalla de arranque con verificación de sesión activa
│   │       ├── auth/
│   │       │   └── auth_screen.dart              # Pantalla holográfica de login y despertar de cazadores
│   │       ├── developer/
│   │       │   └── developer_terminal_dialog.dart# Terminal de desarrollador: forzar 8 rangos y editor de PRs
│   │       ├── home/
│   │       │   └── home_screen.dart              # Navegación en 3 pestañas: Ejercicios, Cuerpo (default) y Perfil
│   │       ├── body_map/
│   │       │   ├── widgets/
│   │       │   │   ├── anatomical_body_view.dart # Mapa interactivo frontal/dorsal de los 14 músculos
│   │       │   │   └── muscle_detail_sheet.dart  # Detalle de músculo, registro de series, 1RM y Drop Sets
│   │       │   └── body_map_screen.dart          # Pantalla principal del cuerpo anatómico
│   │       ├── exercises/
│   │       │   └── exercise_library_screen.dart  # Buscador de ejercicios con multimedia, YouTube y 4 músculos
│   │       ├── profile/
│   │       │   ├── widgets/
│   │       │   │   └── rank_pyramid_dialog.dart  # Modal piramidal con los 8 rangos y botón 'X'
│   │       │   └── hunter_profile_screen.dart    # Perfil (1-100 azul/oro), chip UID copiable, carrusel PRs y rutinas
│   │       ├── routines/
│   │       │   ├── routine_editor_dialog.dart    # Modal de creación y edición completa de rutinas
│   │       │   └── routine_session_screen.dart   # Sesión de entrenamiento guiada interactiva con descanso y +15s
│   │       ├── quests/
│   │       │   └── daily_quest_sheet.dart        # Ventana de las 4 pruebas del Olimpo y uso de tokens de descanso
│   │       ├── stats/
│   │       │   └── hunter_stats_sheet.dart       # Ventana de estado, Poder de Combate (CP) y reparto de atributos
│   │       ├── history/
│   │       │   └── workout_history_sheet.dart    # Historial de series, tonelaje total acumulado y marcas personales
│   │       ├── dungeons/
│   │       │   └── rank_dungeon_sheet.dart       # Mazmorra semanal de ascenso con regla de bloqueo de músculos atrasados
│   │       ├── calculator/
│   │       │   └── widgets/
│   │       │       └── plate_calculator_sheet.dart # Calculadora visual de discos en barra olímpica por colores
│   │       ├── level_up/
│   │       │   └── level_up_dialog.dart          # Diálogo épico de LEVEL UP con sonido y animación
│   │       ├── timer/
│   │       │   └── widgets/
│   │       │       └── rest_timer_sheet.dart     # Temporizador de recuperación post-serie con aviso sonoro y háptico
│   │       ├── exercises/
│   │       │   └── exercise_library_screen.dart  # Buscador de ejercicios con filtros por músculo y fichas técnicas
│   │       ├── achievements/
│   │       │   └── achievements_screen.dart      # Pantalla de títulos y logros con bonificaciones pasivas equipables
│   │       └── settings/
│   │           └── settings_screen.dart          # Perfil cazador, God Mode, ajustes audiovisuales, IP y legal
│   │
│   ├── test/                        # Pruebas automatizadas de Flutter
│   │   ├── auth_test.dart           # Pruebas unitarias de hashing SHA-256, salt, usuario sajiadmin y sesiones
│   │   ├── models_test.dart         # Pruebas unitarias de curva recursiva 15%, racha, modelos y penalización
│   │   └── widget_test.dart         # Pruebas de widgets y diseño responsive (320x568, 768x1024, 1024x1366)
│   │
│   ├── android/                     # Configuración nativa de Android
│   │   └── app/src/main/AndroidManifest.xml  # Permisos de INTERNET y VIBRATE configurados
│   │
│   ├── ios/                         # Configuración nativa de iOS (iPhone / iPad)
│   │   └── Runner/Info.plist        # Configuración de NSAppTransportSecurity para red local
│   │
│   └── macos/                       # Configuración nativa de macOS Desktop para desarrollo y test local
│
└── server/                          # SERVIDOR Y DASHBOARD WEB EN PYTHON (FastAPI)
    ├── main.py                      # Aplicación FastAPI, endpoint /api/xp_curve, endpoints REST y rutas
    ├── requirements.txt             # Dependencias (fastapi, uvicorn, jinja2, pydantic, pytest, httpx)
    ├── default_config.json          # Configuración inicial por defecto (músculos, rangos, ejercicios, misiones)
    ├── config_data.json             # Almacén de configuración activo y modificado en tiempo real
    ├── test_server.py               # Pruebas automatizadas de endpoints y curva recursiva del 15% con pytest
    ├── static/                      # Ficheros estáticos del panel web
    └── templates/
        └── index.html               # Dashboard visual neón para balancear intervalos, ejercicios y rangos
```
