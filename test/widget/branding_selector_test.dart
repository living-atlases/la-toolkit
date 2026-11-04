import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/branding_selector.dart';

// The theme picker of the branding step: material is gone from base-branding,
// and a project saved with it opens on clean (what base-branding builds it as)
// instead of throwing.

void main() {
  Future<void> pump(WidgetTester tester, String initial) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BrandingSelector(initialValue: initial, onChange: (_) {}),
          ),
        ),
      ),
    );
  }

  testWidgets('material is no longer offered', (WidgetTester tester) async {
    await pump(tester, 'clean');
    expect(tester.takeException(), isNull);
    expect(find.text('clean'), findsWidgets);
    expect(find.text('material'), findsNothing);
  });

  testWidgets('a project saved with material opens on clean', (
    WidgetTester tester,
  ) async {
    await pump(tester, 'material');
    expect(tester.takeException(), isNull);
    expect(find.text('clean'), findsWidgets);
  });
}
