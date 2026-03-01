import 'package:flutter/material.dart';

enum AppPage {
  takeoff(label: 'Takeoff', icon: Icons.flight_takeoff),
  landing(label: 'Landing', icon: Icons.flight_land),
  flightTimes(label: 'Flight Times', icon: Icons.schedule);

  const AppPage({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
