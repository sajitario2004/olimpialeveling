# CONTEXT.md - Olimpia Leveling: Master Project Context & Specification

> **Propósito de este documento**: Este archivo almacena el 100% del contexto, reglas de negocio, decisiones técnicas, arquitectura, fórmulas matemáticas y visión del producto de **Olimpia Leveling**. Está diseñado para que cualquier IA, agente o desarrollador que tome el proyecto pueda continuar el desarrollo sin perder ningún detalle histórico ni técnico.

---

## 1. Visión y Concepto del Proyecto
- **Nombre**: Olimpia Leveling
- **Slogan**: *"De skinny bitch a dios del olimpo (despanchizado)"*
- **Inspiración**: El concepto y la interfaz holográfica del "Sistema" del manhwa/anime **Solo Leveling**, fusionado con la mitología del **Olimpo** y la disciplina del entrenamiento de fuerza/gimnasio.
- **Objetivo**: Convertir el entrenamiento físico y la transformación corporal en un RPG de ascensión real, donde cada repetición y cada kilo levantado otorga experiencia concreta a músculos específicos, visualizados en un mapa de calor anatómico interactivo.

---

## 2. Pila Tecnológica (Tech Stack)

### Frontend Móvil y Escritorio (`app/`)
- **Framework**: Flutter 3.x (Dart 3.x).
- **Soporte Multiplataforma**:
  - **Android**: Compatible con teléfonos y tablets (permisos `INTERNET` y `VIBRATE` en `AndroidManifest.xml`).
  - **iOS (iPhone & iPad)**: `NSAppTransportSecurity` configurado para red local/remota en `Info.plist`.
  - **macOS Desktop**: Soporte nativo para pruebas y desarrollo directo en Mac sin necesidad de emulador.
- **Base de Datos Local**: SQLite mediante `sqflite` (móvil) y `sqflite_common_ffi` (escritorio).
- **Gestión de Estado**: `Provider` (`ChangeNotifier`).
- **Diseño & UI**: Estética holográfica neón oscuro, fuentes `Orbitron` y `Rajdhani` vía `google_fonts`, micro-animaciones con `flutter_animate`.
- **Efectos Audiovisuales**: Reproductor de audio (`audioplayers`) con efectos de sonido sintetizados en `.wav` (`system_level_up.wav` y `penalty_alert.wav`).

### Backend y Dashboard de Balanceo Local (`server/`)
- **Framework**: Python 3.14 con **FastAPI** y servidor ASGI **Uvicorn**.
- **Puerto de Ejecución**: `http://localhost:8000` (o `0.0.0.0:8000` para acceso en red local desde dispositivos móviles).
- **Panel Visual Web**: Dashboard interactivo con Jinja2 templates y Tailwind CSS para modificar en vivo misiones, intervalos de nivel, multiplicadores de ejercicios y probar cálculos en el simulador.
- **Persistencia de Configuración**: `server/config_data.json` con respaldo en `server/default_config.json`.
- **Pruebas Automatizadas**: `pytest` con `httpx` (`TestClient`).

---

## 3. Jerarquía del Olimpo: Los 8 Rangos
El rango del Cazador se determina automáticamente en base a su nivel unificado de 0 a 100 (y los niveles de los músculos individuales):

| # | Rango (ID) | Nombre Mostrado | Intervalo de Nivel | Prueba de Ascensión | Color Neón | Descripción / Cita del Sistema |
|---|------------|-----------------|--------------------|---------------------|------------|--------------------------------|
| 1 | `skinnybitch` | **SKINNYBITCH** | Niveles 0 - 4 | En Nivel 4 | `#94A3B8` (Gris Slate) | *"El inicio de todo despertar. Débil pero con potencial divino."* |
| 2 | `human` | **HUMAN** | Niveles 5 - 14 | En Nivel 14 | `#38BDF8` (Azul Cielo) | *"Has superado la fragilidad común. El hierro empieza a obedecerte."* |
| 3 | `normal_gym_buddy` | **NORMAL GYM BUDDY** | Niveles 15 - 29 | En Nivel 29 | `#06B6D4` (Azul Cian) | *"Tu presencia en el gimnasio ya es constante. Eres un compañero digno."* |
| 4 | `gymbro` | **GYMBRO** | Niveles 30 - 49 | En Nivel 49 | `#10B981` (Verde Esmeralda) | *"El sudor y la disciplina corren por tus venas. Respetado por tus pares."* |
| 5 | `soldier` | **SOLDIER** | Niveles 50 - 64 | En Nivel 64 | `#EAB308` (Oro Militar) | *"Disciplina militar espartana. El dolor es debilidad abandonando el cuerpo."* |
| 6 | `spartan` | **SPARTAN** | Niveles 65 - 79 | En Nivel 79 | `#F97316` (Naranja Ardiente) | *"¡Esto es Esparta! Ningún peso ni fatiga quebranta tu voluntad."* |
| 7 | `hercules` | **HERCULES** | Niveles 80 - 100 | En Nivel 98 y Nivel 100 (Previo a Prueba Suprema) | `#EF4444` (Rojo Carmesí) | *"Fuerza mitológica sobrehumana. Capaz de realizar los 12 trabajos."* |
| 8 | `god_of_olimpus` | **GOD OF OLIMPUS** | Nivel 100 (Supremo) | Prueba Suprema del Olimpo Superada | `#A855F7` / `#FFD700` | *"Ascensión celestial consumada. Te sientas en el trono del Olimpo."* |

