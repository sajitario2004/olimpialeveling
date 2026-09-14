import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:olimpia_leveling/models/muscle.dart';
import 'package:olimpia_leveling/models/player.dart';
import 'package:olimpia_leveling/models/daily_quest.dart';
import 'package:olimpia_leveling/models/rank.dart';
import 'package:olimpia_leveling/features/body_map/widgets/anatomical_body_view.dart';
import 'package:olimpia_leveling/features/level_up/level_up_dialog.dart';
import 'package:olimpia_leveling/features/calculator/widgets/plate_calculator_sheet.dart';
import 'package:olimpia_leveling/features/timer/widgets/rest_timer_sheet.dart';
import 'package:olimpia_leveling/features/dungeons/rank_dungeon_sheet.dart';
import 'package:olimpia_leveling/features/quests/daily_quest_sheet.dart';
import 'package:olimpia_leveling/features/stats/hunter_stats_sheet.dart';
import 'package:olimpia_leveling/features/history/workout_history_sheet.dart';
import 'package:olimpia_leveling/features/exercises/exercise_library_screen.dart';
import 'package:olimpia_leveling/features/achievements/achievements_screen.dart';
import 'package:olimpia_leveling/features/settings/settings_screen.dart';
import 'package:olimpia_leveling/features/body_map/widgets/muscle_detail_sheet.dart';
import 'package:olimpia_leveling/features/splash/system_boot_screen.dart';
import 'package:olimpia_leveling/features/home/home_screen.dart';
import 'package:olimpia_leveling/features/profile/hunter_profile_screen.dart';
import 'package:olimpia_leveling/features/profile/widgets/rank_pyramid_dialog.dart';
import 'package:olimpia_leveling/features/routines/routine_session_screen.dart';
import 'package:olimpia_leveling/models/routine.dart';
import 'package:olimpia_leveling/models/exercise.dart';
import 'package:olimpia_leveling/providers/game_provider.dart';

