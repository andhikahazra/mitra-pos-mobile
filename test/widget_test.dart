import 'package:flutter_test/flutter_test.dart';
import 'package:mitrapos/core/services/theme_provider.dart';

import 'package:mitrapos/main.dart';

void main() {
  testWidgets('MitraPOS app shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(MitraPOSApp(themeProvider: ThemeProvider()));

    expect(find.text('MitraPOS'), findsOneWidget);
    expect(find.text('Kasir modern dan manajemen inventaris cerdas'), findsOneWidget);
  });
}
