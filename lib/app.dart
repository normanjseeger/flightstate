import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flightstate/features/takeoff/viewmodels/takeoff_viewmodel.dart';
import 'package:flightstate/features/takeoff/views/takeoff_input_view.dart';

class FlightStateApp extends StatelessWidget {
  const FlightStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TakeoffViewModel(),
      child: MaterialApp(
        title: 'FlightState',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const TakeoffInputView(),
      ),
    );
  }
}
