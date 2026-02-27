enum AircraftType {
  dv20(label: 'Diamond DV-20 Katana'),
  c172p(label: 'Cessna 172P'),
  f172n(label: 'Reims Cessna F172N');

  const AircraftType({required this.label});

  final String label;
}
