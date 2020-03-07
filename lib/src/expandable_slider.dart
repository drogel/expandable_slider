import 'package:expandable_slider/src/view_model.dart';

import 'durations.dart' as durations;
import 'curves.dart' as curves;
import 'package:flutter/material.dart';

class ExpandableSlider extends StatefulWidget {
  const ExpandableSlider({
    @required this.value,
    @required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.estimatedValueStep = 1,
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
    this.scrollBehavior = const ScrollBehavior(),
    Key key,
  })  : assert(value != null),
        assert(estimatedValueStep != null,
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
  final double estimatedValueStep;
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
  final ScrollBehavior scrollBehavior;

  @override
  _ExpandableSliderState createState() => _ExpandableSliderState();
}

class _ExpandableSliderState extends State<ExpandableSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  ExpandableSliderViewModel _viewModel;
  AnimationController _expansion;
  Animation<double> _expansionAnimation;
  AnimationStatus _previousExpansionStatus;
  double _expansionFocalValue;
  double _shrunkWidth;
  double _expandedExtraWidth;
  int _divisions;

  bool get _isExpanded => _expansion.status == AnimationStatus.completed;

  bool get _isShrunk => _expansion.status == AnimationStatus.dismissed;

  double get _totalWidth => _shrunkWidth + _expandedExtraWidth;

  bool get _wasForwarding =>
      _expansion.status == AnimationStatus.forward ||
      (_isExpanded && _previousExpansionStatus == AnimationStatus.forward);

  @override
  void initState() {
    _viewModel = ExpandableSliderViewModel(min: widget.min, max: widget.max);
    _setUpExpansionAnimation();
    _scroll.addListener(_updateExpansionFocalValue);
    _updateExpansionFocalValue();
    _divisions = _viewModel.computeDivisions(
      widget.estimatedValueStep,
    );
    _expandedExtraWidth = _viewModel.computeExtraWidth(_divisions);
    super.initState();
  }

  @override
  void didUpdateWidget(ExpandableSlider oldWidget) {
    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      _viewModel = ExpandableSliderViewModel(min: widget.min, max: widget.max);
    }
    if (oldWidget.value != widget.value && _isShrunk) {
      _updateExpansionFocalValue();
    }
    _shouldSnapCenter(widget.value, oldWidget.value);
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
                behavior: widget.scrollBehavior,
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
    _viewModel = null;
    super.dispose();
  }

  void _expand() => _expansion.forward();

  void _shrink() => _expansion.reverse();

  void _toggleExpansionScale(ScaleUpdateDetails details) {
    if (details.horizontalScale > 1) {
      _expand();
    } else if (details.horizontalScale < 1) {
      _shrink();
    }
  }

  void _toggleExpansion() => _isExpanded ? _shrink() : _expand();

  void _onChanged(double newValue) {
    _shouldSideScroll(newValue);
    widget.onChanged(newValue);
  }

  void _updateExpansionFocalValue() {
    if (_isExpanded) {
      _expansionFocalValue = _scroll.position.pixels;
    } else if (_isShrunk) {
      _expansionFocalValue = _viewModel.normalize(widget.value);
    }
  }

  void _shouldSnapCenter(double newValue, double oldValue) {
    if (!_isExpanded) return;
    final snapCenterScrollPosition = _viewModel.computeSnapCenterScrollPosition(
      shrunkWidth: _shrunkWidth,
      totalWidth: _totalWidth,
      newValue: newValue,
      oldValue: oldValue,
    );

    if (snapCenterScrollPosition == null) return;
    final normalizedValue = _viewModel.normalize(newValue);
    final newCenterPosition = normalizedValue * _totalWidth - _shrunkWidth / 2;
    _scroll.animateTo(
      newCenterPosition,
      duration: widget.snapCenterScrollDuration,
      curve: widget.snapCenterScrollCurve,
    );
  }

  void _shouldSideScroll(double newValue) {
    if (!_isExpanded) return;
    final sideScroll = _viewModel.computeSideScroll(
      newValue: newValue,
      scrollPosition: _scroll.position.pixels,
      totalWidth: _totalWidth,
      shrunkWidth: _shrunkWidth,
    );

    if (sideScroll == null) return;
    _scroll.animateTo(
      sideScroll,
      duration: widget.sideScrollDuration,
      curve: widget.sideScrollCurve,
    );
  }

  void _updateExpansionTransition() {
    final expansionValue = _expansionAnimation.value;
    final addedWidth = expansionValue * _expandedExtraWidth;
    if (_wasForwarding) {
      setState(() => _scroll.jumpTo(_expansionFocalValue * addedWidth));
    } else {
      setState(() => _scroll.jumpTo(_expansionFocalValue * expansionValue));
    }
    _previousExpansionStatus = _expansion.status;
  }

  void _setUpExpansionAnimation() {
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
    _previousExpansionStatus = _expansion.status;
  }
}
