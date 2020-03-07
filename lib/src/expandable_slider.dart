import 'package:expandable_slider/src/view_model.dart';
import 'package:expandable_slider/src/durations.dart' as durations;
import 'package:expandable_slider/src/curves.dart' as curves;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum _SliderType { material, adaptive }

/// A slider that can be expanded to select values with more precision.
///
/// This widget is based on Flutter's [Slider] widget.
class ExpandableSlider extends StatefulWidget {
  /// Creates a Material Design slider that can be expanded to select values
  /// with more precision.
  ///
  /// See also:
  ///   * [Slider], which is a widget used to select from a range of values.
  const ExpandableSlider({
    @required this.value,
    @required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.onExpansionStart,
    this.onShrinkingStart,
    this.estimatedValueStep = 1,
    this.shrunkWidth,
    this.inactiveColor,
    this.activeColor,
    this.min = 0,
    this.max = 1,
    this.expansionDuration = durations.mediumPresenting,
    this.shrinkageDuration = durations.mediumDismissing,
    this.snapCenterScrollDuration = durations.longPresenting,
    this.sideScrollDuration = durations.shortPresenting,
    this.expansionCurve = curves.exiting,
    this.shrinkageCurve = curves.entering,
    this.snapCenterScrollCurve = curves.main,
    this.sideScrollCurve = curves.main,
    this.expandsOnLongPress = true,
    this.expandsOnScale = true,
    this.expandsOnDoubleTap = false,
    this.scrollBehavior = const ScrollBehavior(),
    Key key,
  })  : _sliderType = _SliderType.material,
        assert(estimatedValueStep != null,
            "Needed to calculate the slider's divisions"),
        super(key: key);

  /// Creates an [ExpandableSlider] that takes the appearance of a
  /// [CupertinoSlider] if the target platform is iOS, or that of a Material
  /// Design slider otherwise.
  ///
  /// If a [CupertinoSlider] is created, [inactiveColor] is ignored.
  ///
  /// See also:
  ///   * [Slider.adaptive], which creates a slider that adapts its appearance
  ///   to the target platform.
  const ExpandableSlider.adaptive({
    @required this.value,
    @required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.onExpansionStart,
    this.onShrinkingStart,
    this.estimatedValueStep = 1,
    this.shrunkWidth,
    this.inactiveColor,
    this.activeColor,
    this.min = 0,
    this.max = 1,
    this.expansionDuration = durations.mediumPresenting,
    this.shrinkageDuration = durations.mediumDismissing,
    this.snapCenterScrollDuration = durations.longPresenting,
    this.sideScrollDuration = durations.shortPresenting,
    this.expansionCurve = curves.exiting,
    this.shrinkageCurve = curves.entering,
    this.snapCenterScrollCurve = curves.main,
    this.sideScrollCurve = curves.main,
    this.expandsOnLongPress = true,
    this.expandsOnScale = true,
    this.expandsOnDoubleTap = false,
    this.scrollBehavior = const ScrollBehavior(),
    Key key,
  })  : _sliderType = _SliderType.adaptive,
        assert(estimatedValueStep != null,
            "Needed to calculate the slider's divisions"),
        super(key: key);

  /// The currently selected value for this slider.
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  /// Called during a drag when the user is selecting a new value.
  final void Function(double) onChanged;

  /// Called when the user starts selecting a new value for the slider.
  final void Function(double) onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  final void Function(double) onChangeEnd;

  /// Called when the slider starts an expansion animation.
  final void Function() onExpansionStart;

  /// Called when the slider starts a shrinking animation.
  final void Function() onShrinkingStart;

  /// The estimated value change when the slider thumb jumps between divisions.
  ///
  /// The divisions that this [ExpandableSlider] have are computed based on this
  /// value, as the truncated division between ([max] - [min]) and this value.
  /// It is preferred to set this value such that ([max] - [min]) is divisible
  /// by this value, so that every jump between divisions always implies the
  /// same change in the slider's [value].
  ///
  /// For example, if [max] == 11, [min] == 0, and [estimatedValueStep] == 2,
  /// some jumps between divisions will imply a change in [value] of 2, and some
  /// of them will imply a change in [value] of 3.
  final double estimatedValueStep;

  /// The color to use for the portion of the slider track that is active.
  ///
  /// The "active" side of the slider is the side between the thumb and the
  /// minimum value.
  final Color activeColor;

  /// The color for the inactive portion of the slider track.
  ///
  /// The "inactive" side of the slider is the side between the thumb and the
  /// maximum value.
  final Color inactiveColor;

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double min;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double max;