---

## 4. Los 14 Grupos Musculares y Mapa de Calor Anatómico

### Lista Oficial de los 14 Músculos
1. **Pecho** (Pectoral mayor y menor) - Vista frontal
2. **Tríceps** (Cabeza lateral, medial y larga) - Vista dorsal
3. **Bíceps** (Cabeza corta y larga del bíceps braquial) - Vista frontal
4. **Antebrazo** (Flexores y extensores) - Vista frontal
5. **Dorsales** (Dorsal ancho y redondo mayor) - Vista dorsal
6. **Trapecio** (Superior, medio e inferior) - Vista dorsal
7. **Lumbar** (Erectores espinales) - Vista dorsal
8. **Deltoides** (Anterior, lateral y posterior) - Vista frontal y dorsal
9. **Cuádriceps** (Vasto externo, interno, recto femoral) - Vista frontal
10. **Isquiotibiales** (Bíceps femoral, semitendinoso, semimembranoso) - Vista dorsal
11. **Glúteos** (Glúteo mayor, medio y menor) - Vista dorsal
12. **Gemelos** (Gastrocnemio y sóleo) - Vista frontal y dorsal
13. **Abdominales** (Recto abdominal) - Vista frontal
14. **Oblicuos** (Oblicuos internos y externos) - Vista frontal

### Dinámica del Mapa de Calor (Heat Map)
Cada músculo tiene su propio nivel independiente. Su representación gráfica cambia dinámicamente de color según su nivel:
- **Nivel 0 a 4**: `#64748B` (Gris / Skinnybitch)
- **Nivel 5 a 14**: `#38BDF8` (Azul Neón / Human)
- **Nivel 15 a 29**: `#06B6D4` (Cian / Normal Gym Buddy)
- **Nivel 30 a 49**: `#10B981` (Verde Cazador / Gymbro)
- **Nivel 50 a 64**: `#EAB308` (Oro Militar / Soldier)
- **Nivel 65 a 79**: `#F97316` (Naranja Ardiente / Spartan)
- **Nivel 80 a 98**: `#EF4444` (Rojo Carmesí / Hercules)
- **Nivel 99 a 100**: `#A855F7` / `#FFD700` (Púrpura y Oro Divino / God of Olimpus)

---

## 5. Fórmulas Matemáticas y Reglas de Progresión

### 1. Curva Recursiva de Experiencia por Músculo
Para pasar del nivel $L$ al nivel $L+1$:
- **Nivel 1**: 100 XP
- **Nivel 2**: 200 XP
- **Nivel 3**: 300 XP
- **Nivel 4**: 400 XP (Requiere prueba física para subir a Nivel 5)
- **Nivel 5 ➔ 6**: 1,000 XP
- **Nivel $6 \le L \le 98$**: Incremento recursivo del **15% compuesto** sobre el nivel anterior:
$$\text{XP}(L) = 1000 \times 1.15^{(L - 5)}$$
- **Nivel 99 ➔ 100 (Cúspide Divina)**: Se requieren **20 veces más XP** que para pasar de 98 a 99:
$$\text{XP}(99 \to 100) = \text{XP}(98 \to 99) \times 20.0 = (1000 \times 1.15^{93}) \times 20.0$$

### 2. Multiplicador de Racha de Días (Streak XP Bonus)
Recompensa acumulativa por constancia diaria:
- Menos de 7 días: Multiplicador $1.0\times$ (+0% bonus)
- **7 a 29 días de racha**: Multiplicador $1.05\times$ (**+5% XP adicional** en todos los ejercicios)
- **30 días o más de racha**: Multiplicador $1.10\times$ (**+10% XP adicional** en todos los ejercicios)

