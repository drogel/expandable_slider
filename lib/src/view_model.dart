import 'dart:async';

import 'package:expandable_slider/src/states.dart';
import 'package:flutter/foundation.dart';

class ExpandableSliderViewModel {
  const ExpandableSliderViewModel({
    @required StreamController<SliderState> stateController,
  })  : assert(stateController != null),
        _stateController = stateController;

  final StreamController<SliderState> _stateController;

  Stream<SliderState> get stateStream => _stateController.stream;

  int computeDivisions(double min, double max, int step) => (max - min) ~/ step;

  void dispose() => _stateController.close();
}
