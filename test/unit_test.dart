import 'package:expandable_slider/src/view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _kScrollingStep = 64.0;

void main() {
  ExpandableSliderViewModel viewModel;

  void runDivisionsTest(int expectedDivisions, double step) {
    final actual = viewModel.computeDivisions(step);
    expect(actual, expectedDivisions);
  }

  void runNormalizationTest(double expectedNormalizedValue, double value) {
    final actual = viewModel.normalize(value);
    expect(actual, expectedNormalizedValue);
  }

  void runSideScrollTest(
    double expectedScroll, {
    @required double newValue,
    @required double scrollPosition,
    @required double totalWidth,
    @required double shrunkWidth,
  }) {
    final actual = viewModel.computeSideScroll(
      newValue: newValue,
      scrollPosition: scrollPosition,
      totalWidth: totalWidth,
      shrunkWidth: shrunkWidth,
    );
    expect(actual, expectedScroll);
  }

  void runSnapCenterTest(
    double expectedScroll, {
    @required double shrunkWidth,
    @required double totalWidth,
    @required double newValue,
    @required double oldValue,
  }) {
    final actual = viewModel.computeSnapCenterScrollPosition(
      shrunkWidth: shrunkWidth,
      totalWidth: totalWidth,
      newValue: newValue,
      oldValue: oldValue,
    );
    expect(actual, expectedScroll);
  }

  group("Given a normalized ExpandableSliderViewModel", () {
    setUp(() => viewModel = const ExpandableSliderViewModel(min: 0, max: 1));
    tearDown(() => viewModel = null);

    group("when computeDivisions is called with exact number of divisions", () {
      test("then expected amount of divisions is retrieved", () {
        runDivisionsTest(10, 0.1);
        runDivisionsTest(25, 0.04);
        runDivisionsTest(20000, 0.00005);
      });
    });

    group("when computeDivisions is called with estimated divisions", () {
      test("then expected amount of divisions is retrieved", () {
        runDivisionsTest(10, 0.098);
        runDivisionsTest(24, 0.04002);
        runDivisionsTest(19999, 0.0000500004);
      });
    });

    group("when normalize is called", () {
      test("then expected normalized value is retrieved", () {
        runNormalizationTest(0.5, 0.5);
        runNormalizationTest(0.1, 0.1);
        runNormalizationTest(0.00333, 0.00333);
      });
    });

    group("when computeSideScroll is called with left scroll conditions", () {
      test("then expected amount of pixels to scroll is retrieved", () {
        runSideScrollTest(
          500.0 - _kScrollingStep,
          newValue: 0.54,
          scrollPosition: 500,
          totalWidth: 1000,
          shrunkWidth: 500,
        );
      });
    });

    group("when computeSideScroll is called with right scroll conditions", () {
      test("then expected amount of pixels to scroll is retrieved", () {
        runSideScrollTest(
          _kScrollingStep,
          newValue: 0.48,
          scrollPosition: 0,
          totalWidth: 1000,
          shrunkWidth: 500,
        );
      });
    });

    group("when computeSideScroll is called with no scroll conditions", () {
      test("then null is retrieved", () {
        runSideScrollTest(
          null,
          newValue: 0.25,
          scrollPosition: 0,
          totalWidth: 1000,
          shrunkWidth: 500,
        );
        runSideScrollTest(
          null,
          newValue: 0.75,
          scrollPosition: 500,
          totalWidth: 1000,
          shrunkWidth: 500,
        );
      });
    });

    group("when calling computeSnapCenterScrollPosition should snap", () {
      test("then expected amount of pixels to snap center is retrieved", () {
        // Value change is enough to trigger snap to center scrolling
        runSnapCenterTest(
          500,
          shrunkWidth: 500,
          totalWidth: 1000,
          newValue: 0.75,
          oldValue: 0.25,
        );
        runSnapCenterTest(
          650,
          shrunkWidth: 500,
          totalWidth: 1000,
          newValue: 0.9,
          oldValue: 0.2,
        );
      });
    });

    group("when calling computeSnapCenterScrollPosition shouldn't snap", () {
      test("then null is retrieved", () {
        // Value change is not enough to trigger snap to center scrolling
        runSnapCenterTest(
          null,
          shrunkWidth: 500,
          totalWidth: 1000,
          newValue: 0.75,
          oldValue: 0.4,
        );
        runSnapCenterTest(
          null,
          shrunkWidth: 500,
          totalWidth: 1000,
          newValue: 0.56,
          oldValue: 0.2,
        );
      });
    });
  });
}
