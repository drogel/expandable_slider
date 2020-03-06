import 'package:flutter/foundation.dart';

const _kScrollingStep = 64;
const _kSideScrollTriggerFactor = 0.085;
const _kSnapTriggerWidthFactor = 0.875;

class ExpandableSliderViewModel {
  const ExpandableSliderViewModel({@required double min, @required double max})
      : assert(min != null),
        assert(max != null),
        _min = min,
        _max = max;

  final double _min;
  final double _max;

  int computeDivisions(int step) => (_max - _min) ~/ step;

  double normalize(double value) => (value - _min) / (_max - _min);

  double computeExtraWidth(int divisions) => divisions * _kScrollingStep / 2;

  double computeSideScroll({
    @required double newValue,
    @required double scrollPosition,
    @required double totalWidth,
    @required double shrunkWidth,
  }) {
    final min = 0;
    final max = 1;
    final normalizedValue = normalize(newValue);
    final normalizedScreenMin = scrollPosition / totalWidth;
    final normalizedScreenMax = (scrollPosition + shrunkWidth) / totalWidth;
    final valueChangeInScreen = normalizedScreenMax - normalizedScreenMin;
    final minDiff = (normalizedScreenMin - min).clamp(min, max);
    final maxDiff = (max - normalizedScreenMax).clamp(min, max);
    final scrollTriggerDiff = valueChangeInScreen * _kSideScrollTriggerFactor;

    if (minDiff + scrollTriggerDiff + min > normalizedValue) {
      return scrollPosition - _kScrollingStep;
    } else if (max - maxDiff - scrollTriggerDiff < normalizedValue) {
      return scrollPosition + _kScrollingStep;
    } else {
      return null;
    }
  }

  double computeSnapCenterScrollPosition({
    @required double shrunkWidth,
    @required double totalWidth,
    @required double newValue,
    @required double oldValue,
  }) {
    final normalizedValue = normalize(newValue);
    final normalizedOld = normalize(oldValue);
    final valueChange = (normalizedOld - normalizedValue).abs() * totalWidth;
    if (valueChange > shrunkWidth * _kSnapTriggerWidthFactor) {
      return normalizedValue * totalWidth - shrunkWidth / 2;
    } else {
      return null;
    }
  }
}
