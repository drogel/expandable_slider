import 'package:expandable_slider/src/injector.dart' as injector;
import 'package:expandable_slider/src/view_model.dart';

import 'no_glow_behavior.dart';
import 'durations.dart' as durations;
import 'curves.dart' as curves;
import 'package:flutter/material.dart';

const _kSideScrollTriggerFactor = 0.085;
const _kSnapTriggerWidthFactor = 0.875;
const _kScrollingStep = 64;

class ExpandableSlider extends StatefulWidget {
  const ExpandableSlider({
    @required this.value,
    @required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.expandedEstimatedChangePerDivision = 1,
    this.shrunkWidth,
    this.inactiveColor,
    this.activeColor,
    this.min = 0,
    this.max = 1,
    this.expansionDuration = durations.mediumPresenting,
    this.shrinkingDuration = durations.mediumDismissing,
    this.snapCenterScrollDuration = durations.longPresenting,
    this.sideScrollDuration = durations.shortPresenting,
    this.expansionCurve = curves.exiting,
    this.shrinkingCurve = curves.entering,
    this.snapCenterScrollCurve = curves.main,
    this.sideScrollCurve = curves.main,
    this.expandsOnLongPress = true,
    this.expandsOnScale = true,
    this.expandsOnDoubleTap = false,
    Key key,
  })  : assert(value != null),
        assert(expandedEstimatedChangePerDivision != null,
            "This value can't be null, it's needed to calculate divisions"),
        assert(min != null),
        assert(max != null),
        assert(expansionDuration != null),
        assert(shrinkingDuration != null),
        assert(snapCenterScrollDuration != null),
        assert(sideScrollDuration != null),
        assert(expansionCurve != null),
        assert(snapCenterScrollCurve != null),
        assert(sideScrollCurve != null),
        assert(expandsOnLongPress != null),
        assert(expandsOnScale != null),
        assert(expandsOnDoubleTap != null),
        super(key: key);

  final double value;
  final void Function(double) onChanged;
  final void Function(double) onChangeStart;
  final void Function(double) onChangeEnd;
  final int expandedEstimatedChangePerDivision;
  final Color activeColor;
  final Color inactiveColor;
  final double min;
  final double max;
  final double shrunkWidth;
  final Duration expansionDuration;
  final Duration shrinkingDuration;
  final Duration snapCenterScrollDuration;
  final Duration sideScrollDuration;
  final Curve expansionCurve;
  final Curve shrinkingCurve;
  final Curve snapCenterScrollCurve;
  final Curve sideScrollCurve;
  final bool expandsOnLongPress;
  final bool expandsOnScale;
  final bool expandsOnDoubleTap;

  @override
  _ExpandableSliderState createState() => _ExpandableSliderState();
}

