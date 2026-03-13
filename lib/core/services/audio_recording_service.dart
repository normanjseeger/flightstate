import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// Service for recording audio from the microphone to a temporary M4A file.
///
/// This service handles:
/// - Microphone permission checking
/// - Recording audio in M4A/AAC format (optimized for Whisper API)
/// - Returning file path when recording is complete
/// - Providing amplitude stream for UI feedback
class AudioRecordingService {
  final _recorder = AudioRecorder();
  String? _currentRecordingPath;

  /// Check if the app has permission to use the microphone.
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording audio to a temporary M4A file.
  ///
  /// Audio is recorded at 16kHz sample rate, which is optimized for
  /// speech recognition with the Whisper API.
  ///
  /// Throws an exception if recording fails to start.
  Future<void> startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _currentRecordingPath = '${tempDir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, // WAV format - universally compatible
        sampleRate: 16000, // Whisper optimized sample rate
        bitRate: 128000,
      ),
      path: _currentRecordingPath!,
    );
  }

  /// Stop recording and return the path to the recorded audio file.
  ///
  /// Returns null if no recording was in progress or if the recording failed.
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _currentRecordingPath = null;
    return path;
  }

  /// Get a stream of amplitude values for the current recording.
  ///
  /// This can be used to provide visual feedback during recording.
  Stream<Amplitude> get amplitudeStream => _recorder.onAmplitudeChanged(const Duration(milliseconds: 200));

  /// Check if recording is currently in progress.
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Dispose of the recorder resources.
  ///
  /// Should be called when the service is no longer needed.
  void dispose() {
    _recorder.dispose();
  }
}
