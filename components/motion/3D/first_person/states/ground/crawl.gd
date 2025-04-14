class_name FirstPersonCrawlState extends FirstPersonGroundState

@export_range(0.0, 1.0, 0.01, "percent") var crawl_percent: float = 0.75
@export var crawl_animation_time: float = 0.2

var crawl_tween: Tween


func enter() -> void:
	crawl_tween = create_tween()
	crawl_tween.tween_property(actor.head, "position:y", actor.original_head_position.y * (1.0 - crawl_percent), crawl_animation_time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func physics_update(delta):
	super.physics_update(delta)
	
	if crawl_tween == null or (crawl_tween and not crawl_tween.is_running()):
		if not Input.is_action_pressed(crawl_input_action) and not actor.ceil_shape_cast.is_colliding():
			FSM.change_state_to(FirstPersonCrouchState)
				
	accelerate(delta)

	stair_step_up()
	actor.move_and_slide()
	stair_step_down()