class _ExpandableSliderState extends State<ExpandableSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  ExpandableSliderViewModel _viewModel;
  AnimationController _expansion;
  Animation<double> _expansionAnimation;
  AnimationStatus _previousStatus;
  double _expansionFocalValue;
  double _shrunkWidth;
  double _expandedExtraWidth;
  int _divisions;

  bool get _isExpanded => _expansion.status == AnimationStatus.completed;

  bool get _isShrunk => _expansion.status == AnimationStatus.dismissed;

  double get _totalWidth => _shrunkWidth + _expandedExtraWidth;

  bool get _hasFinishedForwarding =>
      _expansion.status == AnimationStatus.forward ||
      (_isExpanded && _previousStatus == AnimationStatus.forward);

  @override
  void initState() {
    _viewModel = injector.injectViewModel();
    _expansion = AnimationController(
      vsync: this,
      duration: widget.expansionDuration,
      reverseDuration: widget.shrinkingDuration,
    );
    _expansionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expansion,
        curve: widget.expansionCurve,
        reverseCurve: widget.shrinkingCurve,
      ),
    );
    _expansionAnimation.addListener(_updateExpansionTransition);
    _expansionAnimation.addStatusListener((_) => _updateExpansionFocalValue());
    _scroll.addListener(_updateExpansionFocalValue);
    _previousStatus = _expansion.status;
    _updateExpansionFocalValue();
    _divisions = _viewModel.computeDivisions(
      widget.min,
      widget.max,
      widget.expandedEstimatedChangePerDivision,
    );
    _expandedExtraWidth = _computeExtraWidth(_divisions);
    super.initState();
  }

  @override
  void didUpdateWidget(ExpandableSlider oldWidget) {
    final normalizedValue = _normalize(widget.value);
    final normalizedOld = _normalize(oldWidget.value);
    final valueChange = (normalizedOld - normalizedValue).abs() * _totalWidth;
    _shouldSnapCenterScroll(normalizedValue, valueChange);
    if (oldWidget.value != widget.value && _isShrunk) {
      _updateExpansionFocalValue();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          _shrunkWidth = widget.shrunkWidth ?? constraints.maxWidth;
          return GestureDetector(
            onScaleUpdate: widget.expandsOnScale ? _toggleExpansionScale : null,
            onLongPress: widget.expandsOnLongPress ? _toggleExpansion : null,
            onDoubleTap: widget.expandsOnDoubleTap ? _toggleExpansion : null,
            child: LayoutBuilder(
              builder: (_, constraints) => ScrollConfiguration(
                behavior: const NoGlowBehavior(),
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: _shrunkWidth +
                        _expansionAnimation.value * _expandedExtraWidth,
                    child: Slider(
                      value: widget.value,
                      activeColor: widget.activeColor,
                      inactiveColor: widget.inactiveColor,
                      onChanged: _onChanged,
                      onChangeStart: widget.onChangeStart,
                      onChangeEnd: widget.onChangeEnd,
                      max: widget.max,
                      min: widget.min,
                      divisions: _divisions,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  @override
  void dispose() {
    _expansion.dispose();
    super.dispose();
  }

  double _computeExtraWidth(int divisions) => divisions * _kScrollingStep / 2;

  double _normalize(double value) =>
      (value - widget.min) / (widget.max - widget.min);

  void _onChanged(double newValue) {
    _shouldSideScroll(newValue);
    widget.onChanged(newValue);
  }

  void _updateExpansionFocalValue() {
    if (_isExpanded) {
      _expansionFocalValue = _scroll.position.pixels;
    } else if (_isShrunk) {
      _expansionFocalValue = _normalize(widget.value);
    }
  }

  void _shouldSnapCenterScroll(double newNormalizedValue, double valueChange) {
    if (valueChange > _shrunkWidth * _kSnapTriggerWidthFactor && _isExpanded) {
      _scroll.animateTo(
        newNormalizedValue * _totalWidth - _shrunkWidth / 2,
        duration: widget.snapCenterScrollDuration,
        curve: widget.snapCenterScrollCurve,
      );
    }
  }

  void _shouldSideScroll(double newValue) {
    final min = 0;
    final max = 1;
    final normalizedValue = _normalize(newValue);
    if (_isExpanded) {
      final scrollPosition = _scroll.position.pixels;
      final normalizedScreenMin = scrollPosition / _totalWidth;
      final normalizedScreenMax = (scrollPosition + _shrunkWidth) / _totalWidth;
      final valueChangeInScreen = normalizedScreenMax - normalizedScreenMin;
      final minDiff = (normalizedScreenMin - min).clamp(min, max);
      final maxDiff = (max - normalizedScreenMax).clamp(min, max);
      final scrollTriggerDiff = valueChangeInScreen * _kSideScrollTriggerFactor;
      if (minDiff + scrollTriggerDiff + min > normalizedValue) {
        _scroll.animateTo(
          scrollPosition - _kScrollingStep,
          duration: widget.sideScrollDuration,
          curve: widget.sideScrollCurve,
        );
      } else if (max - maxDiff - scrollTriggerDiff < normalizedValue) {
        _scroll.animateTo(
          scrollPosition + _kScrollingStep,
          duration: widget.sideScrollDuration,
          curve: widget.sideScrollCurve,
        );
      }
    }
  }

  void _toggleExpansionScale(ScaleUpdateDetails details) {
    if (details.horizontalScale > 1 && _isShrunk) {
      _expand();
    } else if (details.horizontalScale < 1 && _isExpanded) {
      _shrink();
    }
  }

  void _toggleExpansion() => _isExpanded ? _shrink() : _expand();

  void _updateExpansionTransition() {
    final expansionValue = _expansionAnimation.value;
    final addedWidth = expansionValue * _expandedExtraWidth;
    if (_hasFinishedForwarding) {
      setState(() => _scroll.jumpTo(_expansionFocalValue * addedWidth));
    } else {
      setState(() => _scroll.jumpTo(_expansionFocalValue * expansionValue));
    }
    _previousStatus = _expansion.status;
  }

  void _expand() => _expansion.forward();

  void _shrink() => _expansion.reverse();
}
