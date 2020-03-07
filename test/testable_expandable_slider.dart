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
  static const button = "button";

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
            _value.toStringAsFixed(0),
            key: const Key(TestableExpandableSlider.label),
          ),
          ExpandableSlider(
            key: const Key(TestableExpandableSlider.slider),
            value: _value,
            onChanged: _onChanged,
            min: widget.min,
            max: widget.max,
            estimatedValueStep: widget.estimatedValueStep,
          ),
          RaisedButton(
            key: const Key(TestableExpandableSlider.button),
            onPressed: () => _onChanged(widget.max / 2),
            child: const Text("Jump to half"),
          ),
        ],
      );

  void _onChanged(double newValue) => setState(() => _value = newValue);
}