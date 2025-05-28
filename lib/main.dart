import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
      home: SmileDetectorPage(),
    );
  }
}

class SmileDetectorPage extends StatefulWidget {
  @override
  _SmileDetectorPageState createState() => _SmileDetectorPageState();
}

class _SmileDetectorPageState extends State<SmileDetectorPage> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  double _smileProgress = 0.0;
  Timer? _smileTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front),
      ResolutionPreset.low,
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
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );

        final faces = await _faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          final smileProb = faces.first.smilingProbability ?? 0.0;
          if (smileProb > 0.7) {
            _startSmileTimer();
          } else {
            _stopSmileTimer();
          }
        } else {
          _stopSmileTimer();
        }

      } catch (e) {
        print("Error in face detection: $e");
      }

      _isDetecting = false;
    });
  }

  void _startSmileTimer() {
    if (_smileTimer != null) return;

    _smileTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        _smileProgress += 0.01;
        if (_smileProgress >= 1.0) {
          _smileProgress = 1.0;
          timer.cancel();
          // TODO: Show "You Win!" animation
        }
      });
    });
  }

  void _stopSmileTimer() {
    _smileTimer?.cancel();
    _smileTimer = null;
    setState(() {
      _smileProgress -= 0.01;
      if (_smileProgress < 0) _smileProgress = 0;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _smileTimer?.cancel();
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: LinearProgressIndicator(
                value: _smileProgress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
                minHeight: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
