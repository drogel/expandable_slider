import 'package:flutter/foundation.dart';

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
}
