class_name FirstPersonWallJumpState extends FirstPersonWallState

@export var keep_momentum: bool = true
@export var wall_jump_vertical_force: float = 5.0
@export var wall_jump_horizontal_force: float = 4.0

var current_wall_normal: Vector3 = Vector3.ZERO
var last_jumped_position: Vector3 = Vector3.ZERO


func enter() -> void:
	apply_wall_jump()
	actor.move_and_slide()
	

func exit(_next_state: IndieBlueprintMachineState) -> void:
	current_wall_normal = Vector3.ZERO
	last_jumped_position = Vector3.ZERO


func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	detect_wall_jump()
	detect_fall(last_jumped_position)
	actor.move_and_slide()


func apply_wall_jump() -> void:
	if current_wall_normal.is_zero_approx():
		FSM.change_state_to(FirstPersonFallState)
		return
	
	if keep_momentum:
		actor.velocity = wall_jump_horizontal_force * current_wall_normal
		actor.velocity.y = wall_jump_vertical_force
	else:
		actor.velocity = wall_jump_horizontal_force * current_wall_normal
		actor.velocity.y = wall_jump_vertical_force
		
	last_jumped_position = actor.global_position
