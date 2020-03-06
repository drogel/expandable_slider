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
          body: const Example(max: 1000, min: 0),
        ),
      );
}

class Example extends StatefulWidget {
  const Example({@required this.max, @required this.min});

  final double max;
  final double min;

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
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
          Text("Current slider value:"),
          Text(
            (_value).toStringAsFixed(0),
            style: Theme.of(context).textTheme.display1,
          ),
          SizedBox(height: 32),
          ExpandableSlider(
            value: _value,
            onChanged: _onChanged,
            min: widget.min,
            max: widget.max,
            expandedEstimatedChangePerDivision: 25,
          ),
        ],
      );

  void _onChanged(double newValue) => setState(() => _value = newValue);
}
