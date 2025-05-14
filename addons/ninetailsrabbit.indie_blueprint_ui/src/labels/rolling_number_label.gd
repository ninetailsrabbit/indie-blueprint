class_name RollingNumberLabel extends RichTextLabel

signal started
signal ended

@export var time: float = 2.0
@export var delay: float = 0.05
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var tween_transition: Tween.TransitionType = Tween.TRANS_LINEAR

var tween: Tween

## Display callback allow custom outputs for the rich text label text
func roll(from: int, to: int, display_callback: Callable = set_number) -> void:
	if _tween_can_be_created():
		started.emit()
		
		tween = create_tween()\
			.set_ease(tween_ease)\
			.set_trans(tween_transition)
		
		tween.tween_method(display_callback, from, to, time).set_delay(delay)
		tween.finished.connect(func(): ended.emit(), CONNECT_ONE_SHOT)
		

func pause() -> void:
	if tween and tween.is_running():
		tween.pause()


func play() -> void:
	if tween:
		tween.play()


func set_number(value: int) -> void:
	text = str(value)


func _tween_can_be_created() -> bool:
	return tween == null or (tween != null and not tween.is_running())
