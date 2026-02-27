import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/features/settings/viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 24),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Units Section
            _buildSectionHeader(context, 'Units', Icons.straighten),
            const SizedBox(height: 8),
            _buildUnitsCard(context, vm),

            const SizedBox(height: 24),

            // Safety Margins Section
            _buildSectionHeader(context, 'Safety Margins', Icons.shield),
            const SizedBox(height: 8),
            _buildSafetyMarginsCard(context, vm),

            const SizedBox(height: 24),

            // Takeoff Corrections Section
            _buildSectionHeader(context, 'Takeoff Corrections', Icons.flight_takeoff),
            const SizedBox(height: 8),
            _buildTakeoffCorrectionsCard(context, vm),

            const SizedBox(height: 24),

            // Landing Corrections Section
            _buildSectionHeader(context, 'Landing Corrections', Icons.flight_land),
            const SizedBox(height: 8),
            _buildLandingCorrectionsCard(context, vm),

            const SizedBox(height: 24),

            // Reset Button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  vm.resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings reset to defaults'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
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

  Widget _buildUnitsCard(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Measurement System',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildUnitOption(
                    context,
                    title: 'Metric',
                    subtitle: 'm, kg, °C',
                    isSelected: !vm.useImperial,
                    onTap: () => vm.setUseImperial(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUnitOption(
                    context,
                    title: 'Imperial',
                    subtitle: 'ft, lbs, °F',
                    isSelected: vm.useImperial,
                    onTap: () => vm.setUseImperial(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(77)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyMarginsCard(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply a personal safety multiplier to calculated distances:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _EditableSliderSetting(
              label: 'Takeoff Safety Margin',
              value: vm.takeoffSafetyMargin,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setTakeoffSafetyMargin,
            ),
            const SizedBox(height: 16),
            _EditableSliderSetting(
              label: 'Landing Safety Margin',
              value: vm.landingSafetyMargin,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setLandingSafetyMargin,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1.33 = +33%, 1.43 = +43% (Student pilot rule)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakeoffCorrectionsCard(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Used when POH does not provide specific data (Operations Manual):',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _EditableSliderSetting(
              label: 'Dry Grass (firm soil)',
              value: vm.takeoffDryGrassCorrection,
              min: 1.0,
              max: 1.4,
              decimals: 2,
              onChanged: vm.setTakeoffDryGrassCorrection,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Wet Grass (up to 13cm)',
              value: vm.takeoffWetGrassCorrection,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setTakeoffWetGrassCorrection,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Wet Paved',
              value: vm.takeoffWetPavedCorrection,
              min: 1.0,
              max: 1.3,
              decimals: 2,
              onChanged: vm.setTakeoffWetPavedCorrection,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Runway Slope (per 1% upslope)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Upslope Correction',
              value: vm.takeoffUpslopeCorrection * 100,
              min: 0,
              max: 15,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => vm.setTakeoffUpslopeCorrection(v / 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandingCorrectionsCard(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Used when POH does not provide specific data (Operations Manual):',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _EditableSliderSetting(
              label: 'Dry Grass (firm soil)',
              value: vm.landingDryGrassCorrection,
              min: 1.0,
              max: 1.4,
              decimals: 2,
              onChanged: vm.setLandingDryGrassCorrection,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Wet Grass (up to 13cm)',
              value: vm.landingWetGrassCorrection,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setLandingWetGrassCorrection,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Wet Paved',
              value: vm.landingWetPavedCorrection,
              min: 1.0,
              max: 1.3,
              decimals: 2,
              onChanged: vm.setLandingWetPavedCorrection,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Runway Slope (per 1% downslope)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _EditableSliderSetting(
              label: 'Downslope Correction',
              value: vm.landingDownslopeCorrection * 100,
              min: 0,
              max: 15,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => vm.setLandingDownslopeCorrection(v / 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableSliderSetting extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;
  final String? suffix;

  const _EditableSliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.decimals,
    required this.onChanged,
    this.suffix,
  });

  @override
  State<_EditableSliderSetting> createState() => _EditableSliderSettingState();
}

class _EditableSliderSettingState extends State<_EditableSliderSetting> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toStringAsFixed(widget.decimals),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(_EditableSliderSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _controller.text = widget.value.toStringAsFixed(widget.decimals);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() => _isEditing = true);
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      _submitValue();
      setState(() => _isEditing = false);
    }
  }

  void _submitValue() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _controller.text = clamped.toStringAsFixed(widget.decimals);
    } else {
      // Revert to current value
      _controller.text = widget.value.toStringAsFixed(widget.decimals);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisions = widget.decimals >= 2
        ? ((widget.max - widget.min) * 100).round()
        : widget.decimals == 1
            ? ((widget.max - widget.min) * 10).round()
            : (widget.max - widget.min).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  suffixText: widget.suffix,
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.primaryContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _submitValue(),
              ),
            ),
          ],
        ),
        Slider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          divisions: divisions,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
