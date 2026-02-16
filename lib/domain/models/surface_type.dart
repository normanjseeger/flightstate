enum SurfaceType {
  paved(label: 'Paved', correctionFactor: 1.0),
  dryShortGrass(label: 'Dry short grass', correctionFactor: 1.25),
  softGrass(label: 'Soft grass >10cm', correctionFactor: 1.40),
  dryGrass(label: 'Dry grass', correctionFactor: 1.15);

  const SurfaceType({required this.label, required this.correctionFactor});

  final String label;
  final double correctionFactor;
}
