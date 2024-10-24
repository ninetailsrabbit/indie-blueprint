class_name Crawl extends GroundState


func enter():
	actor.animation_player.play(crawl_animation)


func exit(_next_state: MachineState):
	actor.animation_player.play_backwards(crawl_animation)
	await actor.animation_player.animation_finished


func physics_update(delta):
	super.physics_update(delta)
	
	if not Input.is_action_pressed(crawl_input_action) and not actor.ceil_shape_cast.is_colliding():
		FSM.change_state_to("Crouch")
		
	accelerate(delta)
		
	actor.move_and_slide()


func _crouch_animation() -> void:
	var previous_state = FSM.last_state()
	
	if not previous_state is Slide and not previous_state is Crawl:
		actor.animation_player.play(crouch_animation)
		await actor.animation_player.animation_finished


func _reset_crouch_animation(next_state: MachineState) -> void:
	if actor.animation_player and not next_state is Crawl:
		actor.anmation_player.play_backwards(crouch_animation)
		await actor.animation_player.animation_finished
	
