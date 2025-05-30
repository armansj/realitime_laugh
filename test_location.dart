import 'package:flutter/material.dart';
import 'lib/models/location_service.dart';

void main() {
  runApp(const LocationTestApp());
}

class LocationTestApp extends StatelessWidget {
  const LocationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Service Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationTestScreen(),
    );
  }
}

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final LocationService _locationService = LocationService();
  String _output = 'Tap the button to test location detection...';
  bool _isLoading = false;

  Future<void> _testLocationDetection() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing location detection...\n\n';
    });

    try {
      // Test the debug method which tests both GPS and IP
      await _locationService.debugLocationDetection();
      
      // Get the final result
      final location = await _locationService.getUserLocation();
      
      setState(() {
        _output += '\n=== FINAL RESULT ===\n';
        _output += 'Country: ${location['countryName']}\n';
        _output += 'Country Code: ${location['countryCode']}\n';
        _output += 'Flag: ${_locationService.getCountryFlag(location['countryCode'])}\n';
        _output += '\nLocation detection completed successfully!';
      });
    } catch (e) {
      setState(() {
        _output += '\nError: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Service Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testLocationDetection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Testing...'),
                      ],
                    )
                  : const Text(
                      'Test Location Detection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