### 3. Mecánica Drop Set (Multiplicadores de Saltos de Peso)
Cuando un cazador realiza reducciones de peso consecutivas tras el fallo sin descanso en la misma serie:
- **0 Saltos (Normal)**: Multiplicador $1\times$ XP.
- **1 Salto**: Multiplicador $2\times$ XP.
- **2 Saltos**: Multiplicador $3\times$ XP.
- **3 o más Saltos**: Multiplicador $4\times$ XP (límite máximo $4\times$).

### 4. Fórmulas de XP por Ejercicio
$$\text{XP}_{\text{primaria}} = \left(\frac{\text{Peso (kg)} \times \text{Multiplicador}_{\text{primario}} \times \text{Reps}}{10} + \text{Base XP}\right) \times \text{DropsetMultiplier} \times \text{StreakMultiplier}$$
$$\text{XP}_{\text{secundaria}} = \left(\frac{\text{Peso (kg)} \times \text{Multiplicador}_{\text{secundario}} \times \text{Reps}}{10} + (\text{Base XP} \times 0.5)\right) \times \text{DropsetMultiplier} \times \text{StreakMultiplier}$$

---

## 6. Las 4 Misiones Diarias del Olimpo y Penalización

### Selección Diaria
El cazador puede elegir libremente entre **4 pruebas legendarias** cada día:
1. **100 Flexiones** (100 reps)
2. **100 Sentadillas** (100 reps)
3. **100 Abdominales** (100 reps)
4. **Carrera de 10 Kilómetros** (10 km)

### Regla de Penalización
- Temporizador en cuenta regresiva que finaliza a las **23:59:59**.
- Completar cualquiera de las 4 pruebas (o la seleccionada) antes de medianoche protege el nivel del cazador y extiende la racha diaria.
- Si llega la medianoche sin completar la misión:
  - Se activa la **Alarma Roja del Sistema** y sonido de penalización.
  - El jugador **pierde 1 nivel total**: $\text{Nivel} = \max(14, \text{Nivel} - 1)$.
  - Se descuenta 1 nivel del músculo más desarrollado para mantener la consistencia de la suma.

---

## 7. Nuevos Módulos Profesionales Integrados

### 1. Temporizador de Descanso (Rest Timer) & Anti-Cheat
- Al registrar una serie, se despliega automáticamente el cronómetro de descanso (60s, 90s, 120s, 180s) con aviso sonoro y háptico al terminar.
- **Sistema Anti-Trampas**:
  - Límite máximo de 200 reps por serie para prevenir datos fraudulentos.
  - Detección de cadencia anormal (<5 segundos entre series) con aviso del Sistema para proteger la técnica y salud.

### 2. Biblioteca y Buscador de Ejercicios (`ExerciseLibraryScreen`)
- Búsqueda en tiempo real por texto.
- Filtros rápidos por grupo muscular (Pecho, Deltoides, Dorsales, Bíceps, Tríceps, Piernas, Core) y equipamiento.
- Ficha técnica de cada ejercicio con multiplicadores de XP y botón directo para entrenar.

### 3. Logros y Títulos Mitológicos (`AchievementsScreen`)
- Títulos desbloqueables equipables estilo Solo Leveling:
  - *"El Despanchizado"*: Nivel 25 alcanzado (+2% XP Abdominales y Oblicuos).
  - *"Devorador de Hierro"*: Nivel 55 alcanzado (+5% XP Pecho y Espalda).
  - *"Hijo de Ares"*: 7 días de racha diaria (+5% XP General).
  - *"Voluntad Espartana"*: Rango Spartan (+8% XP Piernas y Hombros).
  - *"Fuerza Herclúlea"*: Nivel 300 alcanzado (+10% XP Brazos).
  - *"Dios del Olimpo"*: Rango God of Olimpus (+15% XP Divina).

### 4. Ajustes del Sistema & Cumplimiento Legal (`SettingsScreen`)
- Interruptores de Sonidos y Hápticos.
- Selector de descanso por defecto.
- Configuración de IP/puerto del servidor local Python con botón de test de conexión.
- Copia de seguridad exportable en formato JSON.
- Reinicio de cuenta con confirmación de seguridad.
- Documentos legales integrados:
  - Términos y Condiciones de Uso.
### 5. Mazmorras Semanales para Ascenso de Rango (`RankDungeonSheet`)
- Mazmorra de ascenso con 3 pruebas físicas a elegir: Pecho, Espalda o Pierna.
- **Regla Estricta de Balance Muscular (-2 Rangos)**:
  - Para ascender al rango objetivo $T$, ningún músculo puede estar a más de 2 rangos por debajo: $\text{Rango Músculo} \ge \max(0, T - 2)$.
  - Si existen músculos rezagados (por ejemplo, querer subir a rango 4 teniendo un músculo en rango 1), el Sistema deniega el acceso a la prueba y enumera explícitamente los músculos retrasados que deben entrenarse primero.

