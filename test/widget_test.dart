import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boba_score/main.dart';


void main() {
  testWidgets('BobaScore home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BobaScoreApp()));

    expect(find.text('BobaScore'), findsNWidgets(2));
    expect(
      find.text('Your personal boba shop rankings are coming soon.'),
      findsOneWidget,
    );
  });
}
