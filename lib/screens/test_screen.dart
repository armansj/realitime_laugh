import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("TestScreen building...");
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade300,
        title: const Text('Test Screen'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_very_satisfied,
              size: 100,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            Text(
              'Test Screen Loaded Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'If you can see this, navigation is working.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
