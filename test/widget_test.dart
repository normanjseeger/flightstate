import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/app.dart';

void main() {
  testWidgets('App renders takeoff input view', (WidgetTester tester) async {
    await tester.pumpWidget(const FlightStateApp());

    expect(find.text('FlightState'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Ground Roll'), findsOneWidget);
    expect(find.text('Outside Air Temperature'), findsOneWidget);
  });
}
