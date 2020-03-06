import 'package:expandable_slider/src/view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExpandableSliderViewModel viewModel;

  group("Given a normalized ExpandableSliderViewModel", () {
    setUp(() {
      viewModel = ExpandableSliderViewModel(min: 0, max: 1);
    });

    tearDown(() {
      viewModel = null;
    });

    group("when computeDivisions is called with exact number of divisions", () {
      void runDivisionsTest(int expectedDivisions, double step) {
        final actual = viewModel.computeDivisions(step);
        expect(actual, expectedDivisions);
      }

      test("then expected amount of divisions is retrieved", () {
        runDivisionsTest(10, 0.1);
        runDivisionsTest(25, 0.04);
        runDivisionsTest(20000, 0.00005);
      });
    });

    group("when computeDivisions is called with estimated divisions", () {
      void runDivisionsTest(int expectedDivisions, double step) {
        final actual = viewModel.computeDivisions(step);
        expect(actual, expectedDivisions);
      }

      test("then expected amount of divisions is retrieved", () {
        runDivisionsTest(10, 0.098);
        runDivisionsTest(24, 0.04002);
        runDivisionsTest(19999, 0.0000500004);
      });
    });

    group("when normalize is called", () {
      void runNormalizationTest(double expectedNormalizedValue, double value) {
        final actual = viewModel.normalize(value);
        expect(actual, expectedNormalizedValue);
      }

      test("then expected normalized value is retrieved", () {
        runNormalizationTest(0.5, 0.5);
        runNormalizationTest(0.1, 0.1);
        runNormalizationTest(0.00333, 0.00333);
      });
    });
  });
}
