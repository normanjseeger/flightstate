import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/core/models/app_page.dart';
import 'package:flightstate/data/aircraft/aircraft_registry.dart';
import 'package:flightstate/features/takeoff/views/takeoff_input_view.dart';
import 'package:flightstate/features/takeoff/viewmodels/takeoff_viewmodel.dart';
import 'package:flightstate/features/landing/views/landing_input_view.dart';
import 'package:flightstate/features/landing/viewmodels/landing_viewmodel.dart';
import 'package:flightstate/features/flight_times/views/flight_times_view.dart';
import 'package:flightstate/features/flight_times/viewmodels/flight_times_viewmodel.dart';
import 'package:flightstate/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:flightstate/features/settings/views/settings_view.dart';

class FlightStateApp extends StatefulWidget {
  const FlightStateApp({super.key});

  @override
  State<FlightStateApp> createState() => _FlightStateAppState();
}

class _FlightStateAppState extends State<FlightStateApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()..loadSettings()),
        ChangeNotifierProvider(create: (_) => TakeoffViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => FlightTimesViewModel()),
      ],
      child: MaterialApp(
        title: 'FlightState',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const _MainScreen(),
      ),
    );
  }

  // Aviation-inspired color scheme
  static const Color _primaryColor = Color(0xFF1565C0); // Aviation Blue
  static const Color _secondaryColor = Color(0xFF42A5F5); // Sky Blue
  static const Color _accentColor = Color(0xFFFF8F00); // Amber/Orange for highlights
  static const Color _surfaceColor = Color(0xFFF5F7FA); // Light gray-blue

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: _surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card styling
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),

      // Input/Slider styling
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: _primaryColor.withAlpha(51),
        thumbColor: _primaryColor,
        overlayColor: _primaryColor.withAlpha(31),
        valueIndicatorColor: _primaryColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Dropdown styling
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Text styling
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _primaryColor,
        size: 24,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _secondaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',

      // AppBar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card styling
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2D2D2D),
      ),

      // Input/Slider styling
      sliderTheme: SliderThemeData(
        activeTrackColor: _secondaryColor,
        inactiveTrackColor: _secondaryColor.withAlpha(51),
        thumbColor: _secondaryColor,
        overlayColor: _secondaryColor.withAlpha(31),
        valueIndicatorColor: _secondaryColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text styling
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFE0E0E0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFB0B0B0),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _secondaryColor,
        size: 24,
      ),
    );
  }
}

class _MainScreen extends StatefulWidget {
  const _MainScreen();

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  static const String _appIconPath = 'assets/images/flightStateIcon.png';

  AppPage _selectedPage = AppPage.takeoff;

  void _onAircraftChanged(AircraftType type) {
    final takeoffVm = context.read<TakeoffViewModel>();
    final landingVm = context.read<LandingViewModel>();
    takeoffVm.setAircraftType(type);
    landingVm.setAircraftType(type);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedPage) {
      case AppPage.takeoff:
        return const TakeoffInputView();
      case AppPage.landing:
        return const LandingInputView();
      case AppPage.flightTimes:
        return const FlightTimesView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final takeoffVm = context.watch<TakeoffViewModel>();

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
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Shared aircraft dropdown
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aircraft',
                    style: theme.textTheme.bodyLarge,
                  ),
                  DropdownButton<AircraftType>(
                    value: takeoffVm.aircraftType,
                    underline: const SizedBox(),
                    onChanged: (v) {
                      if (v != null) _onAircraftChanged(v);
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
          ),

          // Page selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<AppPage>(
              segments: AppPage.values
                  .map(
                    (page) => ButtonSegment(
                      value: page,
                      label: Text(page.label),
                      icon: Icon(page.icon),
                    ),
                  )
                  .toList(),
              selected: {_selectedPage},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedPage = set.first;
                });
              },
            ),
          ),

          // Active page content
          Expanded(child: _buildPageContent()),
        ],
      ),
    );
  }
}
