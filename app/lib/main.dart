import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/system_theme.dart';
import 'core/config/game_config_service.dart';
import 'providers/game_provider.dart';
import 'features/splash/system_boot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameConfigService.instance.loadBundledConfig();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const OlimpiaLevelingApp());
}

class OlimpiaLevelingApp extends StatelessWidget {
  const OlimpiaLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Olimpia Leveling',
        debugShowCheckedModeBanner: false,
        theme: SystemTheme.themeData,
        home: const SystemBootScreen(),
      ),
    );
  }
}