  /// If non-null, requires the slider to have exactly this width when shrunk.
  ///
  /// If null, the shrunk slider will try to occupy as much space as possible.
  final double shrunkWidth;

  /// The length of time the slider expansion animation animation should last.
  ///
  /// If [shrinkageDuration] is specified, then [expansionDuration] is only
  /// used when expanding. However, if [shrinkageDuration] is null, it
  /// specifies the duration for both the shrinkage and the expansion animation.
  final Duration expansionDuration;

  /// The length of time the shrinkage animation should last.
  ///
  /// The value of [expansionDuration] us used if [shrinkageDuration] is set to
  /// null.
  final Duration shrinkageDuration;

  /// The duration of the scrolling animation that occurs when the slider is
  /// expanded and the [value] changes in such a way that would cause the slider
  /// thumb to travel as many pixels as 0.875 times the width of the viewport.
  ///
  /// Must not be zero.
  final Duration snapCenterScrollDuration;

  /// The duration of the scrolling animation that occurs when the slider is
  /// expanded and the [value] changes in such a way that would cause the slider
  /// thumb to exit the viewport, but not by travelling as many pixels as
  /// 0.875 times the width of the viewport.
  ///
  /// Must not be zero.
  final Duration sideScrollDuration;

  /// The curve to use in the expansion animation.
  ///
  /// If [shrinkageCurve] is null, this curve will also be used in the shrinkage
  /// animation.
  final Curve expansionCurve;

  /// The curve to use in the shrinkage animation.
  ///
  /// If null, [expansionCurve] will be used in the shrinkage animation instead.
  final Curve shrinkageCurve;

  /// The curve to use in the scrolling animation that occurs when the slider
  /// is expanded and the [value] changes in such a way that would cause
  /// the slider to travel as many pixels as 0.875 times the width of the
  /// viewport.
  final Curve snapCenterScrollCurve;

  /// The curve to use in the scrolling animation that occurs when the slider is
  /// expanded and the [value] changes in such a way that would cause the slider
  /// thumb to exit the viewport, but not by travelling as many pixels as
  /// 0.875 times the width of the viewport.
  final Curve sideScrollCurve;

  /// Whether to expand or shrink the slider when performing a long press on it.
  ///
  /// Defaults to true.
  final bool expandsOnLongPress;

  /// Whether to expand or shrink the slider when performing a scale gesture on
  /// it.
  ///
  /// Defaults to true.
  final bool expandsOnScale;

  /// Whether to expand or shrink the slider when performing a double tap on it.
  ///
  /// Defaults to false.
  final bool expandsOnDoubleTap;

  /// How the [ScrollView] that wraps the slider should behave.
  final ScrollBehavior scrollBehavior;

  final _SliderType _sliderType;

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
    if (oldWidget.value != widget.value) {
      _shouldSnapCenter(widget.value, oldWidget.value);
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
                behavior: widget.scrollBehavior,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: _shrunkWidth +
                        _expansionAnimation.value * _expandedExtraWidth,
                    child: _buildSlider(),
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

  Widget _buildSlider() {
    switch (widget._sliderType) {
      case _SliderType.material:
        return Slider(
          value: widget.value,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          onChanged: _onChanged,
          onChangeStart: widget.onChangeStart,
          onChangeEnd: widget.onChangeEnd,
          max: widget.max,
          min: widget.min,
          divisions: _divisions,
        );
      case _SliderType.adaptive:
        return Slider.adaptive(
          value: widget.value,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          onChanged: _onChanged,
          onChangeStart: widget.onChangeStart,
          onChangeEnd: widget.onChangeEnd,
          max: widget.max,
          min: widget.min,
          divisions: _divisions,
        );
    }
    return null;
  }

  void _expand() {
    if (widget.onExpansionStart != null) widget.onExpansionStart();
    _expansion.forward();
    HapticFeedback.mediumImpact();
  }

  void _shrink() {
    if (widget.onShrinkingStart != null) widget.onShrinkingStart();
    _expansion.reverse();
    HapticFeedback.mediumImpact();
  }

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
      reverseDuration: widget.shrinkageDuration,
    );
    _expansionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expansion,
        curve: widget.expansionCurve,
        reverseCurve: widget.shrinkageCurve,
      ),
    );
    _expansionAnimation.addListener(_updateExpansionTransition);
    _expansionAnimation.addStatusListener((_) => _updateExpansionFocalValue());
    _previousExpansionStatus = _expansion.status;
  }
}
