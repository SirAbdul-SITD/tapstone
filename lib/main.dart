import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/palette.dart';
import 'services/puzzle_repository.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';
import 'services/audio_manager.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TapstoneApp());
}

class TapstoneApp extends StatefulWidget {
  const TapstoneApp({super.key});

  @override
  State<TapstoneApp> createState() => _TapstoneAppState();
}

class _TapstoneAppState extends State<TapstoneApp> {
  final repo = PuzzleRepository();
  final progress = ProgressService();
  final settings = SettingsService();
  late final AudioManager audio;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    audio = AudioManager(settings);
    _boot();
  }

  Future<void> _boot() async {
    await Future.wait([repo.load(), progress.init(), settings.init()]);
    if (settings.sound) audio.startMusic();
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: MaterialApp(
        title: 'Tapstone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Palette.slate,
          colorScheme: const ColorScheme.dark(
            primary: Palette.cyan,
            surface: Palette.panel,
          ),
        ),
        home: _ready
            ? HomeScreen(repo: repo, audio: audio)
            : const _SplashScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Palette.slate,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_4x4, color: Palette.cyan, size: 56),
            SizedBox(height: 16),
            Text('TAPSTONE',
                style: TextStyle(
                    color: Palette.chalk,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
