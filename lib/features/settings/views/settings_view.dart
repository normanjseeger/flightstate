import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/features/settings/viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

            // Default Corrections Section
            _buildSectionHeader(context, 'Default Corrections', Icons.tune),
            const SizedBox(height: 8),
            _buildDefaultCorrectionsCard(context, vm),

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
              'Apply a safety multiplier to calculated distances:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context,
              label: 'Takeoff Safety Margin',
              value: vm.takeoffSafetyMargin,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setTakeoffSafetyMargin,
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context,
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

  Widget _buildDefaultCorrectionsCard(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Used when POH does not provide specific data:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context,
              label: 'Dry Grass',
              value: vm.dryGrassCorrection,
              min: 1.0,
              max: 1.4,
              decimals: 2,
              onChanged: vm.setDryGrassCorrection,
            ),
            const SizedBox(height: 12),
            _buildSliderSetting(
              context,
              label: 'Wet Grass',
              value: vm.wetGrassCorrection,
              min: 1.0,
              max: 1.5,
              decimals: 2,
              onChanged: vm.setWetGrassCorrection,
            ),
            const SizedBox(height: 12),
            _buildSliderSetting(
              context,
              label: 'Wet Paved',
              value: vm.wetPavedCorrection,
              min: 1.0,
              max: 1.3,
              decimals: 2,
              onChanged: vm.setWetPavedCorrection,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Runway Slope Corrections (per 1% slope)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildSliderSetting(
              context,
              label: 'Upslope (Takeoff)',
              value: vm.upslopeCorrection * 100,
              min: 0,
              max: 15,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => vm.setUpslopeCorrection(v / 100),
            ),
            const SizedBox(height: 12),
            _buildSliderSetting(
              context,
              label: 'Downslope (Landing)',
              value: vm.downslopeCorrection * 100,
              min: 0,
              max: 15,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => vm.setDownslopeCorrection(v / 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int decimals,
    required ValueChanged<double> onChanged,
    String? suffix,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${value.toStringAsFixed(decimals)}${suffix ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * (decimals == 0 ? 1 : 10)).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
