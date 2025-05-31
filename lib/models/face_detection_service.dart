import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

class FaceDetectionService {
  late FaceDetector _faceDetector;
  late FaceMeshDetector _faceMeshDetector;
  bool isDetecting = false;

  // Anti-spoofing variables
  final List<Map<String, dynamic>> _recentFaceData = [];
  DateTime? _lastBlinkTime;
  double? _lastHeadPoseX;
  double? _lastHeadPoseY;
  int _consecutiveStaticFrames = 0;
  bool _isLivenessConfirmed = false;
  
  static const int MAX_HISTORY_FRAMES = 10;
  static const int MAX_STATIC_FRAMES = 30; // 1 second at 30fps
  static const double MIN_MOVEMENT_THRESHOLD = 2.0;
  static const double BLINK_INTERVAL_SECONDS = 8.0;

  FaceDetectionService() {
    _initializeDetectors();
  }

  void _initializeDetectors() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    _faceMeshDetector = FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh,
    );
  }  Future<FaceAnalysisResult> analyzeFace(CameraImage image) async {
    if (isDetecting) {
      return FaceAnalysisResult.empty();
    }
    
    isDetecting = true;
    
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);
      final faceMeshes = await _faceMeshDetector.processImage(inputImage);
      
      if (faces.isNotEmpty && faceMeshes.isNotEmpty) {
        final face = faces.first;
        final mesh = faceMeshes.first;

        // Perform anti-spoofing checks
        final livenessCheck = _performLivenessCheck(face, mesh);
        final result = _analyzeFaceFeatures(face, mesh);
        
        // Only return valid results if liveness is confirmed
        if (livenessCheck) {
          return result;
        } else {
          // Return degraded result for potential spoofing
          return FaceAnalysisResult(
            smileProb: result.smileProb * 0.3, // Heavily reduce detection confidence
            mouthOpen: result.mouthOpen * 0.3,
            cheekRaised: false, // Disable complex features
            eyeWrinkleDetected: false,
            isLive: false,
          );
        }
      }

      // Reset consecutive static frames when no face is detected
      _consecutiveStaticFrames = 0;
      return FaceAnalysisResult.empty();
    } catch (e) {
      // Silent error handling
      return FaceAnalysisResult.empty();
    } finally {
      isDetecting = false;
    }
  }  bool _performLivenessCheck(Face face, FaceMesh mesh) {
    final now = DateTime.now();
    
    // Check for blink detection
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final averageEyeOpen = (leftEyeOpen + rightEyeOpen) / 2;
    
    // Detect blink (eyes closed)
    if (averageEyeOpen < 0.3) {
      _lastBlinkTime = now;
      _isLivenessConfirmed = true;
    }
    
    // Check head pose movement
    final headEulerY = face.headEulerAngleY ?? 0.0;
    final headEulerX = face.headEulerAngleX ?? 0.0;
    
    bool hasHeadMovement = false;
    if (_lastHeadPoseX != null && _lastHeadPoseY != null) {
      final xDiff = (headEulerX - _lastHeadPoseX!).abs();
      final yDiff = (headEulerY - _lastHeadPoseY!).abs();
      
      if (xDiff > MIN_MOVEMENT_THRESHOLD || yDiff > MIN_MOVEMENT_THRESHOLD) {
        hasHeadMovement = true;
        _consecutiveStaticFrames = 0;
        _isLivenessConfirmed = true;
      } else {
        _consecutiveStaticFrames++;
      }
    }
    
    _lastHeadPoseX = headEulerX;
    _lastHeadPoseY = headEulerY;
    
    // Store current frame data for movement analysis
    final currentFrameData = {
      'timestamp': now.millisecondsSinceEpoch,
      'headX': headEulerX,
      'headY': headEulerY,
      'eyeOpen': averageEyeOpen,
    };
    
    _recentFaceData.add(currentFrameData);
    if (_recentFaceData.length > MAX_HISTORY_FRAMES) {
      _recentFaceData.removeAt(0);
    }
    
    // Check for recent blink (within last 8 seconds)
    final timeSinceLastBlink = _lastBlinkTime != null 
        ? now.difference(_lastBlinkTime!).inSeconds 
        : double.infinity;
    
    // Fail liveness check if:
    // 1. Too many consecutive static frames (likely a photo)
    // 2. No blink detected in a reasonable time AND no head movement
    if (_consecutiveStaticFrames > MAX_STATIC_FRAMES) {
      _isLivenessConfirmed = false;
      return false;
    }
    
    if (timeSinceLastBlink > BLINK_INTERVAL_SECONDS && !hasHeadMovement && _consecutiveStaticFrames > 15) {
      return false;
    }
    
    return _isLivenessConfirmed;
  }

  FaceAnalysisResult _analyzeFaceFeatures(Face face, FaceMesh mesh) {
    final smileProb = face.smilingProbability ?? 0.0;

    // Use the working mouth opening calculation from your code
    final upperLip = mesh.contours[FaceMeshContourType.upperLipTop];
    final lowerLip = mesh.contours[FaceMeshContourType.lowerLipBottom];

    double mouthOpen = 0.0;
    if (upperLip != null && lowerLip != null && upperLip.length > 5 && lowerLip.length > 5) {
      mouthOpen = (lowerLip[5].y - upperLip[5].y).abs();
    }

    // Use the working cheek and eye detection from your code
    bool cheekRaised = false;
    bool eyeWrinkleDetected = false;

    try {
      final leftEyeOuter = mesh.points[130];
      final leftCheek = mesh.points[243];
      final underEye = mesh.points[113];

      final eyeToCheek = (leftEyeOuter.y - leftCheek.y).abs();
      final eyeToUnderEye = (leftEyeOuter.y - underEye.y).abs();

      if (eyeToCheek < 15) cheekRaised = true;
      if (eyeToUnderEye < 10) eyeWrinkleDetected = true;
    } catch (_) {
      // Silent error handling
    }    return FaceAnalysisResult(
      smileProb: smileProb,
      mouthOpen: mouthOpen,
      cheekRaised: cheekRaised,
      eyeWrinkleDetected: eyeWrinkleDetected,
      isLive: true, // Assume live when we reach normal analysis
    );
  }
  void dispose() {
    _faceDetector.close();
    _faceMeshDetector.close();
  }

  void resetAntiSpoofing() {
    _recentFaceData.clear();
    _lastBlinkTime = null;
    _lastHeadPoseX = null;
    _lastHeadPoseY = null;
    _consecutiveStaticFrames = 0;
    _isLivenessConfirmed = false;
  }

  bool get isLivenessConfirmed => _isLivenessConfirmed;
  int get consecutiveStaticFrames => _consecutiveStaticFrames;
}

class FaceAnalysisResult {
  final double smileProb;
  final double mouthOpen;
  final bool cheekRaised;
  final bool eyeWrinkleDetected;
  final bool isLive;

  FaceAnalysisResult({
    required this.smileProb,
    required this.mouthOpen,
    required this.cheekRaised,
    required this.eyeWrinkleDetected,
    required this.isLive,
  });

  factory FaceAnalysisResult.empty() {
    return FaceAnalysisResult(
      smileProb: 0.0,
      mouthOpen: 0.0,
      cheekRaised: false,
      eyeWrinkleDetected: false,
      isLive: false,
    );
  }

  bool get isEmpty => smileProb == 0.0 && mouthOpen == 0.0;
}
