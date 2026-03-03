import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/flight_times_viewmodel.dart';

/// Dialog shown while listening for voice input
class VoiceInputDialog extends StatefulWidget {
  final FlightTimesViewModel viewModel;

  const VoiceInputDialog({
    required this.viewModel,
    super.key,
  });

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create pulsing animation for the microphone icon
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the pulsing animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<FlightTimesViewModel>(
        builder: (context, vm, _) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.mic,
                  color: vm.isListening ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(vm.isListening ? 'Recording...' : 'Processing...'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated microphone icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.mic,
                    size: 80,
                    color: vm.isListening ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                Text(
                  vm.isListening
                      ? 'Speak your flight parameters clearly.\nClick "Done" when finished.'
                      : 'Processing your voice input...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Real-time transcription display or error message
                if (vm.isListening) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: vm.voiceError != null ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: vm.voiceError != null ? Colors.red[300]! : Colors.grey[300]!,
                      ),
                    ),
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.voiceError != null ? 'Error:' : 'Transcription:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: vm.voiceError != null ? Colors.red[700] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.voiceError ??
                          (vm.currentTranscription.isEmpty
                              ? 'Listening... (speak now)'
                              : vm.currentTranscription),
                          style: TextStyle(
                            fontSize: 14,
                            color: vm.voiceError != null
                                ? Colors.red[900]
                                : (vm.currentTranscription.isEmpty
                                    ? Colors.grey[500]
                                    : Colors.black87),
                            fontStyle: vm.currentTranscription.isEmpty && vm.voiceError == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Progress indicator
                if (vm.isListening)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
              ],
            ),
            actions: [
              if (vm.isListening) ...[
                // Cancel button
                TextButton(
                  onPressed: () {
                    widget.viewModel.cancelVoiceInput();
                    Navigator.of(context).pop(false); // Return false = cancelled
                  },
                  child: const Text('Cancel'),
                ),
                // Retry button (if error)
                if (vm.voiceError != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await widget.viewModel.cancelVoiceInput();
                      if (context.mounted) {
                        Navigator.of(context).pop(false);
                        // The parent will handle showing the dialog again
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                // Stop and process button (only if no error)
                if (vm.voiceError == null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await widget.viewModel.stopVoiceInput();
                      if (context.mounted) {
                        Navigator.of(context).pop(true); // Return true = completed
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
