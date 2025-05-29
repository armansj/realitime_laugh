import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Detector',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
