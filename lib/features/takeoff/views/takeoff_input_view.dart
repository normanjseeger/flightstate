import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/domain/models/surface_type.dart';
import 'package:flightstate/features/takeoff/viewmodels/takeoff_viewmodel.dart';


class TakeoffInputView extends StatelessWidget {
  const TakeoffInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlightState'),
        actions: [
          Consumer<TakeoffViewModel>(
            builder: (_, vm, _) => TextButton.icon(
              onPressed: vm.toggleUnits,
              icon: const Icon(Icons.swap_horiz),
              label: Text(vm.useImperial ? 'Imperial' : 'Metric'),
            ),
          ),
        ],
      ),
      body: Consumer<TakeoffViewModel>(
        builder: (context, vm, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildResultsCard(vm),
            const SizedBox(height: 8),
            _buildSurfaceDropdown(vm),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Outside Air Temperature',
              value: vm.oat,
              min: vm.oatMin,
              max: vm.oatMax,
              divisions: 60,
              unit: vm.tempUnit,
              displayValue: vm.displayOat,
              onChanged: vm.setOat,
            ),
            _buildSlider(
              label: 'Pressure Altitude',
              value: vm.pressureAltitude,
              min: vm.altMin,
              max: vm.altMax,
              divisions: 80,
              unit: vm.altUnit,
              displayValue: vm.pressureAltitude,
              decimals: 0,
              onChanged: vm.setPressureAltitude,
            ),
            _buildSlider(
              label: 'Mass',
              value: vm.mass,
              min: vm.massMin,
              max: vm.massMax,
              divisions: 130,
              unit: vm.massUnit,
              displayValue: vm.displayMass,
              decimals: 0,
              onChanged: vm.setMass,
            ),
            _buildSlider(
              label: 'Headwind Component',
              value: vm.headwind,
              min: vm.windMin,
              max: vm.windMax,
              divisions: 30,
              unit: vm.windUnit,
              displayValue: vm.headwind,
              subtitle: 'Negative = tailwind',
              onChanged: vm.setHeadwind,
            ),
            _buildSlider(
              label: 'Obstacle Height',
              value: vm.obstacleHeight,
              min: vm.obstMin,
              max: vm.obstMax,
              divisions: 15,
              unit: vm.obstUnit,
              displayValue: vm.displayObstacleHeight,
              decimals: 0,
              onChanged: vm.setObstacleHeight,
            ),
            if (vm.validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  vm.validationError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(TakeoffViewModel vm) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _resultRow(
              'Ground Roll',
              vm.displayGroundRoll,
              vm.distUnit,
            ),
            const SizedBox(height: 8),
            _resultRow(
              'Over ${vm.displayObstacleHeight.round()} ${vm.obstUnit} obstacle',
              vm.displayTotalDistance,
              vm.distUnit,
            ),
            if (vm.surfaceType != SurfaceType.paved)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Includes ${vm.surfaceType.label} correction '
                  '(+${((vm.surfaceType.correctionFactor - 1) * 100).round()}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, double value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          '${value.round()} $unit',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
              Text(
                '${displayValue.toStringAsFixed(decimals)} $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceDropdown(TakeoffViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Runway Surface',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        DropdownButton<SurfaceType>(
          value: vm.surfaceType,
          onChanged: (v) {
            if (v != null) vm.setSurfaceType(v);
          },
          items: SurfaceType.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
              .toList(),
        ),
      ],
    );
  }
}
