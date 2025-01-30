class_name LadderClimb extends SpecialState

## When automatic ladder detection is enabled, we give a cooldown time to not get stuck 
## on the ladder when released
@export var dismount_jump_amount: float = 3.5
@export var cooldown_time: float = 1.5

var current_ladder: Ladder3D
var cooldown_timer: Timer


func handle_input(_event: InputEvent) -> void:
	if current_ladder and current_ladder.press_to_release and Input.is_action_just_pressed(current_ladder.input_action_to_climb_ladder):
		current_ladder = null
		FSM.change_state_to(Fall)


func ready() -> void:
	_create_cooldown_timer()


func enter() -> void:
	## This is necessary so that handle input is not thrown at the moment before enter() is called.
	await get_tree().physics_frame
	current_ladder = actor.ladder_cast_detector.get_collider(0).get_parent()
	
	if current_ladder == null:
		FSM.change_state_to(Fall)
		
	actor.velocity = Vector3.ZERO
		

func exit(_next_state: MachineState) -> void:
	if current_ladder and not current_ladder.press_to_climb and is_instance_valid(cooldown_timer):
		cooldown_timer.start(cooldown_time)
		
	current_ladder = null


func physics_update(delta: float) -> void:
	if actor.is_on_floor() or current_ladder == null:
		FSM.change_state_to(Fall)
		return
	
	var position_relative_to_ladder: Vector3 = current_ladder.global_transform.affine_inverse() * actor.global_position
	var climb_direction: float = actor.motion_input.input_direction_vertical_axis

	actor.velocity.y = lerp(actor.velocity.y, -climb_direction * speed, delta * acceleration)
	
	var actor_height_reference: float = actor.stand_collision_shape.shape.height / 2.0
	var is_above_top_of_ladder: bool = position_relative_to_ladder.y > current_ladder.top_of_ladder.position.y - actor_height_reference
	
	if is_above_top_of_ladder:
		actor.velocity = Vector3(0, dismount_jump_amount + actor.stand_collision_shape.shape.height, 0)
		actor.velocity += actor.global_transform.basis.z * dismount_jump_amount
		current_ladder = null
		
	actor.move_and_slide()
	
	detect_jump()
	detect_swim()
	
	
func _create_cooldown_timer():
	if cooldown_timer == null:
		cooldown_timer = TimeHelper.create_physics_timer(cooldown_time, false, true)
		cooldown_timer.name = "LadderClimbCooldownTimer"
		add_child(cooldown_timer)
