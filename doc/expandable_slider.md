# expandable_slider library documentation

## ExpandableSlider class

A slider that can be expanded to select values with more precision.

This widget is based on Flutter's `Slider` widget.

An expandable slider can have two status: "shrunk" and "expanded". An
`ExpandableSlider` will always be a discrete `Slider`, i.e., a `Slider`
with non-null `Slider.divisions`.

When shrunk, the default behavior will be that of a Flutter's `Slider`,
that is, both the `min` and `max` values of the slider are visible and
reachable by the slider thumb. Depending on the `estimatedValueStep` and
`shrunkWidth` properties, a shrunk expandable slider can either have
visible or invisible divisions: the divisions will be visible if the
`ExpandableSlider` has enough room to present the divisions, and the
divisions will be invisible otherwise.

An expanded `ExpandableSlider` will always have visible divisions, and the
spacing between divisions will always be enough for the user to move the
slider thumb between divisions easily. On the other hand, the `min` and
`max` values of the slider might not be visible when the slider is expanded.
If, while expanded, the slider thumb tries to exit the viewport, an
animation will be triggered to move the viewport such that the slider thumb
becomes visible again. This animation can be either:

  * A "snap center" animation, which is a scrolling animation that occurs
  when the slider is expanded and the `value` changes in such a way that
  would cause the slider thumb to travel as many pixels as 0.875 times the
  width of the viewport. This animation causes the slider thumb to return
  to the center of the viewport.
  * A "side scroll" animation, which is a scrolling animation that occurs
  when the slider is expanded and the `value` changes in such a way that
  would cause the slider thumb to exit the viewport, but not by travelling
  as many pixels as 0.875 times the width of the viewport. This animation
  does not cause the slider thumb to return to the center of the viewport.

Just like with `Slider`, the visual appearance can be finely tuned with
`SliderTheme` and `SliderThemeData`.

### Constructors

```dart
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
  });
```

Creates a Material Design slider that can be expanded to select values
with more precision.

```dart
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
  });
```

Creates an `ExpandableSlider` that takes the appearance of a
`CupertinoSlider` if the target platform is iOS, or that of a Material
Design slider otherwise.

If a `CupertinoSlider` is created, `inactiveColor` is ignored.

### Properties

#### value (`double`)

The currently selected value for this slider.

The slider's thumb is drawn at a position that corresponds to this value.

#### onChanged (`void Function(double)`)

Called during a drag when the user is selecting a new value.

#### onChangeStart (`void Function(double)`)

Called when the user starts selecting a new value for the slider.

#### onChangeEnd (`void Function(double)`)

Called when the user is done selecting a new value for the slider.

#### onExpansionStart (`void Function()`)

Called when the slider starts an expansion animation.

#### onShrinkageStart (`void Function()`)

Called when the slider starts a shrinkage animation.

#### estimatedValueStep (`double`)

The estimated value change when the slider thumb jumps between divisions.

The divisions that this `ExpandableSlider` have are computed based on this
value, as the truncated division between (`max` - `min`) and this value.
It is preferred to set this value such that (`max` - `min`) is divisible
by this value, so that every jump between divisions always implies the
same change in the slider's `value`.

For example, if `max` == 11, `min` == 0, and `estimatedValueStep` == 2,
some jumps between divisions will imply a change in `value` of 2, and some
of them will imply a change in `value` of 3. On the other hand, if
`max` == 10, `min` == 0, and `estimatedValueStep` == 2, all jumps between
divisions will imply a change in `value` of 2, since (10 - 0) % 2 == 0.

#### activeColor (`Color`)

The color to use for the portion of the slider track that is active.
  
The "active" side of the slider is the side between the thumb and the
minimum value.
  
Defaults to the active track color of the current `SliderTheme`.
  
#### inactiveColor (`Color`)

The color for the inactive portion of the slider track.
  
The "inactive" side of the slider is the side between the thumb and the
maximum value.
  
