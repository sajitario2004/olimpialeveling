# VERSIONS.md - Registro Oficial de Versiones (Changelog)

> **Reglas de Versionado SemVer del Proyecto**:
> - **PATCH (0.0.x)**: Modificaciones menores, correcciones de errores, ajustes de interfaz, optimizaciones de rendimiento y documentación.
> - **MINOR (0.x.0)**: Nuevas funcionalidades de peso medio (ej. añadir nuevos músculos, buscador global de ejercicios, temporizador de descanso, sistema de sonido avanzado, pantalla de ajustes).
> - **MAJOR (x.0.0)**: Hitos de gran envergadura (ej. lanzamiento oficial a tiendas de aplicaciones Google Play / App Store v1.0.0, rediseño total de la arquitectura, multijugador online).
> 
> *Nota clave*: Cada salto de versión es validado y decidido expresamente por el usuario. Actualmente nos mantenemos en **v0.0.1** completando la base de funcionalidades antes de saltar a la siguiente versión.

---

## [0.0.1] - 2026-09-14 (Versión Actual en Desarrollo)

### Estado: En desarrollo activo

### 🚀 Novedades y Funcionalidades Desarrolladas:

1. **Nueva Curva de Nivel Recursiva (+15% Compuesto)**:
   - Niveles 1 a 4: Costo lineal de 100, 200, 300 y 400 XP.
   - Nivel 5: Para ascender al Nivel 6 se requieren 1,000 XP.
   - A partir del Nivel 6 en adelante: Cada nivel cuesta un **15% más de forma recursiva/compuesta** sobre el anterior ($1000 \times 1.15^{(L - 5)}$).
   - Implementado en Flutter (`Muscle.xpForNextLevel`) y en el servidor Python (`/api/xp_curve`).

2. **Sistema de Racha Diaria con Multiplicador de XP**:
   - Menos de 7 días: Multiplicador base $1.0\times$ (+0% bonus).
   - **7 días o más de racha**: Multiplicador $1.05\times$ (**+5% XP adicional** en todos los ejercicios).
   - **30 días o más de racha**: Multiplicador $1.10\times$ (**+10% XP adicional** en todos los ejercicios).
   - Indicador visual animado de racha y bonus activo en la cabecera de la aplicación.

3. **Las 4 Pruebas Legendarias del Olimpo (Misiones Diarias Elegibles)**:
   - Se reemplazaron las misiones genéricas por 4 retos emblemáticos seleccionables:
     1. **100 Flexiones** (100 reps)
     2. **100 Sentadillas** (100 reps)
     3. **100 Abdominales** (100 reps)
     4. **Carrera de 10 Kilómetros** (10 km)
   - El jugador puede elegir su misión diaria principal. Completar cualquiera de las 4 pruebas antes de medianoche protege el nivel del jugador y prolonga su racha.

4. **Temporizador de Descanso (Rest Timer) & Sistema Anti-Trampas**:
   - Se abre automáticamente tras registrar cualquier serie de entrenamiento.
   - Cuenta atrás circular con presets rápidos (+30s, +60s, -15s) y aviso sonoro/háptico al terminar.
   - **Mecanismo Anti-Trampas**: Límite de 200 repeticiones lógicas por set y detección de spam de series en menos de 5 segundos con advertencia del Sistema.

5. **Biblioteca y Buscador de Ejercicios en Tiempo Real**:
   - Pestaña de navegación dedicada con buscador instantáneo por nombre y técnica.
   - Filtros rápidos por grupo muscular (Pecho, Deltoides, Dorsales, Bíceps, Tríceps, Piernas, Core) y equipamiento.
   - Visualización de multiplicadores de XP por kg y botón de acceso directo al entrenamiento.

6. **Logros y Títulos Mitológicos Desbloqueables**:
   - Sistema de títulos equipables que otorgan beneficios pasivos ("El Despanchizado", "Devorador de Hierro", "Hijo de Ares", "Voluntad Espartana", "Fuerza Herclúlea", "Dios del Olimpo").
   - El título seleccionado se equipa y se muestra en la cabecera principal y en la ventana de estado.

7. **Ajustes del Sistema & Cumplimiento Legal (App Store / Google Play)**:
   - Interruptores para activar/desactivar sonido del Sistema y respuesta háptica.
   - Selector de tiempo de descanso por defecto.
   - Configuración y test de IP del servidor Python local.
   - Exportación de copias de seguridad en formato JSON al portapapeles.
   - Opción de reinicio de cuenta ("Nuevo Despertar") con confirmación de seguridad.
   - Textos legales completos integrados: Términos y Condiciones, Política de Privacidad (datos 100% locales) y Descargo de Responsabilidad Médica.

