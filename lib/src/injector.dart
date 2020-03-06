import 'dart:async';

import 'package:expandable_slider/src/states.dart';
import 'package:expandable_slider/src/view_model.dart';

ExpandableSliderViewModel injectViewModel() => ExpandableSliderViewModel(
      stateController: StreamController<SliderState>(),
    );
