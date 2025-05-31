import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'screens/auth_wrapper.dart';
import 'firebase_options.dart';
import 'services/language_service.dart';
import 'services/audio_service.dart';
import 'l10n/app_localizations.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize cameras
  cameras = await availableCameras();
  
  // Initialize audio service
  await AudioService.instance.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    // Dispose audio service
    AudioService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is going to background or being closed
        AudioService.instance.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        if (AudioService.instance.isBackgroundMusicEnabled) {
          AudioService.instance.resumeBackgroundMusic();
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive (like when receiving a phone call)
        AudioService.instance.pauseBackgroundMusic();
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        AudioService.instance.pauseBackgroundMusic();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {        return MaterialApp(
          title: 'Laugh Detector',
          theme: AppTheme.lightTheme,
          locale: languageService.locale,          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          home: AuthWrapper(),
        );
      },
    );
  }
}