8. **Navegación Inferior Multisección**:
   - `IndexedStack` en `HomeScreen` con 4 pestañas: Cuerpo (Anatomía interactiva), Biblioteca, Títulos y Ajustes.

9. **Mazmorras Semanales para Ascenso de Rango & Regla de Balance Muscular (-2 Rangos)**:
   - Mazmorra de ascenso con 3 senderos a elegir: Pecho, Espalda o Piernas.
   - **Regla inquebrantable de balance**: Para ascender al rango objetivo $T$, ningún músculo puede encontrarse a más de 2 rangos de diferencia ($T - 2$). Si hay músculos atrasados, el Sistema bloquea la prueba y nombra explícitamente cuáles deben subirse de nivel antes de permitir el ascenso.

10. **Calculadora Visual de Discos en Barra Olímpica (Plate Calculator)**:
    - Barra olímpica de 20 kg con manga visual en SVG/colores oficiales de halterofilia (25kg rojo, 20kg azul, 15kg amarillo, 10kg verde, 5kg blanco, 2.5kg plata, 1.25kg gris).
    - Acceso directo e interactivo desde el modal de registro de series de entrenamiento (`MuscleDetailSheet`).

11. **Tokens de Descanso (Rest Day Tokens) & Preservación de Racha**:
    - Obtención de 1 token de descanso cada 6 días consecutivos de racha.
    - Su consumo congela la penalización de medianoche en días de descanso físico programado sin perder el multiplicador de racha.

12. **Poder de Combate (Combat Power - CP)**:
    - Indicador numérico de estatus calculado mediante: `(Nivel Total * 100) + (STR * 15) + (AGI * 10) + (END * 12) + (DIS * 8)`.
    - Presente en la barra superior de la pantalla principal y en la Ventana de Estado.

14. **Bloqueo Estricto de Orientación Vertical (Portrait Only)**:
    - Bloqueo exclusivo a orientación vertical tanto a nivel de código (`SystemChrome.setPreferredOrientations`) como a nivel nativo en Android (`AndroidManifest.xml`) e iOS (`Info.plist`).

15. **Auditoría de Diseño Responsive & Prevención de Overflows**:
    - Adaptabilidad garantizada en pantallas estrechas (desde 320px como iPhone SE hasta tablets) con `FittedBox`, `Flexible` y `LayoutBuilder` en cabeceras, leyendas y subheaders.

16. **Estimador Científico de 1RM (Fórmulas de Epley y Brzycki)**:
    - Cálculo de una repetición máxima en tiempo real en `MuscleDetailSheet` y cálculo promedio con base científica.

17. **Detección Automática de Récords Personales (PR) & Historial de Batalla**:
    - Detección de superación de marca histórica por ejercicio con diálogo épico dorado y +50 XP de Bonificación Divina al músculo principal.
    - Hoja de Historial de Batalla (`WorkoutHistorySheet`) con desglose de series y Tonelaje Total Levantado Hoy ($\sum kg \times reps$).

18. **Gestión Documental y Pruebas Automatizadas**:
    - `CONTEXT.md` y `TREE.md` actualizados.
    - 100% de pruebas superadas: 7/7 en Python (`pytest`) y 15/15 en Flutter (`flutter test`).
    - 0 errores y 0 warnings en `flutter analyze`.

19. **Integración de Skills CLI & Skill `find-skills`**:
    - Instalación de la skill `find-skills` de `vercel-labs/skills` en `.agents/skills/find-skills/` con archivo de bloqueo `skills-lock.json`.
    - Permite descubrir, buscar e instalar habilidades y flujos de trabajo adicionales desde el ecosistema abierto de skills.

20. **Integración de la Skill Oficial de Arquitectura Flutter (`flutter-apply-architecture-best-practices`)**:
    - Instalación de `flutter-apply-architecture-best-practices` desde `flutter/agent-plugins` en `.agents/skills/flutter-apply-architecture-best-practices/`.
    - Guías y directivas oficiales del equipo de Flutter para estructurar la aplicación por capas (Data, Domain, Presentation), separar responsabilidades y optimizar el manejo de estado reactivo.

