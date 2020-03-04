import 'no_glow_behavior.dart';
import 'durations.dart' as durations;
import 'curves.dart' as curves;
import 'package:flutter/material.dart';

const _kExpandedAddedWidth = 6000;
const _kExpandedDivisions = 255;
const _kExpandedScrollingFactor = 1.02;
const _kScrollTriggerFactor = 0.86;
const _kScrollingStep = 40;

class ExpandableSlider extends StatefulWidget {
  const ExpandableSlider({
    @required this.value,
    @required this.onChanged,
    this.shrunkWidth,
    this.expansionDuration = durations.mediumPresenting,
    this.shrinkingDuration = durations.mediumDismissing,
    this.curve = curves.main,
    this.inactiveColor,
    this.activeColor,
    this.min = 0,
    this.max = 1,
    Key key,
  })  : assert(value != null),
        assert(min != null),
        assert(max != null),
        super(key: key);

  final double value;
  final void Function(double) onChanged;
  final double shrunkWidth;
  final Duration expansionDuration;
  final Duration shrinkingDuration;
  final Color activeColor;
  final Color inactiveColor;
  final double min;
  final double max;
  final Curve curve;

  @override
  _ExpandableSliderState createState() => _ExpandableSliderState();
}

class _ExpandableSliderState extends State<ExpandableSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();

  AnimationController _expansion;
  Animation<double> _expansionAnimation;
  AnimationStatus _previousStatus;
  double _expansionFocalValue;
  double _shrunkWidth;

  @override
  void initState() {
    _expansion = AnimationController(
      vsync: this,
      duration: widget.expansionDuration,
      reverseDuration: widget.shrinkingDuration,
    );
    _expansionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expansion,
        curve: curves.exiting,
        reverseCurve: curves.incoming,
      ),
    );
    _expansionAnimation.addListener(_updateExpansionTransition);
    _expansionAnimation.addStatusListener((_) => _updateExpansionFocalValue());
    _scroll.addListener(_updateExpansionFocalValue);
    _previousStatus = _expansion.status;
    _updateExpansionFocalValue();
    super.initState();
  }

  @override
  void didUpdateWidget(ExpandableSlider oldWidget) {
    final normalizedValue = _normalize(widget.value);
    final normalizedOld = _normalize(oldWidget.value);
    final change = (normalizedOld - normalizedValue).abs() * _totalWidth;
    if (change > _shrunkWidth * _kScrollTriggerFactor && _isExpanded) {
      _scroll.animateTo(
        normalizedValue * _totalWidth - _shrunkWidth / 2,
        duration: durations.largePresenting,
        curve: curves.main,
      );
    }
    if (oldWidget.value != widget.value && _isShrunk) {
      _updateExpansionFocalValue();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        _shrunkWidth = widget.shrunkWidth ?? constraints.maxWidth;
        return GestureDetector(
          onScaleUpdate: _toggleExpansionOnScale,
          onLongPress: _toggleExpansionOnPress,
          child: LayoutBuilder(
            builder: (_, constraints) => ScrollConfiguration(
              behavior: const NoGlowBehavior(),
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: _shrunkWidth +
                      _expansionAnimation.value * _kExpandedAddedWidth,
                  child: Slider(
                    value: widget.value,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    onChanged: _onChanged,
                    max: widget.max,
                    min: widget.min,
                    divisions: _kExpandedDivisions,
                  ),
                ),
              ),
            ),
          ),
        );
      });

  @override
  void dispose() {
    _expansion.dispose();
    super.dispose();
  }

  bool get _isExpanded => _expansion.status == AnimationStatus.completed;

  bool get _isShrunk => _expansion.status == AnimationStatus.dismissed;

  double get _totalWidth => _shrunkWidth + _kExpandedAddedWidth;

  bool get _isCompleteForwarding =>
      _expansion.status == AnimationStatus.forward ||
      (_isExpanded && _previousStatus == AnimationStatus.forward);

  double _normalize(double value) =>
      (value - widget.min) / (widget.max - widget.min);

  void _onChanged(double newValue) {
    _shouldScroll(newValue);
    widget.onChanged(newValue);
  }

  void _updateExpansionFocalValue() {
    if (_isExpanded) {
      _expansionFocalValue = _scroll.position.pixels;
    } else if (_isShrunk) {
      _expansionFocalValue = _normalize(widget.value);
    }
  }

  void _shouldScroll(double newValue) {
    final min = _normalize(widget.min);
    final max = _normalize(widget.max);
    final normalizedValue = _normalize(newValue);
    if (_isExpanded) {
      final scrollPosition = _scroll.position.pixels;
      final screenMin = scrollPosition / _totalWidth;
      final screenMax = (scrollPosition + _shrunkWidth) / _totalWidth;
      final minDiff = (screenMin - min).clamp(min, max);
      final maxDiff = (max - screenMax).clamp(min, max);
      if (minDiff * _kExpandedScrollingFactor + min > normalizedValue) {
        _scroll.animateTo(
          scrollPosition - _kScrollingStep,
          duration: durations.smallPresenting,
          curve: curves.main,
        );
      } else if (max - maxDiff * _kExpandedScrollingFactor < normalizedValue) {
        _scroll.animateTo(
          scrollPosition + _kScrollingStep,
          duration: durations.smallPresenting,
          curve: curves.main,
        );
      }
    }
  }

  void _toggleExpansionOnScale(ScaleUpdateDetails details) {
    if (details.horizontalScale > 1 && _isShrunk) {
      _expand();
    } else if (details.horizontalScale < 1 && _isExpanded) {
      _shrink();
    }
  }

  void _toggleExpansionOnPress() => _isExpanded ? _shrink() : _expand();

  void _updateExpansionTransition() {
    final expansionValue = _expansionAnimation.value;
    final addedWidth = expansionValue * _kExpandedAddedWidth;
    if (_isCompleteForwarding) {
      setState(() => _scroll.jumpTo(_expansionFocalValue * addedWidth));
    } else {
      setState(() => _scroll.jumpTo(_expansionFocalValue * expansionValue));
    }
    _previousStatus = _expansion.status;
  }

  void _expand() => _expansion.forward();

  void _shrink() => _expansion.reverse();
}
