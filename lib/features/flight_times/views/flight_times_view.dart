import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/features/flight_times/viewmodels/flight_times_viewmodel.dart';
import 'package:flightstate/core/services/voice_command_parser.dart';
import 'widgets/voice_input_dialog.dart';

class FlightTimesView extends StatelessWidget {
  const FlightTimesView({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildSectionHeader(context, 'Block On (UTC)', Icons.access_time),
            const SizedBox(height: 8),
            _buildBlockOnPicker(context, vm),

            const SizedBox(height: 20),

            // HOBBS & VUT inputs
            _buildSectionHeader(context, 'HOBBS & VUT', Icons.timer),
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
        title: const Text('Block On (UTC)'),
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
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voice Input Header (only show if available)
            if (vm.isVoiceAvailable) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Input',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, size: 18),
                        onPressed: () => _showVoiceHelpDialog(context),
                        tooltip: 'Show voice command examples',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  FloatingActionButton.small(
                    onPressed: vm.isListening ? null : () => _handleVoiceInput(context, vm),
                    backgroundColor: vm.isListening
                        ? Colors.red
                        : theme.colorScheme.primary,
                    tooltip: 'Start voice input',
                    child: Icon(vm.isListening ? Icons.mic : Icons.mic_none),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Existing input fields
            vm.inputMode == InputMode.direct
                ? _buildDirectInputs(context, vm)
                : _buildReadingsInputs(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectInputs(BuildContext context, FlightTimesViewModel vm) {
    return Column(
      children: [
        _buildDecimalField(
          context,
          label: 'HOBBS (hours)',
          value: vm.hobbsDiff,
          onChanged: vm.setHobbsDiff,
        ),
        const SizedBox(height: 16),
        _buildDecimalField(
          context,
          label: 'VUT (hours)',
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
                label: 'HOBBS Start',
                value: vm.hobbsStart,
                onChanged: vm.setHobbsStart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'HOBBS End',
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
                label: 'VUT Start',
                value: vm.vutStart,
                onChanged: vm.setVutStart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDecimalField(
                context,
                label: 'VUT End',
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
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return TextFormField(
      initialValue: value == 0.0 ? '' : value.toString(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) {
          onChanged(parsed);
        } else if (text.isEmpty) {
          onChanged(0.0);
        }
      },
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
            // HOBBS & VUT in both formats
            Row(
              children: [
                Expanded(
                  child: _buildDualFormatChip(
                    context,
                    'HOBBS',
                    vm.hobbsFormatted,
                    vm.hobbsHours,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDualFormatChip(
                    context,
                    'VUT',
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
            _buildTimeRow(context, 'Block On', vm.blockOnUtc, vm.blockOnLocal),
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

  // Voice Input Methods

  Future<void> _handleVoiceInput(BuildContext context, FlightTimesViewModel vm) async {
    // Start listening
    await vm.startVoiceInput();

    if (!context.mounted) return;

    // Show listening dialog - it will auto-close when done
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoiceInputDialog(viewModel: vm),
    );

    if (!context.mounted) return;

    // Show result feedback
    if (result == false) {
      // User cancelled
      return;
    }

    if (vm.voiceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.voiceError!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleVoiceInput(context, vm),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input applied successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showVoiceHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Input Guide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text('What Actually Works on Web:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Try saying NUMBERS instead of words:'),
                    SizedBox(height: 4),
                    Text('"Hobs 3.5, V U T 2.75, Block on 14 30"',
                      style: TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('How to Speak:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('1. Say "Hobs" (pause) "3.5"'),
              const SizedBox(height: 4),
              const Text('2. Say "V U T" (spell it) (pause) "2.75"'),
              const SizedBox(height: 4),
              const Text('3. Say "Block on" (pause) "14 30"'),
              const SizedBox(height: 16),
              const Text('Alternative Words:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Instead of "HOBBS" → say "Hobs" or "Hours"'),
              const SizedBox(height: 4),
              const Text('• Instead of "VUT" → spell it "V U T"'),
              const SizedBox(height: 4),
              const Text('• For time → say digits: "14 30" not "fourteen thirty"'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        SizedBox(width: 6),
                        Text('Web Speech Limitations:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• May not recognize aviation terms'),
                    SizedBox(height: 4),
                    Text('• Works best with common English words'),
                    SizedBox(height: 4),
                    Text('• Use numbers instead of spelling them out'),
                    SizedBox(height: 4),
                    Text('• Watch transcription box to see what it hears'),
                  ],
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
