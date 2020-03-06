import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testable_expandable_slider.dart';

void main() {
  Future<void> init(
    tester, {
    @required double max,
    @required double min,
    @required double step,
  }) =>
      tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: MaterialApp(
            home: Scaffold(
              body: TestableExpandableSlider(
                max: max,
                min: min,
                estimatedValueStep: step,
              ),
            ),
          ),
        ),
      );

  final label = find.byKey(Key(TestableExpandableSlider.label));
  final slider = find.byKey(Key(TestableExpandableSlider.slider));

  group("Given a ExpandableSlider with an int associated value label", () {
    testWidgets("when loaded, then label and slider appear", (tester) async {
      await init(tester, max: 10, min: 0, step: 1);

      expect(label, findsOneWidget);
      expect(slider, findsOneWidget);
    });

    testWidgets("when touching the slider, then label changes", (tester) async {
      final min = 0.0;
      await init(tester, max: 10, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);
      await tester.tap(slider);
      await tester.pumpAndSettle();
      expect(find.text(min.toStringAsFixed(0)), findsNothing);
    });

    testWidgets("when sliding the slider, then label changes", (tester) async {
      final min = 0.0;
      final max = 10.0;
      await init(tester, max: max, min: min, step: 1);
      final sliderSize = tester.getSize(slider);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      // Tester starts sliding from middle of slider.
      await tester.drag(slider, Offset(sliderSize.width / max, 0));
      await tester.pumpAndSettle();
      expect(find.text(6.toStringAsFixed(0)), findsOneWidget);
    });

    testWidgets("when long-pressing the slider, label changes", (tester) async {
      final min = 0.0;
      await init(tester, max: 10, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      // Tester long-presses at middle of slider.
      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
    });

    testWidgets("when long-pressing the slider, it expands", (tester) async {
      final min = 0.0;
      final max = 10.0;
      await init(tester, max: max, min: min, step: 1);
      final sliderSize = tester.getSize(slider);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      // Tester has long-pressed at middle of slider.
      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);

      // Tester has long-pressed at middle of slider,
      // it takes more pixels to change value by 1.
      await tester.drag(slider, Offset(3 * sliderSize.width / max, 0));
      await tester.pumpAndSettle();
      expect(find.text(6.toStringAsFixed(0)), findsOneWidget);
    });

    testWidgets("when long-pressing the expanded slider, then it shrinks",
        (tester) async {
      final min = 0.0;
      final max = 10.0;
      await init(tester, max: max, min: min, step: 1);
      final sliderSize = tester.getSize(slider);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      // Tester has long-pressed at middle of slider.
      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
      await tester.longPress(slider);
      await tester.pumpAndSettle();

      // Tester has long-pressed at middle of slider,
      // it takes more pixels to change value by 1.
      await tester.drag(slider, Offset(sliderSize.width / max, 0));
      await tester.pumpAndSettle();
      expect(find.text(6.toStringAsFixed(0)), findsOneWidget);
    });
  });
}