21. **Integración de la Skill Oficial de Layouts Responsive (`flutter-build-responsive-layout`)**:
    - Instalación de `flutter-build-responsive-layout` desde `flutter/agent-plugins` en `.agents/skills/flutter-build-responsive-layout/`.
    - Guías y estándares para adaptar dinámicamente vistas móviles y de escritorio mediante `LayoutBuilder`, `MediaQuery`, constraints flexibles y breakpoints adaptativos sin overflows.

22. **Integración de la Skill Oficial de Corrección de Layouts (`flutter-fix-layout-issues`)**:
    - Instalación de `flutter-fix-layout-issues` desde `flutter/agent-plugins` en `.agents/skills/flutter-fix-layout-issues/`.
    - Procedimientos sistemáticos para depuración de árboles de widgets, resolución de errores de constraints no acotadas (`unbounded height/width`) y eliminación de líneas amarillas/negras de desbordamiento en Flutter.

23. **Integración de la Skill Oficial de Pruebas de Widgets (`flutter-add-widget-test`)**:
    - Instalación de `flutter-add-widget-test` desde `flutter/agent-plugins` en `.agents/skills/flutter-add-widget-test/`.
    - Metodología y directivas oficiales para implementar pruebas de componentes con `WidgetTester`, interacción de usuario (`tap`, `enterText`, `scrollUntilVisible`), bombeo de frames (`pump`, `pumpAndSettle`) y verificación con `Finder` y `Matcher`.

24. **Expansión del Ecosistema de Capacidades a 25 Skills Oficiales**:
    - Instalación y configuración en `.agents/skills/` de 20 skills complementarias de `flutter/agent-plugins`, `github/awesome-copilot` y `obra/superpowers`:
      - **Flutter/Dart**: `flutter-add-integration-test`, `flutter-implement-json-serialization`, `flutter-setup-localization`, `flutter-setup-declarative-routing`, `flutter-add-widget-preview`, `flutter-use-http-package`, `dart-add-unit-test`, `dart-collect-coverage`, `dart-fix-runtime-errors`, `dart-generate-test-mocks`.
      - **Gestión, CI/CD y Calidad**: `git-commit`, `github-issues`, `github-release`, `create-github-action-workflow-specification`, `documentation-writer`, `test-driven-development`, `pytest-coverage`, `refactor`, `prd`, `excalidraw-diagram-generator`.

25. **Auditoría y Recuperación Íntegra del Directorio `app/`**:
    - Detección de desplazamiento accidental del directorio `app/` a `.pytest_cache/app` durante la ejecución paralela previa.
    - Restauración inmediata a la raíz del repositorio (`/app`).
    - Verificación completa con 15/15 tests superados en Flutter y 0 errores de análisis.

26. **Auditoría Técnica Archivo por Archivo & Blindaje Responsive Total (29/29 Tests)**:
    - **Bloqueo Vertical en Móvil**: Garantizado mediante `SystemChrome.setPreferredOrientations` en Dart y metadatos nativos en Android (`AndroidManifest.xml`) e iOS (`Info.plist`).
    - **Base de Datos SQLite**: Sincronización de esquema en `database_helper.dart` (añadidos `equipped_title`, `selected_daily_quest_id`, `rest_tokens`, `is_rest_day_used_today` e `is_selected`), versión 2 con migración automática `ALTER TABLE`.
    - **Sincronización REST**: Serialización completa de los 14 músculos enviada a `/api/player/sync` en Python.
    - **Resolución Sistemática de Desbordamientos (RenderFlex Overflows)**:
      - `RankDungeonSheet`: Subtítulo flexible + badge con `FittedBox` y título independiente escalable.
      - `WorkoutHistorySheet`: Cabecera adaptable, banner de tonelaje con `Expanded` y columna de métricas de serie con `FittedBox`.
      - `MuscleDetailSheet`: Cabecera de músculo, badges de impacto con `Wrap`, selector de peso/discos y tarjetas de 1RM y PR con `FittedBox`.
      - `ExerciseLibraryScreen`: Badges de músculo primario y secundario con `Expanded(child: Wrap(...))` y título adaptativo.
      - `AchievementsScreen`: Título adaptativo y par título/badge con `Wrap`.
      - `SettingsScreen`: Título adaptativo y fila de tiempo de descanso con `Expanded`.
      - `SystemBootScreen`: Título y lema principal con `FittedBox`.
    - **Batería de Pruebas**: 29/29 tests en verde (15 unitarios en `models_test.dart` y 14 de widgets en `widget_test.dart` simulando pantalla ultra-compacta de 320x568).
    - **Análisis de Código**: `flutter analyze` 100% limpio (0 errores, 0 warnings).

