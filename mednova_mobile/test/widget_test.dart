import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mednova_mobile/app.dart';

void main() {
  testWidgets('MedNova app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MedNovaApp(),
      ),
    );
    expect(find.textContaining('MedNova'), findsWidgets);
  });
}
