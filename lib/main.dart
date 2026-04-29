import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/modpack_service.dart';
import 'widgets/animated_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system UI
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      navigationBarColor: Colors.transparent,
      navigationBarIconBrightness: Brightness.light,
      navigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ModpackService(prefs)),
      ],
      child: const ModpackMcbeApp(),
    ),
  );
}

class ModpackMcbeApp extends StatefulWidget {
  const ModpackMcbeApp({super.key});

  @override
  State<ModpackMcbeApp> createState() => _ModpackMcbeAppState();
}

class _ModpackMcbeAppState extends State<ModpackMcbeApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss splash after a minimum display time
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && _showSplash) {
        setState(() => _showSplash = false);
      }
    });
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplash(onComplete: _onSplashComplete),
      );
    }

    return const MainApp();
  }
}
