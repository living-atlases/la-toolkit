import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/fast_deploy_card.dart';

// The fast deploy card on the deploy page of a docker-compose portal: it
// says what it is and when to use Deploy instead, and why it is off.

void main() {
  Future<void> pump(WidgetTester tester, VoidCallback? onTap) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FastDeployCard(onTap: onTap)),
          ),
        ),
      );

  ElevatedButton button(WidgetTester tester) => tester.widget<ElevatedButton>(
    find.ancestor(
      of: find.text(FastDeployCard.title).last,
      matching: find.byWidgetPredicate((Widget w) => w is ElevatedButton),
    ),
  );

  testWidgets('says what it is, when to use Deploy, and launches', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await pump(tester, () => taps++);
    expect(find.text(FastDeployCard.summary), findsOneWidget);
    expect(find.text(FastDeployCard.useIt), findsOneWidget);
    expect(find.text(FastDeployCard.useDeploy), findsOneWidget);
    expect(find.text(FastDeployCard.unavailable), findsNothing);
    expect(button(tester).onPressed, isNotNull);
    await tester.tap(find.text(FastDeployCard.title).last);
    expect(taps, 1);
  });

  testWidgets('off with advanced options, and says why', (
    WidgetTester tester,
  ) async {
    await pump(tester, null);
    expect(button(tester).onPressed, isNull);
    expect(find.text(FastDeployCard.unavailable), findsOneWidget);
  });
}
