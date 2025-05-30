import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String? _countryCode;
  String? _countryName;
  
  String? get countryCode => _countryCode;
  String? get countryName => _countryName;
  // Get user's country based on GPS location (with IP fallback)
  Future<Map<String, String?>> getUserLocation() async {
    try {
      // First check if we have cached location data
      final prefs = await SharedPreferences.getInstance();
      final cachedCountryCode = prefs.getString('user_country_code');
      final cachedCountryName = prefs.getString('user_country_name');
      final lastUpdate = prefs.getInt('location_last_update') ?? 0;
      
      // Cache for 24 hours (86400000 milliseconds)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (cachedCountryCode != null && 
          cachedCountryName != null && 
          (now - lastUpdate) < 86400000) {
        _countryCode = cachedCountryCode;
        _countryName = cachedCountryName;
        print('Using cached location: $_countryName ($_countryCode)');
        return {
          'countryCode': _countryCode,
          'countryName': _countryName,
        };
      }

      // Try GPS-based location first
      Map<String, String?>? gpsLocation = await _getLocationFromGPS();
      if (gpsLocation != null) {
        _countryCode = gpsLocation['countryCode'];
        _countryName = gpsLocation['countryName'];
        
        // Cache the result
        await prefs.setString('user_country_code', _countryCode ?? '');
        await prefs.setString('user_country_name', _countryName ?? '');
        await prefs.setInt('location_last_update', now);
        
        print('GPS location detected: $_countryName ($_countryCode)');
        return gpsLocation;
      }

      // Fallback to IP-based location
      Map<String, String?>? ipLocation = await _getLocationFromIP();
      if (ipLocation != null) {
        _countryCode = ipLocation['countryCode'];
        _countryName = ipLocation['countryName'];
        
        // Cache the result
        await prefs.setString('user_country_code', _countryCode ?? '');
        await prefs.setString('user_country_name', _countryName ?? '');
        await prefs.setInt('location_last_update', now);
        
        print('IP location detected: $_countryName ($_countryCode)');
        return ipLocation;
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
    
    // Ultimate fallback to default values
    _countryCode = 'us'; // Default to US
    _countryName = 'United States';
    print('Using fallback location: $_countryName ($_countryCode)');
    
    return {
      'countryCode': _countryCode,
      'countryName': _countryName,
    };
  }

  // Initialize location service (call this on app start)
  Future<void> initialize() async {
    await getUserLocation();
  }

  // Get country flag emoji
  String getCountryFlag(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) {
      return '🌍'; // Default world emoji
    }
    
    // Convert country code to flag emoji
    final flag = countryCode.toUpperCase().split('').map((char) {
      return String.fromCharCode(0x1F1E6 + char.codeUnitAt(0) - 0x41);
    }).join('');
    
    return flag;  }

  // Get location using GPS coordinates and reverse geocoding
  Future<Map<String, String?>?> _getLocationFromGPS() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      print('GPS coordinates: ${position.latitude}, ${position.longitude}');

      // Use reverse geocoding to get country information
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String? countryCode = place.isoCountryCode?.toLowerCase();
        String? countryName = place.country;

        if (countryCode != null && countryName != null) {
          print('GPS reverse geocoding: $countryName ($countryCode)');
          return {
            'countryCode': countryCode,
            'countryName': countryName,
          };
        }
      }

      print('No country information found from GPS coordinates');
      return null;
    } catch (e) {
      print('Error getting GPS location: $e');
      return null;
    }
  }

  // Get location using IP-based service
  Future<Map<String, String?>?> _getLocationFromIP() async {
    try {
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/?fields=status,message,country,countryCode'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          String? countryCode = data['countryCode']?.toString().toLowerCase();
          String? countryName = data['country']?.toString();
          
          if (countryCode != null && countryName != null) {
            print('IP-based location: $countryName ($countryCode)');
            return {
              'countryCode': countryCode,
              'countryName': countryName,
            };
          }
        } else {
          print('IP location API error: ${data['message']}');
        }
      } else {
        print('IP location API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting IP location: $e');
    }
    
    return null;
  }

  // Clear cached location (for testing or manual refresh)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_country_code');
    await prefs.remove('user_country_name');
    await prefs.remove('location_last_update');
    _countryCode = null;
    _countryName = null;
    print('Location cache cleared');
  }
  // Force refresh location (clears cache and fetches fresh data)
  Future<Map<String, String?>> forceRefreshLocation() async {
    print('Force refreshing location...');
    await clearCache();
    
    // Force GPS detection without fallback to cache
    Map<String, String?>? gpsLocation = await _getLocationFromGPS();
    if (gpsLocation != null) {
      _countryCode = gpsLocation['countryCode'];
      _countryName = gpsLocation['countryName'];
      
      // Cache the fresh GPS result
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('user_country_code', _countryCode ?? '');
      await prefs.setString('user_country_name', _countryName ?? '');
      await prefs.setInt('location_last_update', now);
      
      print('Fresh GPS location detected: $_countryName ($_countryCode)');
      return gpsLocation;
    }
    
    // If GPS fails, try IP as fallback
    Map<String, String?>? ipLocation = await _getLocationFromIP();
    if (ipLocation != null) {
      _countryCode = ipLocation['countryCode'];
      _countryName = ipLocation['countryName'];
      
      // Cache the IP result
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('user_country_code', _countryCode ?? '');
      await prefs.setString('user_country_name', _countryName ?? '');
      await prefs.setInt('location_last_update', now);
      
      print('IP location detected as fallback: $_countryName ($_countryCode)');
      return ipLocation;
    }
    
    // If all fails, use default but don't cache it
    print('Both GPS and IP failed, using default location');
    return {
      'countryCode': 'us',
      'countryName': 'United States',
    };
  }
  // Debug method to test location detection
  Future<void> debugLocationDetection() async {
    print('=== DEBUG: Testing Location Detection ===');
    
    // Clear cache first
    await clearCache();
    print('Cache cleared');
    
    // Test GPS location detection
    print('\n--- Testing GPS Location ---');
    Map<String, String?>? gpsResult = await _getLocationFromGPS();
    if (gpsResult != null) {
      print('GPS Success: ${gpsResult['countryName']} (${gpsResult['countryCode']})');
      print('GPS Flag: ${getCountryFlag(gpsResult['countryCode'])}');
    } else {
      print('GPS Failed or not available');
    }
    
    // Test IP location detection
    print('\n--- Testing IP Location ---');
    Map<String, String?>? ipResult = await _getLocationFromIP();
    if (ipResult != null) {
      print('IP Success: ${ipResult['countryName']} (${ipResult['countryCode']})');
      print('IP Flag: ${getCountryFlag(ipResult['countryCode'])}');
    } else {
      print('IP Failed or not available');
    }
    
    // Test the main method
    print('\n--- Testing Main getUserLocation() Method ---');
    final location = await getUserLocation();
    print('Final result: $location');
    print('Country flag: ${getCountryFlag(location['countryCode'])}');
    print('=== END DEBUG ===');
  }
}
