import 'package:flutter_test/flutter_test.dart';
import 'package:busnap/main.dart';

void main() {
  testWidgets('BusnapApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BusnapApp());
    expect(find.text('Busnap'), findsOneWidget);
  });
}
