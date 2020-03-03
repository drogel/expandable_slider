import 'package:expandable_slider/expandable_slider.dart';
import 'package:flutter/material.dart';

void main() => runApp(ExpandableSliderExampleApp());

class ExpandableSliderExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Expandable slider example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Expandable slider sample app"),
          ),
          body: const Example(1000),
        ),
      );
}

class Example extends StatefulWidget {
  const Example(this._maxValue);

  final double _maxValue;

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  double _value = 0;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Slider value multiplied by ${widget._maxValue.toInt()}:"),
          Text(
            (widget._maxValue * _value).toStringAsFixed(0),
            style: Theme.of(context).textTheme.display1,
          ),
          SizedBox(height: 32),
          ExpandableSlider(
            value: _value,
            onChanged: _onChanged,
          ),
        ],
      );

  void _onChanged(double newValue) => setState(() => _value = newValue);
}
