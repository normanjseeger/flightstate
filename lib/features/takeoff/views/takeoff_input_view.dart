import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/core/widgets/afm_remarks_panel.dart';
import 'package:flightstate/core/widgets/editable_slider.dart';
import 'package:flightstate/features/takeoff/viewmodels/takeoff_viewmodel.dart';
import 'package:flightstate/features/settings/viewmodels/settings_viewmodel.dart';

class TakeoffInputView extends StatelessWidget {
  const TakeoffInputView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<TakeoffViewModel, SettingsViewModel>(
        builder: (context, vm, settingsVm, _) {
          final useImperial = settingsVm.useImperial;
          // Recalculate if safety margin changed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.result.safetyMargin != settingsVm.takeoffSafetyMargin) {
              vm.recalculateWithSafetyMargin(
                settingsVm.takeoffSafetyMargin,
                slopeCorrectionPerPercent: settingsVm.takeoffUpslopeCorrection,
              );
            }
          });
          return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Conditions Section
            _buildSectionHeader(context, 'Conditions', Icons.tune),
            const SizedBox(height: 8),
            _buildConditionsCard(context, vm, useImperial),

            const SizedBox(height: 20),

            // Runway Surface / Condition
            _buildSectionHeader(context, 'Runway Surface / Condition', Icons.wb_sunny),
            const SizedBox(height: 8),
            _buildSurfaceCard(context, vm),

            const SizedBox(height: 20),

            // Results Section
            _buildSectionHeader(context, 'Takeoff Performance', Icons.speed),
            const SizedBox(height: 8),
            _buildResultsCard(context, vm, useImperial),

            // Validation Error
            if (vm.validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.validationError!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // AFM Remarks Panel
            AfmRemarksPanel(
              title: 'Remarks',
              conditions: vm.aircraftData.takeoffConditions,
              notes: vm.aircraftData.takeoffNotes,
              initiallyExpanded: true,
            ),

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

  Widget _buildResultsCard(BuildContext context, TakeoffViewModel vm, bool useImperial) {
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
            // App icon + Title
            Row(
              children: [
                // Custom app icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/flightStateIcon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Takeoff Distance',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        vm.aircraftType.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ground Roll Result
            _buildResultRow(
              context,
              icon: Icons.straighten,
              label: 'Ground Roll',
              value: vm.displayGroundRoll(useImperial),
              unit: vm.distUnit(useImperial),
              isHighlighted: true,
            ),
            _buildBreakdown(context, vm, useImperial: useImperial, isGroundRoll: true),
            const Divider(height: 24),

            // Total Distance Result
            _buildResultRow(
              context,
              icon: Icons.forest,
              label: useImperial
                  ? 'Over ${vm.displayObstacleHeight(useImperial).round()} ft / ${vm.obstacleHeight.round()} m obstacle'
                  : 'Over ${vm.obstacleHeight.round()} m / ${vm.obstacleHeight == 15 ? '50' : vm.displayObstacleHeight(true).round()} ft obstacle',
              value: vm.displayTotalDistance(useImperial),
              unit: vm.distUnit(useImperial),
              isHighlighted: true,
            ),
            _buildBreakdown(context, vm, useImperial: useImperial, isGroundRoll: false),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required String unit,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary.withAlpha(179),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${value.round()}',
              style: TextStyle(
                fontSize: isHighlighted ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? theme.colorScheme.primary : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withAlpha(179),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdown(BuildContext context, TakeoffViewModel vm, {required bool useImperial, required bool isGroundRoll}) {
    final theme = Theme.of(context);
    final r = vm.result;
    final unit = vm.distUnit(useImperial);
    final toDisplay = useImperial ? (double m) => m * 3.28084 : (double m) => m;

    final baseVal = toDisplay(r.baseGroundRollM).round();
    final parts = <String>[];

    if (isGroundRoll) {
      // Ground roll: base × mass × wind × surface × slope × safety = result
      parts.add('POH base: $baseVal $unit');
      if (r.massFactor != 1.0) {
        parts.add('mass: ×${r.massFactor.toStringAsFixed(2)}');
      }
      if (r.windFactor != 1.0) {
        parts.add('wind: ×${r.windFactor.toStringAsFixed(2)}');
      }
      if (r.surfaceFactor != 1.0) {
        parts.add('surface: ×${r.surfaceFactor.toStringAsFixed(2)}');
      }
      if (r.slopeFactor != 1.0) {
        parts.add('slope: ×${r.slopeFactor.toStringAsFixed(2)}');
      }
      if (r.safetyMargin != 1.0) {
        parts.add('safety: ×${r.safetyMargin.toStringAsFixed(2)}');
      }
    } else {
      // Over obstacle: ground roll (before safety) × obstacle × safety = total
      final grVal = toDisplay(r.groundRollM).round();
      parts.add('ground roll: $grVal $unit');
      if (r.obstacleFactor != 1.0) {
        parts.add('obstacle: ×${r.obstacleFactor.toStringAsFixed(2)}');
      }
      if (r.safetyMargin != 1.0) {
        parts.add('safety: ×${r.safetyMargin.toStringAsFixed(2)}');
      }
    }

    // For ground roll, always show POH base even if no corrections applied
    // For obstacle clearance, only show if there are multiple parts
    if (parts.isEmpty) return const SizedBox.shrink();
    if (!isGroundRoll && parts.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 36),
      child: Text(
        parts.join(' → '),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildConditionsCard(BuildContext context, TakeoffViewModel vm, bool useImperial) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Temperature
            EditableSlider(
              icon: Icons.thermostat,
              label: 'Outside Air Temperature',
              value: vm.oat,
              min: vm.oatMin,
              max: vm.oatMax,
              divisions: ((vm.oatMax - vm.oatMin) * 1).round(),
              unit: vm.tempUnit(useImperial),
              displayValue: vm.displayOat(useImperial),
              displayToValue: useImperial ? (f) => fahrenheitToCelsius(f) : null,
              onChanged: vm.setOat,
            ),

            const SizedBox(height: 16),

            // Pressure Altitude
            EditableSlider(
              icon: Icons.speed,
              label: 'Pressure Altitude',
              value: vm.pressureAltitude,
              min: vm.altMin,
              max: vm.altMax,
              divisions: ((vm.altMax - vm.altMin) / 100).round(),
              unit: vm.altUnit,
              displayValue: vm.pressureAltitude,
              decimals: 0,
              onChanged: vm.setPressureAltitude,
            ),

            const SizedBox(height: 16),

            // Mass
            EditableSlider(
              icon: Icons.scale,
              label: 'Aircraft Mass',
              value: vm.mass,
              min: vm.massMin,
              max: vm.massMax,
              divisions: ((vm.massMax - vm.massMin) / 1).round(),
              unit: vm.massUnit(useImperial),
              displayValue: vm.displayMass(useImperial),
              displayToValue: useImperial ? (lbs) => lbsToKg(lbs) : null,
              decimals: 0,
              onChanged: vm.setMass,
            ),

            const SizedBox(height: 16),

            // Wind
            EditableSlider(
              icon: Icons.air,
              label: 'Headwind Component',
              value: vm.headwind,
              min: vm.windMin,
              max: vm.windMax,
              divisions: ((vm.windMax - vm.windMin) * 1).round(),
              unit: vm.windUnit,
              displayValue: vm.headwind,
              subtitle: 'Negative = tailwind',
              onChanged: vm.setHeadwind,
            ),

            // Obstacle (conditional)
            if (vm.showObstacleSlider) ...[
              const SizedBox(height: 16),
              EditableSlider(
                icon: Icons.park,
                label: 'Obstacle Height',
                value: vm.obstacleHeight,
                min: vm.obstMin,
                max: vm.obstMax,
                divisions: (vm.obstMax - vm.obstMin).round().clamp(1, 100),
                unit: vm.obstUnit(useImperial),
                displayValue: vm.displayObstacleHeight(useImperial),
                decimals: 0,
                onChanged: vm.setObstacleHeight,
                displayToValue: useImperial
                    ? (displayVal) => displayVal == 50.0 ? 15.0 : displayVal * 0.3048
                    : null,
              ),
            ],

            const SizedBox(height: 16),

            // Runway Slope
            EditableSlider(
              icon: Icons.terrain,
              label: 'Runway Slope',
              value: vm.slopePercentage,
              min: vm.slopeMin,
              max: vm.slopeMax,
              divisions: ((vm.slopeMax - vm.slopeMin) * 10).round(),
              unit: '%',
              displayValue: vm.slopePercentage,
              decimals: 1,
              subtitle: 'Negative = downslope, Positive = upslope',
              onChanged: vm.setSlopePercentage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurfaceCard(BuildContext context, TakeoffViewModel vm) {
    final theme = Theme.of(context);
    final settingsVm = context.watch<SettingsViewModel>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // POH-provided surfaces
            Text(
              'POH Data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.supportedSurfaces.map((surface) {
                final isSelected = vm.customSurfaceFactor == 0 && vm.surfaceType == surface;
                final factor = surface.correctionFactor;
                return ChoiceChip(
                  label: Text(
                    '${surface.label} (${factor.toStringAsFixed(2)}x)',
                  ),
                  selected: isSelected,
                  onSelected: (_) => vm.setSurfaceType(surface),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Additional surfaces from settings
            Text(
              'Additional (from Settings)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(
                    'Wet Paved (${settingsVm.takeoffWetPavedCorrection.toStringAsFixed(2)}x)',
                  ),
                  selected: vm.customSurfaceFactor == settingsVm.takeoffWetPavedCorrection,
                  onSelected: (_) => vm.setCustomSurfaceFactor(settingsVm.takeoffWetPavedCorrection),
                ),
                ChoiceChip(
                  label: Text(
                    'Wet Grass (${settingsVm.takeoffWetGrassCorrection.toStringAsFixed(2)}x)',
                  ),
                  selected: vm.customSurfaceFactor == settingsVm.takeoffWetGrassCorrection,
                  onSelected: (_) => vm.setCustomSurfaceFactor(settingsVm.takeoffWetGrassCorrection),
                ),
                ChoiceChip(
                  label: Text(
                    'Dry Grass (${settingsVm.takeoffDryGrassCorrection.toStringAsFixed(2)}x)',
                  ),
                  selected: vm.customSurfaceFactor == settingsVm.takeoffDryGrassCorrection,
                  onSelected: (_) => vm.setCustomSurfaceFactor(settingsVm.takeoffDryGrassCorrection),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
