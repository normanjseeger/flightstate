import 'package:flutter/material.dart';

/// Landing surface types with their correction factors.
/// Based on AFM notes for landing distances.
enum LandingSurfaceType {
  dryPaved(label: 'Dry Paved', correctionFactor: 1.0, icon: Icons.straighten),
  wetPaved(label: 'Wet Paved', correctionFactor: 1.1, icon: Icons.water_drop),
  dryGrass(label: 'Dry Grass', correctionFactor: 1.45, icon: Icons.grass);

  const LandingSurfaceType({
    required this.label,
    required this.correctionFactor,
    required this.icon,
  });

  final String label;
  final double correctionFactor;
  final IconData icon;
}