### 6. Calculadora Visual de Discos en Barra Olímpica (`PlateCalculatorSheet`)
- Barra olímpica estándar de 20 kg.
- Visualización gráfica de la manga de la barra con los discos necesarios por lado según la norma internacional de colores (25kg rojo, 20kg azul, 15kg amarillo, 10kg verde, 5kg blanco, 2.5kg plata, 1.25kg gris).
- Accesible desde la barra superior y desde el modal de registro de series para aplicar el peso directamente.

### 7. Tokens de Día de Descanso (Rest Day Tokens)
- Otorga 1 token cada 6 días consecutivos de racha.
- Consumir el token congela la penalización de medianoche en días de descanso físico sin perder la racha acumulada ni los multiplicadores de XP.

### 8. Poder de Combate (Combat Power - CP)
- Métrica global de poder del cazador mostrada en la cabecera y ventana de estado:
$$\text{CP} = (\text{TotalLevel} \times 100) + (\text{STR} \times 15) + (\text{AGI} \times 10) + (\text{END} \times 12) + (\text{DIS} \times 8)$$

### 9. Bloqueo Estricto de Orientación Vertical (Portrait Only)
- Orientación de pantalla bloqueada a Portrait (`portraitUp` y `portraitDown`) en todos los dispositivos móviles:
  - Flutter: `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])`.
  - Android: `android:screenOrientation="portrait"` en `AndroidManifest.xml`.
  - iOS: `UISupportedInterfaceOrientations` restringido a `UIInterfaceOrientationPortrait` en `Info.plist`.

### 10. Estimador Científico de 1RM (Fórmulas de Epley y Brzycki)
- Cálculo integrado de repetición máxima en tiempo real en `MuscleDetailSheet` y `WorkoutHistorySheet`:
  - **Fórmula de Epley**: $\text{1RM} = \text{Peso} \times \left(1 + \frac{\text{Reps}}{30}\right)$
  - **Fórmula de Brzycki**: $\text{1RM} = \text{Peso} \times \left(\frac{36}{37 - \text{Reps}}\right)$ (para $\text{Reps} < 37$)
  - **Estimación Equilibrada**: Promedio aritmético entre ambas fórmulas para ofrecer un resultado riguroso.

### 11. Detección Automática de Récord Personal (PR)
- Al registrar una serie, si el peso levantado supera el máximo histórico registrado para ese ejercicio:
  - Se dispara un diálogo épico dorado de celebración: *"¡NUEVO RÉCORD PERSONAL (PR)!"*.
  - Se otorga una bonificación divina de **+50 XP** al músculo primario asignado.

### 12. Registro de Batalla & Tonelaje Total (`WorkoutHistorySheet`)
- Hoja accesible desde el icono de historial en la cabecera:
  - Resumen de **Tonelaje Total Acumulado Hoy**: $\sum (\text{Peso} \times \text{Reps})$ kg.
  - Listado cronológico de series realizadas con detalle de fecha, ejercicio, músculo, 1RM estimado y XP otorgada.

### 13. Ecosistema de Skills CLI (`find-skills`)
- Integración de la herramienta de gestión de habilidades abiertas mediante Skills CLI (`npx skills`).
- Skill instalada en `.agents/skills/find-skills/` con seguimiento en `skills-lock.json`.
- Permite buscar y añadir paquetes de capacidades avanzadas (ej. diseño, testing, optimizaciones) desde el registro central de `skills.sh`.

### 14. Directivas de Arquitectura Flutter (`flutter-apply-architecture-best-practices`)
- Skill oficial instalada en `.agents/skills/flutter-apply-architecture-best-practices/`.
- Proporciona lineamientos y estándares de ingeniería en Flutter: separación en capas de Presentación, Dominio y Datos, minimización de rebuilds innecesarios, repositorios abstractos y cohesión en la inyección de dependencias.

