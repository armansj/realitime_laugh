import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
    bool _isBackgroundMusicEnabled = true;
  bool _isSoundEffectsEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  bool _wasPlayingBeforePause = false;
  
  bool get isBackgroundMusicEnabled => _isBackgroundMusicEnabled;
  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  /// Initialize the audio service
  Future<void> initialize() async {
    await _loadPreferences();
    await _setupAudioPlayers();
  }

  /// Load audio preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isBackgroundMusicEnabled = prefs.getBool('background_music_enabled') ?? true;
    _isSoundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
  }  /// Setup audio players with initial configuration
  Future<void> _setupAudioPlayers() async {
    // Set background music to loop
    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Set volume levels for background music
    await _backgroundMusicPlayer.setVolume(0.3); // Background music volume
  }
  /// Start playing background music
  Future<void> startBackgroundMusic() async {
    if (!_isBackgroundMusicEnabled || _isBackgroundMusicPlaying) return;
    
    try {
      await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'));
      _isBackgroundMusicPlaying = true;
      print('Background music started');
    } catch (e) {
      print('Error starting background music: $e');
    }
  }
  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (!_isBackgroundMusicPlaying) return;
    
    try {
      await _backgroundMusicPlayer.stop();
      _isBackgroundMusicPlaying = false;
      _wasPlayingBeforePause = false;
      print('Background music stopped');
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }
  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (!_isBackgroundMusicPlaying) return;
    
    try {
      _wasPlayingBeforePause = true;
      await _backgroundMusicPlayer.pause();
      print('Background music paused');
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isBackgroundMusicEnabled || !_wasPlayingBeforePause) return;
    
    try {
      await _backgroundMusicPlayer.resume();
      _wasPlayingBeforePause = false;
      print('Background music resumed');
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }/// Play tick sound for countdown
  Future<void> playTickSound() async {
    if (!_isSoundEffectsEnabled) return;
    
    try {
      // Create a new player for each tick sound to avoid conflicts
      final tickPlayer = AudioPlayer();
      await tickPlayer.setVolume(0.8); // Louder for countdown urgency
      await tickPlayer.play(AssetSource('audio/timer_ticks.mp3'));
      
      print('Tick sound played');
      
      // Dispose the player after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        tickPlayer.dispose();
      });
    } catch (e) {
      print('Error playing tick sound: $e');
    }
  }

  /// Provide vibration for time's up
  Future<void> playTimesUpVibration() async {
    try {
      // Check if device supports vibration
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Strong vibration for time's up (200ms)
        await Vibration.vibrate(duration: 200);
      }
      
      print('Times up vibration provided');
    } catch (e) {
      print('Error providing times up vibration: $e');
    }
  }  /// Pause background music when entering game mode
  Future<void> enterGameMode() async {
    if (_isBackgroundMusicPlaying) {
      await pauseBackgroundMusic();
      print('Game mode entered - background music paused');
    }
  }

  /// Resume background music when exiting game mode
  Future<void> exitGameMode() async {
    if (_isBackgroundMusicEnabled && _wasPlayingBeforePause) {
      await resumeBackgroundMusic();
      print('Game mode exited - background music resumed');
    }
  }

  /// Enable/disable background music
  Future<void> setBackgroundMusicEnabled(bool enabled) async {
    _isBackgroundMusicEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_music_enabled', enabled);
    
    if (enabled && !_isBackgroundMusicPlaying) {
      await startBackgroundMusic();
    } else if (!enabled && _isBackgroundMusicPlaying) {
      await stopBackgroundMusic();
    }
  }

  /// Enable/disable sound effects
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _isSoundEffectsEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects_enabled', enabled);
  }
  /// Set background music volume (0.0 to 1.0)
  Future<void> setBackgroundMusicVolume(double volume) async {
    // Clamp volume to reasonable range for background music
    final clampedVolume = volume.clamp(0.0, 0.6); // Max 60% for background music
    await _backgroundMusicPlayer.setVolume(clampedVolume);
  }
  /// Set sound effects volume (0.0 to 1.0)
  Future<void> setSoundEffectsVolume(double volume) async {
    // Sound effects now use isolated players, so this method does nothing
    // but is kept for compatibility
  }
  /// Dispose audio players
  Future<void> dispose() async {
    await _backgroundMusicPlayer.dispose();
  }
}
