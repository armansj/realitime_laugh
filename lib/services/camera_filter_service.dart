import 'package:flutter/material.dart';

class CameraFilterService {
  static final CameraFilterService _instance = CameraFilterService._internal();
  factory CameraFilterService() => _instance;
  CameraFilterService._internal();
  // Available filters
  static const Map<String, CameraFilter> availableFilters = {
    'none': CameraFilter(
      id: 'none',
      name: 'No Filter',
      description: 'Original camera view',
      colorMatrix: null,
      isPremium: false,
    ),
    'beauty': CameraFilter(
      id: 'beauty',
      name: 'Beauty Filter',
      description: 'Smooth and enhance features',
      colorMatrix: [
        1.2, 0.0, 0.0, 0.0, 10.0,
        0.0, 1.1, 0.0, 0.0, 5.0,
        0.0, 0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
      isPremium: true,
    ),
    'grayscale': CameraFilter(
      id: 'grayscale',
      name: 'Grayscale',
      description: 'Classic black and white',
      colorMatrix: [
        0.3, 0.6, 0.1, 0.0, 0.0,
        0.3, 0.6, 0.1, 0.0, 0.0,
        0.3, 0.6, 0.1, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
      isPremium: true,
    ),
    'warm': CameraFilter(
      id: 'warm',
      name: 'Warm Tone',
      description: 'Cozy warm colors',
      colorMatrix: [
        1.2, 0.0, 0.0, 0.0, 20.0,
        0.0, 1.0, 0.0, 0.0, 10.0,
        0.0, 0.0, 0.8, 0.0, -10.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
      isPremium: true,
    ),
    'colorful_eyes': CameraFilter(
      id: 'colorful_eyes',
      name: 'Colorful Eyes',
      description: 'Enhanced vibrant eye colors with subtle rainbow effect',
      colorMatrix: [
        1.1, 0.0, 0.1, 0.0, 5.0,   // Red enhancement
        0.0, 1.2, 0.1, 0.0, 8.0,   // Green enhancement  
        0.1, 0.0, 1.3, 0.0, 15.0,  // Blue enhancement
        0.0, 0.0, 0.0, 1.0, 0.0,   // Alpha unchanged
      ],
      isPremium: true,
    ),
    'vintage': CameraFilter(
      id: 'vintage',
      name: 'Vintage',
      description: 'Classic retro film look',
      colorMatrix: [
        1.0, 0.1, 0.0, 0.0, 10.0,
        0.0, 0.9, 0.1, 0.0, 5.0,
        0.0, 0.0, 0.8, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
      isPremium: true,
    ),
    'cool': CameraFilter(
      id: 'cool',
      name: 'Cool Tone',
      description: 'Fresh cool blue tones',
      colorMatrix: [
        0.9, 0.0, 0.0, 0.0, -5.0,
        0.0, 1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.2, 0.0, 15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
      isPremium: true,
    ),
  };

  // Get filter by ID
  CameraFilter? getFilter(String? filterId) {
    if (filterId == null) return availableFilters['none'];
    return availableFilters[filterId];
  }

  // Apply color matrix filter to a widget
  Widget applyFilter(Widget child, String? filterId) {
    final filter = getFilter(filterId);
    if (filter == null || filter.colorMatrix == null) {
      return child;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(filter.colorMatrix!),
      child: child,
    );
  }

  // Get all premium filters for shop
  List<CameraFilter> getPremiumFilters() {
    return availableFilters.values
        .where((filter) => filter.isPremium)
        .toList();
  }
}

class CameraFilter {
  final String id;
  final String name;
  final String description;
  final List<double>? colorMatrix;
  final bool isPremium;

  const CameraFilter({
    required this.id,
    required this.name,
    required this.description,
    this.colorMatrix,
    required this.isPremium,
  });
}