### 15. Directivas de Interfaces Responsive en Flutter (`flutter-build-responsive-layout`)
- Skill oficial instalada en `.agents/skills/flutter-build-responsive-layout/`.
- Guías canónicas para diseñar interfaces que se adaptan a múltiples tamaños de pantalla y densidades de píxeles: uso de `LayoutBuilder`, `FittedBox`, `Flexible`, fluid typography y cálculo dinámico de layouts evitando desbordamientos (`RenderFlex overflow`).
### 16. Resolución de Problemas de Layout en Flutter (`flutter-fix-layout-issues`)
- Skill oficial instalada en `.agents/skills/flutter-fix-layout-issues/`.
- Proporciona diagnósticos y correcciones sistemáticas para errores comunes de renderizado en Flutter: `RenderFlex overflowed by X pixels`, `A RenderFlex overflowed`, `Vertical viewport was given unbounded height`, `BoxConstraints forces infinite width/height`, `IntrinsicWidth/IntrinsicHeight` bottlenecks, y manejo preventivo con `SingleChildScrollView`, `Flexible`, `Expanded` y `FittedBox`.

### 17. Implementación de Pruebas de Widgets (`flutter-add-widget-test`)
- Skill oficial instalada en `.agents/skills/flutter-add-widget-test/`.
- Proporciona el flujo canónico para diseñar y ejecutar pruebas de componentes de Flutter usando `WidgetTester`:
  - **Fase de construcción**: Inyección en entorno de prueba con `pumpWidget`, herencia de temas y localización.
  - **Interacciones de usuario simuladas**: `tester.tap()`, `tester.enterText()`, `tester.drag()`, `tester.scrollUntilVisible()`.
  - **Gestión de frames y animaciones**: Control temporal mediante `tester.pump()` para un único frame o `tester.pumpAndSettle()` hasta la finalización de transiciones y microtareas.
  - **Validación declarativa**: Localización de widgets mediante `Finder` (`find.text`, `find.byType`, `find.byKey`) y aserciones rigurosas con `Matcher` (`findsOneWidget`, `findsNothing`, `matchesGoldenFile`).

### 18. Ecosistema de 25 Skills Oficiales Activas en `.agents/skills/`
- **Flutter & Dart**:
  - `find-skills`: Búsqueda e instalación de nuevas habilidades desde el registro global.
  - `flutter-apply-architecture-best-practices`: Arquitectura por capas (Data/Domain/Presentation).
  - `flutter-build-responsive-layout`: Diseño adaptativo, fluid typography y cero overflows.
  - `flutter-fix-layout-issues`: Resolución sistemática de desbordamientos `RenderFlex`.
  - `flutter-add-widget-test`: Pruebas de widgets con `WidgetTester`, `Finder` y matchers.
  - `flutter-add-integration-test`: Tests de integración automatizados con `integration_test`.
  - `flutter-implement-json-serialization`: Serialización y deserialización JSON tipada.
  - `flutter-setup-localization`: Soporte multilingüe e internacionalización.
  - `flutter-setup-declarative-routing`: Enrutamiento declarativo y deep linking.
  - `flutter-add-widget-preview`: Vistas previas de widgets interactivos.
  - `flutter-use-http-package`: Consumo seguro de APIs REST con `http`.
  - `dart-add-unit-test`: Pruebas unitarias de modelos matemáticos y lógica.
  - `dart-collect-coverage`: Generación de informes de cobertura LCOV.
  - `dart-fix-runtime-errors`: Análisis de stack traces y corrección de errores en runtime.
  - `dart-generate-test-mocks`: Generación de mocks con `mockito` y `build_runner`.

- **Gestión, CI/CD, Calidad y Backend**:
  - `git-commit`: Convenciones de commit atómicos semánticos (Conventional Commits).
  - `github-issues`: Creación y gestión de issues y milestones en GitHub.
  - `github-release`: Control de releases SemVer y generación automática de changelogs.
  - `create-github-action-workflow-specification`: Automatización de pipelines CI/CD en GitHub Actions.
  - `documentation-writer`: Documentación técnica estructurada bajo el estándar Diátaxis.
  - `test-driven-development`: Desarrollo guiado por pruebas (TDD) para nuevas mecánicas de juego.
  - `pytest-coverage`: Cobertura de pruebas en el backend Python FastAPI.
  - `refactor`: Refactorización limpia sin alterar comportamiento funcional.
  - `prd`: Creación de Product Requirements Documents para nuevas expansiones.
  - `excalidraw-diagram-generator`: Diagramas de flujo y arquitectura visual.

