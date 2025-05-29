import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:flutter/foundation.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmileMeshDetectorPage(),
    );
  }
}

class SmileMeshDetectorPage extends StatefulWidget {
  @override
  _SmileMeshDetectorPageState createState() => _SmileMeshDetectorPageState();
}

class _SmileMeshDetectorPageState extends State<SmileMeshDetectorPage> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  double _mouthOpen = 0.0;
  double _smileProb = 0.0;
  String _laughLevel = "none";
  double _smileProgress = 0.0;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final FaceMeshDetector _faceMeshDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();
    _startImageStream();
    setState(() {});
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

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

          final smileProb = face.smilingProbability ?? 0.0;

          final upperLip = mesh.contours[FaceMeshContourType.upperLipTop];
          final lowerLip = mesh.contours[FaceMeshContourType.lowerLipBottom];

          double mouthOpen = 0.0;
          if (upperLip != null && lowerLip != null && upperLip.length > 5 && lowerLip.length > 5) {
            mouthOpen = (lowerLip[5].y - upperLip[5].y).abs();
          }

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
          } catch (_) {}

          _updateSmileProgress(smileProb, mouthOpen, cheekRaised, eyeWrinkleDetected);
        } else {
          _updateSmileProgress(0.0, 0.0, false, false); // Reset on no detection
        }
      } catch (e) {
        print("Detection error: $e");
      }

      _isDetecting = false;
    });
  }

void _updateSmileProgress(double smileProb, double mouthOpen, bool cheekRaised, bool eyeWrinkleDetected) {
  String laughLevel = "none";
  double step = 0.0;

  if ((smileProb > 0.8 && mouthOpen > 48) && cheekRaised && eyeWrinkleDetected) {
    step = 0.066; // Extreme
    laughLevel = "extreme";
  } else if (smileProb > 0.6 && mouthOpen > 38) {
    step = 0.033; // Moderate
    laughLevel = "moderate";
  } else if (smileProb > 0.3 && mouthOpen > 24) {
    step = 0.013; // Light
    laughLevel = "light";
  }
                        
  setState(() {
    _mouthOpen = mouthOpen;
    _smileProb = smileProb;
    _laughLevel = laughLevel;

    if (step > 0) {
      _smileProgress += step;
      if (_smileProgress > 1.0) _smileProgress = 1.0;
    } else {
      // Fast decay when not smiling
      _smileProgress -= 0.14;
      if (_smileProgress < 0.0) _smileProgress = 0.0;
    }
  });
}



  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _faceMeshDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mouth Open: $_mouthOpen'),
                Text('Smile Prob: $_smileProb'),
                Text('Laugh Level: $_laughLevel'),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: _smileProgress),
                duration: Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.orange,
                    minHeight: 20,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
