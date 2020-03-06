import 'package:expandable_slider/expandable_slider.dart';
import 'package:flutter/material.dart';

class TestableExpandableSlider extends StatefulWidget {
  const TestableExpandableSlider({
    @required this.max,
    @required this.min,
    @required this.estimatedValueStep,
    Key key,
  }) : super(key: key);

  static const label = "label";
  static const slider = "slider";

  final double max;
  final double min;
  final double estimatedValueStep;

  @override
  _TestableExpandableSliderState createState() =>
      _TestableExpandableSliderState();
}

class _TestableExpandableSliderState extends State<TestableExpandableSlider> {
  double _value;

  @override
  void initState() {
    _value = widget.min;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            (_value).toStringAsFixed(0),
            key: Key(TestableExpandableSlider.label),
          ),
          ExpandableSlider(
            key: Key(TestableExpandableSlider.slider),
            value: _value,
            onChanged: _onChanged,
            min: widget.min,
            max: widget.max,
            estimatedValueStep: widget.estimatedValueStep,
          ),
        ],
      );

  void _onChanged(double newValue) => setState(() => _value = newValue);
}