### 19. Auditoría Integral Archivo por Archivo & Suite de Pruebas (29/29 Passing)
- **Bloqueo Estricto de Orientación Vertical**: Configurado con `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])` en `main.dart`, además de `android:screenOrientation="portrait"` en Android y `UISupportedInterfaceOrientations` en iOS.
- **Auditoría de Base de Datos SQLite**: En `app/lib/core/database/database_helper.dart`, se corrigieron los esquemas de creación que carecían de `equipped_title`, `selected_daily_quest_id`, `rest_tokens`, `is_rest_day_used_today` e `is_selected`. Se elevó la versión de BD a 2 con migración automática `onUpgrade` (`ALTER TABLE ADD COLUMN`).
- **Sincronización de Servidor REST**: En `app/lib/core/sync/server_sync_service.dart` y `app/lib/providers/game_provider.dart`, se implementó la serialización completa de los 14 músculos para el endpoint `/api/player/sync`.
- **Resolución de Fallos de Layout (RenderFlex Overflows)**:
  - `RankDungeonSheet`: Subtítulo y badge envueltos en `Flexible` + `FittedBox`, y título principal en línea propia con `FittedBox`.
  - `WorkoutHistorySheet`: Cabecera y banner de tonelaje con `Expanded` + `FittedBox`, columna de estadísticas del set con `FittedBox(fit: BoxFit.scaleDown)`.
  - `MuscleDetailSheet`: Cabecera de músculo y nivel, badges de impacto de ejercicio (Wrap), selector de peso y discos (`FittedBox`) y tarjetas de 1RM y PR (`FittedBox`).
  - `ExerciseLibraryScreen`: Badges de músculo primario y secundario con `Expanded(child: Wrap(...))` y título con `FittedBox`.
  - `AchievementsScreen`: Título con `FittedBox` y par título/badge de logro con `Wrap`.
  - `SettingsScreen`: Título con `FittedBox` y fila de selector de descanso con `Expanded`.
  - `SystemBootScreen`: Título y subtítulo envueltos en `FittedBox(fit: BoxFit.scaleDown)`.

### 20. Pruebas y Adaptación Responsive para Pantallas Medianas y Grandes (37/37 Tests)
- **Auditoría de Pantallas Medianas (Tablets / iPad: 768x1024)**:
  - Pruebas dedicadas para `HomeScreen`, `MuscleDetailSheet`, `RankDungeonSheet` y `PlateCalculatorSheet` a 768x1024.
  - Verificación de ausencia total de desbordamientos y proporciones anatómicas correctas.
- **Auditoría de Pantallas Grandes (iPad Pro / Desktop: 1024x1366 / 1280x800)**:
  - Pruebas dedicadas para `HomeScreen`, `WorkoutHistorySheet`, `ExerciseLibraryScreen` y `HunterStatsSheet` a 1024x1366.
- **Centrado y Acotación Táctica (Terminal HUD Centering)**:
  - `HomeScreen._buildMainBodyTab`: Acotado a un ancho máximo de `850px` con `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 850), ...))` para evitar estiramiento desproporcionado de las siluetas frontal/dorsal en pantallas anchas.
  - Modales inferiores (`MuscleDetailSheet`, `DailyQuestSheet`, `HunterStatsSheet`, `RankDungeonSheet`, `WorkoutHistorySheet`, `PlateCalculatorSheet`, `RestTimerSheet`): Acotados con `Align(alignment: Alignment.bottomCenter, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 650), ...))`, renderizándose como terminales holográficos centrados en lugar de ocupar el 100% horizontal de monitores o tablets.
### 21. Transformación a App Oficial: Autenticación Cifrada, Cuenta sajiadmin, Panel Web Localhost y .gitignore Maestro
- **Autenticación y Seguridad Local Cifrada**:
  - Base de datos SQLite migrada a versión 3 en `app/lib/core/database/database_helper.dart` con tablas `users` y `auth_sessions`.
  - Cifrado criptográfico con `crypto: ^3.0.6` mediante `PasswordHasher`: generación de salt aleatorio (`Random.secure()`, 16 bytes / 32 hex) y hash de contraseñas con SHA-256.
  - **Cuenta Predeterminada del Sistema**: Usuario **`sajiadmin`**, contraseña **`sajiadmin`** (almacenada cifrada con salt), con roles combinados de **`admin`** y **`developer`**.
  - **Terminal del Desarrollador (God Mode HUD)**: Modal exclusivo en `app/lib/features/developer/developer_terminal_dialog.dart` accesible únicamente para roles `admin` y `developer`, permitiendo subir niveles instantáneos a los 14 músculos, inyectar +10k XP, forzar penalización de medianoche o añadir tokens de descanso para pruebas de QA inmediatas.
  - Pantalla holográfica `AuthScreen` (`app/lib/features/auth/auth_screen.dart`) con acceso rápido, y enrutamiento condicional en `SystemBootScreen`. Opción de cierre de sesión seguro en `SettingsScreen`.
