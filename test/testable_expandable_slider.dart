import 'package:expandable_slider/expandable_slider.dart';
import 'package:flutter/material.dart';

class TestableExpandableSlider extends StatefulWidget {
  const TestableExpandableSlider({
    required this.max,
    required this.min,
    required this.estimatedValueStep,
    this.adaptive = false,
    this.controller,
    Key? key,
  }) : super(key: key);

  static const label = "label";
  static const slider = "slider";
  static const button = "button";

  final double max;
  final double min;
  final double estimatedValueStep;
  final bool adaptive;
  final ExpandableSliderController? controller;

  @override
  _TestableExpandableSliderState createState() =>
      _TestableExpandableSliderState();
}

class _TestableExpandableSliderState extends State<TestableExpandableSlider> {
  late double _value;

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
          _buildSlider(),
          ElevatedButton(
            key: const Key(TestableExpandableSlider.button),
            onPressed: () => _onChanged(widget.max / 2),
            child: const Text("Jump to half"),
          ),
        ],
      );

  void _onChanged(double newValue) => setState(() => _value = newValue);

  Widget _buildSlider() => widget.adaptive
      ? ExpandableSlider.adaptive(
          key: const Key(TestableExpandableSlider.slider),
          value: _value,
          onChanged: _onChanged,
          min: widget.min,
          max: widget.max,
          estimatedValueStep: widget.estimatedValueStep,
          controller: widget.controller,
        )
      : ExpandableSlider(
          key: const Key(TestableExpandableSlider.slider),
          value: _value,
          onChanged: _onChanged,
          min: widget.min,
          max: widget.max,
          estimatedValueStep: widget.estimatedValueStep,
          controller: widget.controller,
        );
}
