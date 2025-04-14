class_name FirstPersonIdleState extends FirstPersonGroundState


#func enter() -> void:
	#var current_weapon: FireArmWeapon = actor.current_weapon()
	#
	#if current_weapon:
		#current_weapon.weapon_mesh.idle_animation()


#func exit(_next_state: IndieBlueprintMachineState) -> void:
	#var current_weapon: FireArmWeapon = actor.current_weapon()
	#
	#if current_weapon:
		#current_weapon.weapon_mesh.animation_player.stop()


func physics_update(delta):
	super.physics_update(delta)
	
	decelerate(delta)
	
	if not actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to(FirstPersonWalkState)
	
	detect_jump()
	detect_crouch()
	
	actor.move_and_slide()
