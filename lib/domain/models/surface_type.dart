enum SurfaceType {
  paved(label: 'Paved', correctionFactor: 1.0, icon: 'apartment'),
  dryShortGrass(label: 'Dry short grass', correctionFactor: 1.25, icon: 'grass'),
  softGrass(label: 'Soft grass >10cm', correctionFactor: 1.40, icon: 'park'),
  wetLongGrass(label: 'Wet long grass', correctionFactor: 1.50, icon: 'water_drop'),
  compactedDirt(label: 'Compacted dirt', correctionFactor: 1.20, icon: 'landscape'),
  looseDirt(label: 'Loose dirt', correctionFactor: 1.35, icon: 'terrain'),
  snow(label: 'Snow', correctionFactor: 1.30, icon: 'ac_unit'),
  dryGrass(label: 'Dry grass', correctionFactor: 1.15, icon: 'eco');

  const SurfaceType({
    required this.label, 
    required this.correctionFactor,
    required this.icon,
  });

  final String label;
  final double correctionFactor;
  final String icon;
}