Defaults to the inactive track color of the current `SliderTheme`.
  
#### min (`double`)

The minimum value the user can select.
  
Defaults to 0.0. Must be less than or equal to `max`.
  
If the `max` is equal to the `min`, then the slider is disabled.
  
#### max (`double`)

The maximum value the user can select.
  
Defaults to 1.0. Must be greater than or equal to `min`.
  
If the `max` is equal to the `min`, then the slider is disabled.

#### shrunkWidth (`double`)

If non-null, requires the slider to have exactly this width when shrunk.
  
If null, the shrunk slider will try to occupy as much space as possible.

#### expansionDuration (`Duration`)

The length of time the slider expansion animation animation should last.
  
If `shrinkageDuration` is specified, then `expansionDuration` is only
used when expanding. However, if `shrinkageDuration` is null, it
specifies the duration for both the shrinkage and the expansion animation.
  
Defaults to 250 milliseconds.

#### shrinkageDuration (`Duration`)

The length of time the shrinkage animation should last.
  
The value of `expansionDuration` us used if `shrinkageDuration` is set to
null.
  
Defaults to 200 milliseconds.

#### snapCenterScrollDuration (`Duration`)

The duration of the scrolling animation that occurs when the slider is
expanded and the `value` changes in such a way that would cause the slider
thumb to travel as many pixels as 0.875 times the width of the viewport.
  
Must not be zero. Defaults to 450 milliseconds.

#### sideScrollDuration (`Duration`)

The duration of the scrolling animation that occurs when the slider is
expanded and the `value` changes in such a way that would cause the slider
thumb to exit the viewport, but not by travelling as many pixels as
0.875 times the width of the viewport.
  
Must not be zero. Defaults to 150 milliseconds.

#### expansionCurve (`Curve`)

The curve to use in the expansion animation.
  
If `shrinkageCurve` is null, this curve will also be used in the shrinkage
animation.
  
Defaults to Cubic(0.4, 0, 1, 1).

#### shrinkageCurve (`Curve`)

The curve to use in the shrinkage animation.
  
If null, `expansionCurve` will be used in the shrinkage animation instead.
  
Defaults to Cubic(0, 0, 0.2, 1).

#### snapCenterScrollCurve (`Curve`)

The curve to use in the scrolling animation that occurs when the slider
is expanded and the `value` changes in such a way that would cause
the slider to travel as many pixels as 0.875 times the width of the
viewport.
  
Defaults to `Curves.fastOutSlowIn`.

#### sideScrollCurve (`Curve`)

The curve to use in the scrolling animation that occurs when the slider is
expanded and the `value` changes in such a way that would cause the slider
thumb to exit the viewport, but not by travelling as many pixels as
0.875 times the width of the viewport.
  
Defaults to `Curves.fastOutSlowIn`.

#### expandsOnLongPress (`bool`)

Whether to expand or shrink the slider when performing a long press on it.
  
Defaults to true.

#### expandsOnScale (`bool`)

Whether to expand or shrink the slider when performing a scale gesture on
it.
  
Defaults to true.

#### expandsOnDoubleTap (`bool`)

Whether to expand or shrink the slider when performing a double tap on it.
  
Defaults to false.

#### scrollBehavior (`ScrollBehavior`)

How the `ScrollView` that wraps the slider should behave.
  
Defaults to `ScrollBehavior`.

#### controller (`ExpandableSliderController`)

An object that can be used to control the animations of the slider.

## ExpandableSliderController class

A controller for an `ExpandableSlider`.

This class lets you expand or shrink the expandable slider.

### Constructors

```dart
ExpandableSliderController();
```

Creates an object that controls the animations of an `ExpandableSlider`.

### Properties

#### isExpanded (`bool`)

Returns true if the `ExpandableSlider` is expanded, and false otherwise.

### Methods

#### expand (`void Function()`)

Starts running the expansion animation forwards.

#### shrink (`void Function()`)

Starts running the shrinkage animation forwards.