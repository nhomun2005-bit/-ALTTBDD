import 'package:flutter_test/flutter_test.dart';
import 'package:duanmuahexanh/main.dart';

void main() {
  testWidgets('Mua He Xanh App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MuaHeXanhApp());
    expect(find.text('CHIẾN DỊCH MÙA HÈ XANH'), findsOneWidget);
  });
}