void main() {
  testWidgets('AnatomicalBodyView renderiza los dos cuerpos frontal y dorsal', (WidgetTester tester) async {
    final testMuscles = [
      Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 1),
      Muscle(id: 'triceps', name: 'Tríceps', category: 'back', level: 1),
      Muscle(id: 'deltoides', name: 'Deltoides', category: 'both', level: 5),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnatomicalBodyView(
            muscles: testMuscles,
            onMuscleSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('MAPA MUSCULAR DEL SISTEMA'), findsOneWidget);
    expect(find.text('VISTA FRONTAL'), findsOneWidget);
    expect(find.text('VISTA DORSAL'), findsOneWidget);
  });

  testWidgets('LevelUpDialog muestra la alerta del sistema y subida de nivel', (WidgetTester tester) async {
    final event = LevelUpEvent(
      muscleName: 'Deltoides',
      muscleLevel: 6,
      totalLevel: 25,
      rank: RankTier.allRanks[1], // Human
      pointsAwarded: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelUpDialog(
            event: event,
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('[NOTIFICACIÓN DEL SISTEMA]'), findsOneWidget);
    expect(find.text('¡HAS SUBIDO DE NIVEL!'), findsOneWidget);
    expect(find.text('DELTOIDES ➔ NIVEL 6'), findsOneWidget);
    expect(find.text('+3 PUNTOS DE ATRIBUTO DISPONIBLES'), findsOneWidget);
  });

  testWidgets('Diseño responsive: AnatomicalBodyView no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testMuscles = [
      Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 1),
      Muscle(id: 'triceps', name: 'Tríceps', category: 'back', level: 1),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnatomicalBodyView(
            muscles: testMuscles,
            onMuscleSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('MAPA MUSCULAR DEL SISTEMA'), findsOneWidget);
    expect(tester.takeException(), isNull); // Ensures NO overflow exception
  });

  testWidgets('PlateCalculatorSheet calcula discos y responde sin overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlateCalculatorSheet(initialWeight: 100.0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONFIGURADOR DE BARRA'), findsOneWidget);
    expect(find.text('100.0 KG'), findsOneWidget);
    expect(find.text('(40.0 kg a cada lado de la barra)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RestTimerSheet cuenta regresiva e interacción de sumar tiempo (+30s)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestTimerSheet(
            initialSeconds: 60,
            exerciseName: 'Press de Banca',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('PRESS DE BANCA'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);

    // Tap '+30s'
    final plus30Finder = find.text('+30s');
    expect(plus30Finder, findsOneWidget);
    await tester.tap(plus30Finder);
    await tester.pump();

    expect(find.text('01:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: RankDungeonSheet no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 30, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 5),
        Muscle(id: 'dorsales', name: 'Dorsales', category: 'back', level: 1),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: RankDungeonSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRUEBA DE ASCENSO DE RANGO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: DailyQuestSheet con bonus de racha no genera overflow (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(streakDays: 30, lastActiveDate: '2026-09-14'),
      dailyQuests: [
        DailyQuest(id: 'q1', name: '100 Flexiones', target: 100, unit: 'reps', isSelected: true, date: '2026-09-14'),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: DailyQuestSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ELIGE TU PRUEBA HEROICA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: HunterStatsSheet no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 55, strength: 20, agility: 15, endurance: 18, discipline: 14, lastActiveDate: '2026-09-14'),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HunterStatsSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CAZADOR DEL OLIMPO'), findsOneWidget);
    expect(find.text('PODER DE COMBATE (CP)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: WorkoutHistorySheet no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      todayVolume: 2500.0,
      workoutLogs: [
        {
          'exercise_name': 'Press de Banca Plano',
          'muscle_name': 'Pecho',
          'weight': 100.0,
          'reps': 10,
          'xp_awarded': 350.0,
          'timestamp': '2026-09-14T18:00:00',
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkoutHistorySheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HISTORIAL DE SERIES'), findsOneWidget);
    expect(find.text('2500 KG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: ExerciseLibraryScreen no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      exercises: [
        Exercise(
          id: 'press_banca',
          name: 'Press de Banca Plano',
          primaryMuscle: 'pecho',
          secondaryMuscle: 'triceps',
          primaryXpPerKg: 1.0,
          secondaryXpPerKg: 0.5,
          description: 'Ejercicio básico de empuje para desarrollar la masa del pectoral.',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: ExerciseLibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BIBLIOTECA DE EJERCICIOS'), findsOneWidget);
    expect(find.text('Press de Banca Plano'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: AchievementsScreen no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(
        totalLevel: 300,
        streakDays: 35,
        equippedTitle: 'Hércules',
        lastActiveDate: '2026-09-14',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: AchievementsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TÍTULOS Y LOGROS DEL OLIMPO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: SettingsScreen no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AJUSTES DEL SISTEMA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: MuscleDetailSheet no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testMuscle = Muscle(
      id: 'isquiotibiales',
      name: 'Isquiotibiales',
      category: 'back',
      level: 15,
      currentXp: 350.0,
    );

    final testGame = GameProvider();
    testGame.loadTestData(
      muscles: [testMuscle],
      exercises: [
        Exercise(
          id: 'peso_muerto_rumano',
          name: 'Peso Muerto Rumano',
          primaryMuscle: 'isquiotibiales',
          secondaryMuscle: 'gluteos',
          primaryXpPerKg: 1.2,
          secondaryXpPerKg: 0.8,
          description: 'Enfoque excéntrico para la cadena posterior.',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: MaterialApp(
          home: Scaffold(
            body: MuscleDetailSheet(muscle: testMuscle),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ISQUIOTIBIALES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: SystemBootScreen no genera overflow en pantalla pequeña (320x568)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: SystemBootScreen(),
        ),
      ),
    );
    // Pump frames for animation
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('OLIMPIA LEVELING'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ==================== PANTALLAS MEDIANAS (TABLETS / IPAD: 768x1024) ====================

  testWidgets('Diseño responsive: HomeScreen en pantalla mediana (768x1024) sin overflow ni distorsión', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 60, streakDays: 14, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 10),
        Muscle(id: 'dorsales', name: 'Dorsales', category: 'back', level: 12),
      ],
      dailyQuests: [
        DailyQuest(
          id: 'quest_1',
          name: '100 FLEXIONES',
          target: 100,
          current: 50,
          unit: 'reps',
          isSelected: true,
          date: '2026-09-14',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MAPA MUSCULAR DEL SISTEMA'), findsOneWidget);
    expect(find.text('VISTA FRONTAL'), findsOneWidget);
    expect(find.text('VISTA DORSAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: MuscleDetailSheet en pantalla mediana (768x1024)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testMuscle = Muscle(
      id: 'pecho',
      name: 'Pecho',
      category: 'front',
      level: 25,
      currentXp: 800.0,
    );

    final testGame = GameProvider();
    testGame.loadTestData(
      muscles: [testMuscle],
      exercises: [
        Exercise(
          id: 'press_banca',
          name: 'Press de Banca Plano',
          primaryMuscle: 'pecho',
          secondaryMuscle: 'triceps',
          primaryXpPerKg: 1.0,
          secondaryXpPerKg: 0.5,
          description: 'Ejercicio de empuje horizontal.',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MuscleDetailSheet(muscle: testMuscle),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 15));

    expect(find.text('PECHO'), findsOneWidget);
    expect(find.text('1RM ESTIMADO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: RankDungeonSheet en pantalla mediana (768x1024)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 75, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 15),
        Muscle(id: 'dorsales', name: 'Dorsales', category: 'back', level: 12),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: RankDungeonSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRUEBA DE ASCENSO DE RANGO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: PlateCalculatorSheet en pantalla mediana (768x1024)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlateCalculatorSheet(initialWeight: 140.0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONFIGURADOR DE BARRA'), findsOneWidget);
    expect(find.text('140.0 KG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ==================== PANTALLAS GRANDES (IPAD PRO / DESKTOP: 1024x1366 / 1280x800) ====================

  testWidgets('Diseño responsive: HomeScreen en pantalla grande (1024x1366) sin overflow ni distorsión', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 160, streakDays: 45, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 30),
        Muscle(id: 'deltoides', name: 'Deltoides', category: 'both', level: 28),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MAPA MUSCULAR DEL SISTEMA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: WorkoutHistorySheet en pantalla grande (1024x1366)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      todayVolume: 8500.0,
      workoutLogs: [
        {
          'exercise_name': 'Sentadilla Trasera',
          'muscle_name': 'Cuádriceps',
          'weight': 140.0,
          'reps': 8,
          'xp_awarded': 650.0,
          'timestamp': '2026-09-14T19:00:00',
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkoutHistorySheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HISTORIAL DE SERIES'), findsOneWidget);
    expect(find.text('8500 KG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: ExerciseLibraryScreen en pantalla grande (1024x1366)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      exercises: [
        Exercise(
          id: 'peso_muerto',
          name: 'Peso Muerto Convencional',
          primaryMuscle: 'lumbar',
          secondaryMuscle: 'gluteos',
          primaryXpPerKg: 1.2,
          secondaryXpPerKg: 0.6,
          description: 'Levantamiento de potencia total.',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: ExerciseLibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BIBLIOTECA DE EJERCICIOS'), findsOneWidget);
    expect(find.text('Peso Muerto Convencional'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Diseño responsive: HunterStatsSheet en pantalla grande (1024x1366)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(
        totalLevel: 250,
        streakDays: 60,
        strength: 80,
        agility: 50,
        endurance: 70,
        discipline: 90,
        lastActiveDate: '2026-09-14',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HunterStatsSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CAZADOR DEL OLIMPO'), findsOneWidget);
    expect(find.text('PODER DE COMBATE (CP)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Barra de navegación con 3 pestañas: Ejercicios, Cuerpo (default) y Perfil', (WidgetTester tester) async {
    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 30, streakDays: 5, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 2),
        Muscle(id: 'deltoides', name: 'Deltoides', category: 'both', level: 3),
      ],
      exercises: [
        Exercise(
          id: 'press_banca',
          name: 'Press de Banca',
          description: 'Pectoral mayor',
          primaryMuscle: 'pecho',
          primaryXpPerKg: 5.0,
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 3 pestañas en la barra de navegación
    expect(find.text('Ejercicios'), findsOneWidget);
    expect(find.text('Cuerpo'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Inicia en la pestaña de en medio (Cuerpo / Mapa Muscular)
    expect(find.text('MAPA MUSCULAR DEL SISTEMA'), findsOneWidget);

    // Cambiar a la pestaña de la izquierda: Ejercicios
    await tester.tap(find.text('Ejercicios'));
    await tester.pumpAndSettle();
    expect(find.text('BIBLIOTECA DE EJERCICIOS'), findsOneWidget);

    // Cambiar a la pestaña de la derecha: Perfil
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('NIVEL DEL JUGADOR: '), findsOneWidget);
    expect(find.text('RUTINAS DE ENTRENAMIENTO'), findsOneWidget);
    await tester.pump(const Duration(seconds: 15));
  });

  testWidgets('RankPyramidDialog muestra la jerarquía piramidal de 8 rangos y botón X de cierre', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RankPyramidDialog(
            playerLevel: 55,
            currentRankId: 'soldier',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PIRÁMIDE DEL OLIMPO'), findsOneWidget);
    expect(find.text('GOD OF OLIMPUS'), findsOneWidget);
    expect(find.text('SKINNYBITCH'), findsOneWidget);
    expect(find.text('HERCULES'), findsOneWidget);
    expect(find.text('SPARTAN'), findsOneWidget);
    expect(find.text('SOLDIER'), findsOneWidget);
    expect(find.text('GYMBRO'), findsOneWidget);
    expect(find.text('NORMAL GYM BUDDY'), findsOneWidget);
    expect(find.text('HUMAN'), findsOneWidget);

    // Botón X de cerrar
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('HunterProfileScreen muestra nivel de cazador, rangos, y gestor de rutinas', (WidgetTester tester) async {
    final testGame = GameProvider();
    testGame.loadTestData(
      player: Player(totalLevel: 42, streakDays: 10, lastActiveDate: '2026-09-14'),
      muscles: [
        Muscle(id: 'pecho', name: 'Pecho', category: 'front', level: 3),
      ],
      exercises: [],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: const MaterialApp(
          home: Scaffold(
            body: HunterProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 15));

    expect(find.text('NIVEL DEL JUGADOR: '), findsOneWidget);
    expect(find.text('RUTINAS DE ENTRENAMIENTO'), findsOneWidget);
    expect(find.text('+ Añadir rutina'), findsOneWidget);
    expect(find.text('Toca para ver la Pirámide del Olimpo'), findsOneWidget);
  });

  testWidgets('RoutineSessionScreen guía de entrenamiento interactiva con selector de peso y reps', (WidgetTester tester) async {
    final testGame = GameProvider();
    final routine = Routine(
      id: 'rutina_test',
      userId: 'admin_1',
      name: 'Rutina Test',
      createdAt: '2026-09-14',
      exercises: [
        RoutineExercise(
          exerciseId: 'press_banca',
          exerciseName: 'Press de Banca',
          primaryMuscle: 'pecho',
          sets: 2,
          targetWeightKg: 50.0,
          targetReps: 10,
          restSeconds: 60,
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: testGame,
        child: MaterialApp(
          home: RoutineSessionScreen(routine: routine),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Press de Banca'), findsOneWidget);
    expect(find.text('SERIE 1 DE 2'), findsOneWidget);
    expect(find.text('TERMINAR SERIE'), findsOneWidget);

    // Tocar TERMINAR SERIE para pasar a revisión y descanso
    await tester.tap(find.text('TERMINAR SERIE'));
    await tester.pumpAndSettle();

    expect(find.text('PASAR A LA SIGUIENTE SERIE'), findsOneWidget);
    expect(find.text('+15s descanso'), findsOneWidget);
  });
}