- **Panel Web de Control en Python (FastAPI en `http://localhost:8000`) & Exportación para APK**:
  - Nueva pestaña "⚙️ Ajustes Globales & APK" en `server/templates/index.html`.
  - Configuración interactiva de:
    - Tiempo de descanso por defecto entre ejercicios (slider de 30 a 300 segundos).
    - Curva de XP por nivel (base de Nivel 6 y porcentaje compuesto recursivo del 15%).
    - Multiplicadores de XP por ejercicio e intervalos de los 8 rangos.
  - Endpoint `POST /api/export_to_apk` que copia atómicamente la configuración activa a `app/assets/config/game_config.json`.
  - Servicio Flutter `GameConfigService` que lee la configuración embebida al inicio de la app, permitiendo que el APK generado (`flutter build apk`) funcione con esos intervalos exactos sin depender de conexión.
- **Preparación para GitHub y `.gitignore` Maestro**:
  - Creación de `.gitignore` en la raíz del repositorio filtrando `.DS_Store`, cachés de Python (`__pycache__`, `.pytest_cache`), artefactos de Flutter/Dart (`.dart_tool`, `build`, `.packages`), y compilados nativos de Android, iOS y macOS.
### 22. Panel de Ejercicios en Python, 3 Pestañas en Flutter, Perfil (1-100 Azul/Oro), Pirámide y Rutinas Guiadas
- **Gestión Avanzada de Ejercicios en Servidor Python (`server/`)**:
  - Modal `#exercise-modal` en la interfaz web de `localhost:8000`.
  - Campos: Nombre, Descripción, Tips técnicos, Foto (`image_url`), GIF demostrativo (`gif_url`) y Enlace a video de YouTube (`youtube_url`, no .mp4).
  - Reparto de XP a hasta 4 músculos anatómicos simultáneos (`muscles_xp`) seleccionables de la lista de los 14 músculos oficiales con su XP por kg respectivo.
  - Validación con 10/10 pruebas en `pytest`.
- **Estructura de Navegación de 3 Pestañas en Flutter (`HomeScreen`)**:
  - **Pestaña Izquierda (Índice 0)**: Buscador de ejercicios por nombre en tiempo real, previsualización de multimedia (imagen o GIF), badges con los hasta 4 músculos involucrados, tips de ejecución y botón de acceso a YouTube mediante `url_launcher`.
  - **Pestaña Central (Índice 1 - Por Defecto)**: Pantalla principal con mapa de calor anatómico de los 2 cuerpos (frontal y dorsal) y misiones del día.
  - **Pestaña Derecha (Índice 2)**: Perfil de Cazador y Gestor de Rutinas de Entrenamiento.
- **Perfil de Cazador y Nivel de 1 a 100**:
  - Foto de avatar configurable (URL o selector de iconos), modificación de nombre de cazador y contraseña cifrada con salt SHA-256.
  - Nivel de Cazador unificado de 1 a 100 donde el nivel 100 representa **GOD OF OLIMPUS**.
  - **Regla estricta de color**: mientras el nivel sea menor a 100, tanto el número de nivel como la barra de progreso se renderizan en **azul oscuro (`#0D47A1`)**; al alcanzar el nivel 100, ambos se iluminan en **dorado resplandeciente (`#FFD700`)**.
  - **Botón de Rango y Modal Piramidal (`RankPyramidDialog`)**: Al pulsarlo se abre un modal en forma de pirámide con la jerarquía de los 8 rangos, citas, colores de liga, realce del rango actual del jugador y un botón `'X'` de cierre en la esquina superior derecha.
- **Gestor de Rutinas de Entrenamiento (`Routine` y `RoutineExercise`)**:
  - Almacenamiento persistente en SQLite tabla `routines` (versión 4 de la base de datos).
  - Tarjeta grande `+ Añadir rutina` si no hay rutinas creadas.
  - Modal de creación y edición (`RoutineEditorDialog`): selección de ejercicios, número de series, peso objetivo (kg), repeticiones objetivo y tiempo de descanso (s).
  - Tarjeta de rutina con 3 acciones:
    1. **Eliminar**: Modal de confirmación con letras rojas chillonas grandes (`#FF1744`) con `"Estas seguro de que quieres borrar esta rutina"`, botón `"SÍ"` en verde (`#00E676`) y botón `"NO"` en rojo (`#FF1744`).
    2. **Editar**: Botón en ámbar-naranja (`#FFA000`) para editar todos los parámetros de la rutina.
    3. **Iniciar Rutina**: Sesión interactiva guiada (`RoutineSessionScreen`):
       - Presentación de la serie actual (ej: "SERIE 1 DE 3", "20 kg x 12 reps").
       - Botón "TERMINAR SERIE" que permite ajustar peso y repeticiones reales ejecutadas.
       - Botón `+15s descanso` para ampliar el tiempo de recuperación si es necesario.
       - Botón `"PASAR A LA SIGUIENTE SERIE"` que distribuye los puntos de XP a los músculos involucrados, reproduce el efecto sonoro del Sistema y activa la cuenta atrás del descanso.
