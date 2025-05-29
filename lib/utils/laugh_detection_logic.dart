import '../models/face_detection_service.dart';

class LaughDetectionLogic {
  // Use the exact thresholds from your working code
  static const double EXTREME_SMILE_THRESHOLD = 0.8;
  static const double EXTREME_MOUTH_THRESHOLD = 48.0;
  static const double MODERATE_SMILE_THRESHOLD = 0.6;
  static const double MODERATE_MOUTH_THRESHOLD = 38.0;
  static const double LIGHT_SMILE_THRESHOLD = 0.3;
  static const double LIGHT_MOUTH_THRESHOLD = 24.0;
  // Use the exact steps from your working code
  static const double EXTREME_STEP = 0.066;
  static const double MODERATE_STEP = 0.033;
  static const double LIGHT_STEP = 0.013;
  static const double DECAY_STEP = 0.02; // Much slower decay to prevent reset during continuous laugh
  
  static LaughAnalysisResult analyzeLaughter(FaceAnalysisResult faceResult) {
    String laughLevel = "none";
    double step = 0.0;    // Use the exact algorithm from your working code
    if ((faceResult.smileProb > EXTREME_SMILE_THRESHOLD && 
         faceResult.mouthOpen > EXTREME_MOUTH_THRESHOLD) && 
         faceResult.cheekRaised && 
         faceResult.eyeWrinkleDetected) {
      step = EXTREME_STEP;
      laughLevel = "extreme";
    } else if (faceResult.smileProb > MODERATE_SMILE_THRESHOLD && 
               faceResult.mouthOpen > MODERATE_MOUTH_THRESHOLD) {
      step = MODERATE_STEP;
      laughLevel = "moderate";
    } else if (faceResult.smileProb > LIGHT_SMILE_THRESHOLD && 
               faceResult.mouthOpen > LIGHT_MOUTH_THRESHOLD) {
      step = LIGHT_STEP;
      laughLevel = "light";
    }

    return LaughAnalysisResult(
      laughLevel: laughLevel,
      progressStep: step,
      isLaughing: step > 0,
    );
  }  static double updateProgress(double currentProgress, LaughAnalysisResult laughResult, {bool isInLaughSession = false}) {
    if (laughResult.isLaughing) {
      currentProgress += laughResult.progressStep;
      if (currentProgress > 1.0) {
        currentProgress = 1.0;
      }
    } else {
      // Use different decay rates based on context
      double decayRate = isInLaughSession ? 0.005 : 0.14; // Slow decay during laugh session, fast when clearly not laughing
      currentProgress -= decayRate;
      if (currentProgress < 0.0) {
        currentProgress = 0.0;
      }
    }
    
    return currentProgress;
  }
}

class LaughAnalysisResult {
  final String laughLevel;
  final double progressStep;
  final bool isLaughing;

  LaughAnalysisResult({
    required this.laughLevel,
    required this.progressStep,
    required this.isLaughing,
  });
}
