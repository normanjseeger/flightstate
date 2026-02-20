import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/app.dart';

void main() {
  testWidgets('App renders takeoff input view', (WidgetTester tester) async {
    await tester.pumpWidget(const FlightStateApp());
    await tester.pumpAndSettle();

    expect(find.text('FlightState'), findsOneWidget);
    expect(find.text('Aircraft'), findsOneWidget);
    expect(find.text('Conditions'), findsOneWidget);
  });
}