- **Suite de Pruebas**: **55/55 tests en Flutter** (unitarios y widgets con responsive) y **10/10 tests en Python**, con 0 errores y 0 warnings en `flutter analyze`.

### 23. Nuevos Intervalos de Rangos Oficiales, Pruebas Físicas (Niveles 4, 14, 29, 49, 64, 79, 98), Curva x20 XP para Nivel 100 y Mecánica Drop Set
- Intervalos oficiales actualizados de los 8 rangos:
  - `skinnybitch`: Niveles 0 a 4 (prueba física en Nivel 4 para subir al 5).
  - `human`: Niveles 5 a 14 (prueba física en Nivel 14 para subir al 15).
  - `normal_gym_buddy`: Niveles 15 a 29 (prueba física en Nivel 29 para subir al 30).
  - `gymbro`: Niveles 30 a 49 (prueba física en Nivel 49 para subir al 50).
  - `soldier`: Niveles 50 a 64 (prueba física en Nivel 64 para subir al 65).
  - `spartan`: Niveles 65 a 79 (prueba física en Nivel 79 para subir al 80).
  - `hercules`: Niveles 80 a 98 (prueba física en Nivel 98 para subir al 99).
  - `god_of_olimpus`: Niveles 99 a 100.
- Requisito de XP de Nivel 99 a 100: Exactamente 20 veces superior al incremento del nivel 98 al 99 ($XP_{99 \to 100} = XP_{98 \to 99} \times 20.0$).
- Mecánica Drop Set en Backend y Frontend con multiplicadores de $1\times$ (0 saltos), $2\times$ (1 salto), $3\times$ (2 saltos) y hasta $4\times$ (3 o más saltos).

### 24. Versión 0.1.1: Prueba Suprema de Ascensión en Nivel 100, Identificador Único UID de 15 Caracteres, Panel de Récords Personales (PR) y Privilegios Developer
- **Regla del Nivel 100 y Prueba Suprema de Ascensión**:
  - Al alcanzar el Nivel 100, el nivel se renderiza en **Azul Imperial** (`#0D47A1` / `#64B5F6`) y el rango oficial del cazador permanece en **HERCULES**.
  - Se activa la **Prueba Suprema de Ascensión del Olimpo** (`isAtTrialLevel == true`), visualizada en un banner táctico en el Perfil y en `RankDungeonSheet`.
  - Solo tras completar con éxito esta prueba física / mazmorra suprema (`completeSupremeAscensionTrial()`), el cazador asciende oficialmente a **GOD OF OLIMPUS**, desbloqueando el aura dorada resplandeciente (`#FFD700`) en su barra de progreso y nivel de perfil.
- **UID Alfanumérico Único de 15 Caracteres (Multijugador Online Futuro)**:
  - Migración a SQLite v5 añadiendo la columna `uid TEXT UNIQUE` a la tabla `users`.
  - Generación automática de identificadores aleatorios de 15 caracteres (`[0-9a-zA-Z]`) mediante `PasswordHasher.generateUid(15)`.
  - La cuenta de administrador predeterminada `sajiadmin` tiene como identificador fijo maestro: **`000000000000001`** (14 ceros + '1').
  - Visualización en pastilla táctica debajo de `@username // ROL` en la pestaña de Perfil, con copiado interactivo al portapapeles mediante un toque.
- **Panel de Récords Personales (PR)**:
  - Carrusel horizontal en la pestaña de Perfil que muestra los mejores levantamientos históricos en kg para cada ejercicio registrado.
  - Botón `"MODIFICAR PRs"` visible para cuentas `admin` y `developer`.
- **Privilegios de Cuenta Developer (God Mode)**:
  - Selector en la Terminal de Desarrollador para forzar el rango del jugador a cualquiera de los 8 rangos existentes (`devSetRank(rankId)`).
  - Editor interactivo para modificar o fijar los récords personales (PR) de cualquier ejercicio en la base de datos (`devSetPersonalRecord(exerciseId, weightKg)`).

---

## 8. Política de Versiones
- Versión actual: **v0.1.1**.
- El usuario decide expresamente cuándo realizar incrementos semver (`PATCH`, `MINOR`, `MAJOR`).
