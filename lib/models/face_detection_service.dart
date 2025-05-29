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
  }
  Future<FaceAnalysisResult> analyzeFace(CameraImage image) async {
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
      );      final faces = await _faceDetector.processImage(inputImage);
      final faceMeshes = await _faceMeshDetector.processImage(inputImage);
      
      if (faces.isNotEmpty && faceMeshes.isNotEmpty) {
        final face = faces.first;
        final mesh = faceMeshes.first;

        return _analyzeFaceFeatures(face, mesh);
      }

      // Return empty result when no face detected - like your working code
      return FaceAnalysisResult.empty();    } catch (e) {
      // Silent error handling
      return FaceAnalysisResult.empty();
    } finally {
      isDetecting = false;
    }
  }  FaceAnalysisResult _analyzeFaceFeatures(Face face, FaceMesh mesh) {
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
    }

    return FaceAnalysisResult(
      smileProb: smileProb,
      mouthOpen: mouthOpen,
      cheekRaised: cheekRaised,
      eyeWrinkleDetected: eyeWrinkleDetected,
    );
  }

  void dispose() {
    _faceDetector.close();
    _faceMeshDetector.close();
  }
}

class FaceAnalysisResult {
  final double smileProb;
  final double mouthOpen;
  final bool cheekRaised;
  final bool eyeWrinkleDetected;

  FaceAnalysisResult({
    required this.smileProb,
    required this.mouthOpen,
    required this.cheekRaised,
    required this.eyeWrinkleDetected,
  });

  factory FaceAnalysisResult.empty() {
    return FaceAnalysisResult(
      smileProb: 0.0,
      mouthOpen: 0.0,
      cheekRaised: false,
      eyeWrinkleDetected: false,
    );
  }

  bool get isEmpty => smileProb == 0.0 && mouthOpen == 0.0;
}
