class_name UIAnimationOptions extends Resource

enum PivotOffset {
	Center,
	TopRight,
	TopLeft,
	BottomRight,
	BottomLeft
}

@export var pivot_offset: PivotOffset = PivotOffset.Center
@export var time: float = 0.3
@export var transition: Tween.TransitionType
@export var easing: Tween.EaseType
