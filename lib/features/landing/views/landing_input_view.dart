import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/data/aircraft/aircraft_registry.dart';
import 'package:flightstate/features/landing/viewmodels/landing_viewmodel.dart';

class LandingInputView extends StatelessWidget {
  const LandingInputView({super.key});

  static const String _appIconPath = 'assets/images/flightStateIconCropped.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  _appIconPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('FlightState'),
          ],
        ),
        actions: [
          Consumer<LandingViewModel>(
            builder: (_, vm, _) => TextButton.icon(
              onPressed: vm.toggleUnits,
              icon: Icon(
                vm.useImperial ? Icons.straighten : Icons.straighten,
                color: Colors.white70,
                size: 18,
              ),
              label: Text(
                vm.useImperial ? 'Imperial' : 'Metric',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<LandingViewModel>(
        builder: (context, vm, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Aircraft Selection
            _buildSectionHeader(context, 'Aircraft', Icons.airplanemode_active),
            const SizedBox(height: 8),
            _buildAircraftCard(context, vm),

            const SizedBox(height: 20),

            // 2. Conditions
            _buildSectionHeader(context, 'Conditions', Icons.tune),
            const SizedBox(height: 8),
            _buildConditionsCard(context, vm),

            const SizedBox(height: 20),

            // 3. Runway Surface
            _buildSectionHeader(context, 'Runway Condition', Icons.water_drop),
            const SizedBox(height: 8),
            _buildSurfaceCard(context, vm),

            const SizedBox(height: 20),

            // 4. Results (at the end)
            _buildSectionHeader(context, 'Landing Performance', Icons.flight_land),
            const SizedBox(height: 8),
            _buildResultsCard(context, vm),

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

  Widget _buildAircraftCard(BuildContext context, LandingViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Aircraft',
              style: theme.textTheme.bodyLarge,
            ),
            DropdownButton<AircraftType>(
              value: vm.aircraftType,
              underline: const SizedBox(),
              onChanged: (v) {
                if (v != null) vm.setAircraftType(v);
              },
              items: AircraftRegistry.supportedAircraft
                  .map(
                    (a) => DropdownMenuItem(
                      value: a,
                      child: Text(
                        a.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context, LandingViewModel vm) {
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
                      _appIconPath,
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
                        'Landing Distance',
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

            // Ground Roll
            _buildResultRow(
              context,
              icon: Icons.straighten,
              label: 'Ground Roll',
              value: vm.displayGroundRoll,
              unit: vm.distUnit,
              isHighlighted: true,
            ),
            const Divider(height: 24),

            // Over Obstacle
            _buildResultRow(
              context,
              icon: Icons.alt_route,
              label: 'Over ${vm.displayObstacleHeight.round()} ${vm.obstUnit} obstacle',
              value: vm.displayTotalDistance,
              unit: vm.distUnit,
              isHighlighted: true,
            ),
            const Divider(height: 24),

            // Over 50ft
            _buildResultRow(
              context,
              icon: Icons.park,
              label: 'Over 50 ft (15m) obstacle',
              value: vm.displayLandingDistance50ft,
              unit: vm.distUnit,
              isHighlighted: true,
            ),

            // Wet Surface Note
            if (vm.isWetSurface)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withAlpha(128)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Includes wet surface correction (+10%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                fontSize: isHighlighted ? 28 : 22,
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

  Widget _buildConditionsCard(BuildContext context, LandingViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSlider(
              context,
              icon: Icons.thermostat,
              label: 'Outside Air Temperature',
              value: vm.oat,
              min: vm.oatMin,
              max: vm.oatMax,
              divisions: ((vm.oatMax - vm.oatMin) * 1).round(),
              unit: vm.tempUnit,
              displayValue: vm.displayOat,
              onChanged: vm.setOat,
            ),

            const SizedBox(height: 16),

            _buildSlider(
              context,
              icon: Icons.height,
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

            _buildSlider(
              context,
              icon: Icons.scale,
              label: 'Aircraft Mass',
              value: vm.mass,
              min: vm.massMin,
              max: vm.massMax,
              divisions: ((vm.massMax - vm.massMin) / 1).round(),
              unit: vm.massUnit,
              displayValue: vm.displayMass,
              decimals: 0,
              onChanged: vm.setMass,
            ),

            const SizedBox(height: 16),

            _buildSlider(
              context,
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

            const SizedBox(height: 16),

            _buildSlider(
              context,
              icon: Icons.park,
              label: 'Obstacle Height',
              value: vm.obstacleHeight,
              min: vm.obstMin,
              max: vm.obstMax,
              divisions: (vm.obstMax - vm.obstMin).round().clamp(1, 100),
              unit: vm.obstUnit,
              displayValue: vm.displayObstacleHeight,
              decimals: 0,
              onChanged: vm.setObstacleHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required double displayValue,
    required ValueChanged<double> onChanged,
    String? subtitle,
    int decimals = 1,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${displayValue.toStringAsFixed(decimals)} $unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSurfaceCard(BuildContext context, LandingViewModel vm) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Runway Condition',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Dry'),
                  selected: !vm.isWetSurface,
                  onSelected: (_) => vm.setWetSurface(false),
                ),
                ChoiceChip(
                  label: const Text('Wet'),
                  selected: vm.isWetSurface,
                  onSelected: (_) => vm.setWetSurface(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