27. **Suite de Pruebas y Adaptación para Pantallas Medianas y Grandes (37/37 Tests)**:
    - **Pantallas Medianas (Tablets / iPad 768x1024)**: 4 pruebas automatizadas para `HomeScreen`, `MuscleDetailSheet`, `RankDungeonSheet` y `PlateCalculatorSheet`.
    - **Pantallas Grandes (iPad Pro / Desktop 1024x1366)**: 4 pruebas automatizadas para `HomeScreen`, `WorkoutHistorySheet`, `ExerciseLibraryScreen` y `HunterStatsSheet`.
    - **Terminal HUD Centering (Diseño Táctico Acotado)**:
      - En `HomeScreen`: siluetas anatómicas y barra de misión acotadas con `maxWidth: 850` centrado en pantallas grandes para preservar la estética original.
      - En hojas modales inferiores (`MuscleDetailSheet`, `DailyQuestSheet`, `HunterStatsSheet`, `RankDungeonSheet`, `WorkoutHistorySheet`, `PlateCalculatorSheet`, `RestTimerSheet`): alineación inferior centrada con `maxWidth: 650` (`Align(alignment: Alignment.bottomCenter)`), presentándose como una consola táctica holográfica centrada en lugar de una franja horizontal estirada.
    - **Ajuste de Framework en `SettingsScreen`**: `ListTile` envueltos en `Material(color: Colors.transparent)` solucionando advertencia de splash en `DecoratedBox`.
    - **Total de Tests en Verde**: **37/37 tests (100%)**.
    - **Análisis Estático**: `flutter analyze` con 0 errores y 0 warnings.

28. **Autenticación Cifrada SQLite, Cuenta sajiadmin, Panel Web Localhost y Preparación para GitHub**:
    - **Sistema de Autenticación Cifrada (SQLite v3)**:
      - Creación de tablas `users` y `auth_sessions` con persistencia de sesión activa.
      - Hashing seguro SHA-256 con salt criptográfico aleatorio individual mediante `PasswordHasher`.
      - Cuenta de administrador y desarrollador predeterminada: **`sajiadmin`** con contraseña **`sajiadmin`** (almacenada cifrada) y rol `admin,developer`.
      - Pantalla holográfica `AuthScreen` para Iniciar Sesión y Despertar de Cazador, con atajo rápido para rellenar `sajiadmin`.
      - Enrutamiento dinámico en `SystemBootScreen` según el estado de sesión activa.
      - Cierre de sesión seguro ("CERRAR SESIÓN") con confirmación en `SettingsScreen`.
    - **Terminal del Desarrollador (God Mode HUD)**:
      - Modal `DeveloperTerminalDialog` accesible en AppBar y Ajustes exclusivamente para roles `admin` y `developer`.
      - Herramientas de QA rápido: subir +5 niveles a todos los músculos, inyectar +10,000 XP a músculos objetivo, simular penalización de medianoche, añadir tokens de descanso y reiniciar misiones.
    - **Panel Web en Python (FastAPI `http://localhost:8000`) & Exportación a APK**:
      - Pestaña "⚙️ Ajustes Globales & APK" en `server/templates/index.html`.
      - Configuración en vivo de:
        - Tiempo de descanso por defecto entre ejercicios (slider de 30 a 300 segundos).
        - Curva de XP por nivel (base de Nivel 6 y porcentaje compuesto del 15%).
        - Multiplicadores de XP por ejercicio e intervalos de los 8 rangos.
      - Botón "🚀 Exportar a Assets para APK" que genera `app/assets/config/game_config.json`.
      - `GameConfigService` en Flutter para ejecutar el APK de forma 100% offline con la configuración exportada.
    - **Archivo `.gitignore` Maestro en Raíz**:
      - Configuración exhaustiva para GitHub ignorando cachés de Python (`__pycache__`, `.pytest_cache`), Flutter (`.dart_tool`, `build`), Android (`.gradle`, `local.properties`), iOS/macOS (`Pods`, `.symlinks`, `ephemeral`), IDEs (`.idea`, `.vscode`, `*.iml`), y archivos `.DS_Store`.
    - **Suite de Pruebas**:
      - **48/48 tests en Flutter (100% verde)** incluyendo 11 nuevas pruebas unitarias en `test/auth_test.dart`.
      - **9/9 tests en Python (100% verde)** con `pytest`.
      - **0 errores y 0 warnings** en `flutter analyze`.

