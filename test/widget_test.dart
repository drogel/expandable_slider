import 'dart:ui';

import 'package:expandable_slider/expandable_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testable_expandable_slider.dart';

void main() {
  runTests(adaptive: true);
  runTests(adaptive: false);
}

void runTests({@required bool adaptive}) {
  Future<void> init(
    tester, {
    @required double max,
    @required double min,
    @required double step,
    ExpandableSliderController controller,
  }) =>
      tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: TestableExpandableSlider(
                max: max,
                min: min,
                estimatedValueStep: step,
                adaptive: adaptive,
                controller: controller,
              ),
            ),
          ),
        ),
      );

  const min = 0.0;
  const max = 10.0;

  final label = find.byKey(const Key(TestableExpandableSlider.label));
  final slider = find.byKey(const Key(TestableExpandableSlider.slider));
  final button = find.byKey(const Key(TestableExpandableSlider.button));

  Future<void> expectShrunkSlider(WidgetTester tester, double max) async {
    // Tester starts sliding from middle of slider.
    final sliderSize = tester.getSize(slider);
    await tester.drag(slider, Offset(sliderSize.width / max, 0));
    await tester.pumpAndSettle();
    expect(find.text(6.toStringAsFixed(0)), findsOneWidget);
  }

  Future<void> expectExpandedSlider(WidgetTester tester, double max) async {
    // Tester has long-pressed at middle of slider,
    // it takes more pixels to change value by 1.
    final sliderSize = tester.getSize(slider);
    await tester.drag(slider, Offset(3 * sliderSize.width / max, 0));
    await tester.pumpAndSettle();
    expect(find.text(6.toStringAsFixed(0)), findsOneWidget);
  }

  group("Given a ExpandableSlider with an int associated value label", () {
    testWidgets("when loaded, then label and slider appear", (tester) async {
      await init(tester, max: max, min: min, step: 1);

      expect(label, findsOneWidget);
      expect(slider, findsOneWidget);
    });

    testWidgets("when touching the slider, then label changes", (tester) async {
      await init(tester, max: 10, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);
      await tester.tap(slider);
      await tester.pumpAndSettle();
      expect(find.text(min.toStringAsFixed(0)), findsNothing);
    });

    testWidgets("when sliding the slider, then label changes", (tester) async {
      await init(tester, max: max, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);
      await expectShrunkSlider(tester, max);
    });

    testWidgets("when long-pressing the slider, label changes", (tester) async {
      await init(tester, max: 10, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      // Tester long-presses at middle of slider.
      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
    });

    testWidgets("when long-pressing the slider, it expands", (tester) async {
      await init(tester, max: max, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
      await expectExpandedSlider(tester, max);
    });

    testWidgets("when long-pressing the expanded slider, then it shrinks",
        (tester) async {
      await init(tester, max: max, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      await tester.longPress(slider);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
      await tester.longPress(slider);
      await tester.pumpAndSettle();
      await expectShrunkSlider(tester, max);
    });

    testWidgets("when jumping to half value when shrunk, slider keeps shrunk",
        (tester) async {
      await init(tester, max: max, min: min, step: 1);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text(5.toStringAsFixed(0)), findsOneWidget);
      await expectShrunkSlider(tester, max);
    });

    testWidgets("when jumping to half value when expanded, slider updates",
        (tester) async {
      await init(tester, max: max, min: min, step: 1);
      final sliderOrigin = tester.getTopLeft(slider);

      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      await tester.longPressAt(sliderOrigin);
      await tester.pumpAndSettle();
      expect(find.text(min.toStringAsFixed(0)), findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text((max / 2).toStringAsFixed(0)), findsOneWidget);
      await expectExpandedSlider(tester, max);
    });
  });

  group("Given a ExpandableSlider with an ExpandableSliderController", () {
    final controller = ExpandableSliderController();

    testWidgets("when controller calls expand, slider expands", (tester) async {
      await init(tester, max: max, min: min, step: 1, controller: controller);

      controller.expand();
      await tester.pumpAndSettle();
      await expectExpandedSlider(tester, max);
    });

    testWidgets("when controller calls shrink, slider shrinks", (tester) async {
      await init(tester, max: max, min: min, step: 1, controller: controller);

      // Long pressing the slider to expand it
      await tester.longPress(slider);
      await tester.pumpAndSettle();

      controller.shrink();
      await tester.pumpAndSettle();
      await expectShrunkSlider(tester, max);
    });

    testWidgets("isExpanded returns false initially", (tester) async {
      await init(tester, max: max, min: min, step: 1, controller: controller);

      expect(controller.isExpanded, false);
    });

    testWidgets("when slider expands, isExpanded returns true", (tester) async {
      await init(tester, max: max, min: min, step: 1, controller: controller);

      // Long pressing the slider to expand it
      await tester.longPress(slider);
      await tester.pumpAndSettle();

      expect(controller.isExpanded, true);
    });

    testWidgets("when slider shrinks, isExpanded is false", (tester) async {
      await init(tester, max: max, min: min, step: 1, controller: controller);

      // Long pressing the slider to expand it
      await tester.longPress(slider);
      await tester.pumpAndSettle();

      // Long pressing the slider to shrink it
      await tester.longPress(slider);
      await tester.pumpAndSettle();

      expect(controller.isExpanded, false);
    });
  });
}
