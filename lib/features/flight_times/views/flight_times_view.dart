import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/features/flight_times/viewmodels/flight_times_viewmodel.dart';

class FlightTimesView extends StatelessWidget {
  const FlightTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<FlightTimesViewModel>(
      builder: (context, vm, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Settings Panel at top
            _buildSectionHeader(context, 'Settings', Icons.settings),
            const SizedBox(height: 8),
            _buildSettingsCard(context, vm),

            const SizedBox(height: 20),

            // Block On Time
            _buildSectionHeader(context, 'Block on time (UTC)', Icons.access_time),
            const SizedBox(height: 8),
            _buildBlockOnPicker(context, vm),

            const SizedBox(height: 20),

            // Total time & Tachometer time inputs
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader(context, 'Total time & Tachometer time', Icons.timer),
                ),
                if (vm.isVoiceAvailable)
                  FloatingActionButton.small(
                    onPressed: () => _handleVoiceInput(context, vm),
                    backgroundColor: vm.isRecording
                        ? Colors.red
                        : theme.colorScheme.primary,
                    tooltip: 'Voice input',
                    child: Icon(
                      vm.isRecording ? Icons.mic : Icons.mic_none,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.mic_off),
                    tooltip: 'Configure API key in Settings',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please configure OpenAI API key in Settings to use voice input'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18),
                  onPressed: () => _showVoiceHelpDialog(context),
                  tooltip: 'Voice command help',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHobbsVutCard(context, vm),

            const SizedBox(height: 20),

            // Results
            _buildSectionHeader(context, 'Flight Times', Icons.schedule),
            const SizedBox(height: 8),
            _buildResultsCard(context, vm),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, FlightTimesViewModel vm) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Mode Toggle
            Text(
              'Input Mode',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<InputMode>(
                segments: const [
                  ButtonSegment(
                    value: InputMode.direct,
                    label: Text('Direct (Diff)'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment(
                    value: InputMode.readings,
                    label: Text('Start / End'),
                    icon: Icon(Icons.compare_arrows),
                  ),
                ],
                selected: {vm.inputMode},
                onSelectionChanged: (set) => vm.setInputMode(set.first),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Taxi time
            Row(
              children: [
                Icon(Icons.local_taxi, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Taxi Time'),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: DropdownButton<int>(
                    value: vm.taxiMinutes,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(11, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text('$m min'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) vm.setTaxiMinutes(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // UTC offset
            Row(
              children: [
                Icon(Icons.public, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('UTC Offset')),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Winter +1')),
                    ButtonSegment(value: 2, label: Text('Summer +2')),
                  ],
                  selected: {vm.utcOffsetHours},
                  onSelectionChanged: (set) => vm.setUtcOffsetHours(set.first),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockOnPicker(BuildContext context, FlightTimesViewModel vm) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
        title: const Text('Block on time (UTC)'),
        trailing: Text(
          FlightTimesViewModel.formatTime(vm.blockOnUtc),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: vm.blockOnUtc,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );
          if (picked != null) {
            vm.setBlockOnUtc(picked);
          }
        },
      ),
    );
  }

  Widget _buildHobbsVutCard(BuildContext context, FlightTimesViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.inputMode == InputMode.direct
            ? _buildDirectInputs(context, vm)
            : _buildReadingsInputs(context, vm),
      ),
    );
  }

  Widget _buildDirectInputs(BuildContext context, FlightTimesViewModel vm) {
    return Column(
      children: [
        _buildDecimalField(
          context,
          label: 'Total time (hours)',
          subtitle: 'HOBBS time',
          value: vm.hobbsDiff,
          onChanged: vm.setHobbsDiff,
        ),
        const SizedBox(height: 16),
        _buildDecimalField(
          context,
          label: 'Tachometer time (hours)',
          subtitle: 'Engine time',
          value: vm.vutDiff,
          onChanged: vm.setVutDiff,
        ),
      ],
    );
  }

  Widget _buildReadingsInputs(BuildContext context, FlightTimesViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'Total time Start',
                subtitle: 'HOBBS time',
                value: vm.hobbsStart,
                onChanged: vm.setHobbsStart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'Total time End',
                subtitle: 'HOBBS time',
                value: vm.hobbsEnd,
                onChanged: vm.setHobbsEnd,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'Tachometer time Start',
                subtitle: 'Engine time',
                value: vm.vutStart,
                onChanged: vm.setVutStart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'Tachometer time End',
                subtitle: 'Engine time',
                value: vm.vutEnd,
                onChanged: vm.setVutEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDecimalField(
    BuildContext context, {
    required String label,
    String? subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return DecimalInputField(
      label: label,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildResultsCard(BuildContext context, FlightTimesViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withAlpha(26),
              theme.colorScheme.primary.withAlpha(13),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HOBBS & Flight time in both formats
            Row(
              children: [
                Expanded(
                  child: _buildDualFormatChip(
                    context,
                    'Total time',
                    vm.hobbsFormatted,
                    vm.hobbsHours,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDualFormatChip(
                    context,
                    'Tachometer time',
                    vm.vutFormatted,
                    vm.vutHours,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Time table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'UTC time',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Local time',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _buildTimeRow(context, 'Block Off', vm.blockOffUtc, vm.blockOffLocal),
            _buildTimeRow(context, 'Takeoff', vm.takeoffUtc, vm.takeoffLocal),
            _buildTimeRow(context, 'Landing', vm.arrivalUtc, vm.arrivalLocal),
            _buildTimeRow(context, 'Block on time', vm.blockOnUtc, vm.blockOnLocal),
          ],
        ),
      ),
    );
  }

  Widget _buildDualFormatChip(
    BuildContext context,
    String label,
    String hhmmValue,
    double decimalValue,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // HH:MM format
          Text(
            hhmmValue,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'hours:minutes',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(179),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          // Decimal format
          Text(
            '${decimalValue.toStringAsFixed(2)} h',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    String label,
    TimeOfDay utcTime,
    TimeOfDay localTime,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              FlightTimesViewModel.formatTime(utcTime),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              FlightTimesViewModel.formatTime(localTime),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput(BuildContext context, FlightTimesViewModel vm) {
    if (!vm.isVoiceAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure OpenAI API key in Settings'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VoiceInputDialog(viewModel: vm),
    );

    // Start recording
    vm.startVoiceInput();
  }

  void _showVoiceHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Command Examples'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Powered by OpenAI Whisper API',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Example Commands:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text(
                'Single Field:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text('"Block on time 14:30"'),
              const SizedBox(height: 4),
              const Text('"Total time 3.5"'),
              const SizedBox(height: 4),
              const Text('"Tachometer time start 8552.3 end 8552.8"'),
              const SizedBox(height: 12),
              const Text(
                'Multiple Fields:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text('"Total time 3.5, Tachometer time 2.75, Block on time 14:30"'),
              const SizedBox(height: 4),
              const Text('"Total time start 8552.3 end 8552.8, Block on time 14:30"'),
              const SizedBox(height: 16),
              const Text(
                'Flexible Phrasing:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text(
                'Total time (HOBBS time):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              const Text('Say: "Total time", "ops", "HOBBS"'),
              const SizedBox(height: 8),
              const Text(
                'Tachometer time (Engine time):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              const Text('Say: "Tachometer time", "tach", "engine time", "flight time"'),
              const SizedBox(height: 8),
              const Text(
                'Block on time:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              const Text('Say: "Block on time", "log on", "block on"'),
              const SizedBox(height: 8),
              const Text(
                'Time formats:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              const Text('• "14:30" or "14 30" → 14:30'),
              const SizedBox(height: 2),
              const Text('• "11 o\'clock" → 11:00'),
              const SizedBox(height: 2),
              const Text('• "half past 11" → 11:30'),
              const SizedBox(height: 2),
              const Text('• "quarter past 11" → 11:15'),
              const SizedBox(height: 2),
              const Text('• "quarter to 12" → 11:45'),
              const SizedBox(height: 16),
              const Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Fill just ONE field or ALL fields - it\'s flexible!'),
              const SizedBox(height: 4),
              const Text('• Combine manual input with voice input'),
              const SizedBox(height: 4),
              const Text('• Speak naturally - Whisper recognizes aviation terms'),
              const SizedBox(height: 4),
              const Text('• Fields can be in any order'),
              const SizedBox(height: 4),
              const Text('• Works in noisy environments'),
              const SizedBox(height: 16),
              Text(
                'First time? Set up your OpenAI API key in Settings.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _VoiceInputDialog extends StatefulWidget {
  final FlightTimesViewModel viewModel;

  const _VoiceInputDialog({required this.viewModel});

  @override
  State<_VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<_VoiceInputDialog> {
  double _audioLevel = 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<FlightTimesViewModel>(
      builder: (context, vm, _) {
        // Listen to audio amplitude when recording
        if (vm.isRecording) {
          widget.viewModel.audioAmplitudeStream?.listen((amplitude) {
            if (mounted) {
              setState(() {
                _audioLevel = amplitude;
              });
            }
          });
        }

        // Position dialog in upper third and make it compact
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(16),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact icon
                      Icon(
                        vm.isRecording ? Icons.mic : Icons.cloud_upload,
                        size: 40,
                        color: vm.isRecording ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(height: 8),

              // Audio level indicator (only when recording)
              if (vm.isRecording) ...[
                const Text(
                  'Listening...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // Audio level bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (index) {
                    final isActive = _audioLevel > (index * 0.1);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 20 + (isActive ? _audioLevel * 20 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _audioLevel > 0.1
                      ? '🎤 Audio detected!'
                      : '⚠️ No audio detected - speak louder',
                  style: TextStyle(
                    fontSize: 12,
                    color: _audioLevel > 0.1 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Status text
              if (!vm.isRecording)
                Text(
                  vm.isProcessing
                      ? 'Transcribing...'
                      : 'Ready',
                  style: const TextStyle(fontSize: 14),
                ),

              const SizedBox(height: 8),

              // Transcription preview
              if (vm.currentTranscription.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vm.currentTranscription,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Error display
              if (vm.voiceError != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vm.voiceError!,
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Loading indicator
              if (vm.isProcessing)
                const LinearProgressIndicator(),
            ],
          ),
          actions: [
            if (vm.isRecording) ...[
              TextButton(
                onPressed: () async {
                  await widget.viewModel.cancelVoiceInput();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await widget.viewModel.stopVoiceInput();
                  // Dialog stays open to show transcription result
                  // Auto-close if no error after a delay
                  if (widget.viewModel.voiceError == null && context.mounted) {
                    await Future.delayed(const Duration(seconds: 1));
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            ] else if (vm.isProcessing) ...[
              // Show Cancel button during processing
              TextButton(
                onPressed: () {
                  // Force cancel and close
                  widget.viewModel.cancelVoiceInput();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stateful widget for decimal input that properly manages TextEditingController
/// to avoid cursor issues and maintain focus during typing.
class DecimalInputField extends StatefulWidget {
  final String label;
  final String? subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  const DecimalInputField({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DecimalInputField> createState() => _DecimalInputFieldState();
}

class _DecimalInputFieldState extends State<DecimalInputField> {
  late TextEditingController _controller;
  bool _isInternalChange = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0.0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(DecimalInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update the controller if the value changed externally (e.g., from voice input)
    // and not from user typing
    if (!_isInternalChange && widget.value != oldWidget.value) {
      final newText = widget.value == 0.0 ? '' : widget.value.toString();
      if (_controller.text != newText) {
        _controller.text = newText;
        // Move cursor to end
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
    _isInternalChange = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.subtitle,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        _isInternalChange = true;
        final parsed = double.tryParse(text);
        if (parsed != null) {
          widget.onChanged(parsed);
        } else if (text.isEmpty) {
          widget.onChanged(0.0);
        }
      },
    );
  }
}
