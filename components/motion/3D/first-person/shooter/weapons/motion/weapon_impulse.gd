class_name WeaponImpulse extends FireArmWeaponMotion

#@export var actor: FirstPersonController
@export var camera: bool = false

@export var jump_kick: float = 0.02
@export var jump_kick_power: float = 20.0
@export var jump_rotation: Vector2 = Vector2(0.1, 0.02)
@export var jump_rotation_power: float = 5.0
@export_group("Multipliers")
@export var multiplier_on_jump: float = 1.0
@export var multiplier_on_jump_after_run: float = 1.5
@export var multiplier_on_land: float = 1.0
@export var multiplier_on_land_after_run: float = 1.5
@export var multiplier_on_crouch: float = 0.5

var current_kick: Vector3 = Vector3.ZERO
var current_rotation: Vector3 = Vector3.ZERO


func _physics_process(delta):
	#var current_state: MachineState = actor.finite_state_machine.current_state
	#var previous_state: MachineState = actor.finite_state_machine.last_state()
	#var next_to_previous_state: MachineState = actor.finite_state_machine.next_to_last_state()
	#
	current_kick = current_kick.lerp(Vector3.ZERO, delta * jump_kick_power)
	current_rotation = current_rotation.lerp(Vector3.ZERO, delta * jump_rotation_power)

	position = lerp(position, current_kick, delta * jump_kick_power)
	rotation = lerp(rotation, current_rotation, delta * jump_rotation_power)

	#if current_state is Jump:
		#if previous_state is Run:
			#apply_jump_kick(multiplier_on_jump_after_run)
		#else:
			#apply_jump_kick(multiplier_on_jump)
	#
	#elif previous_state is AirState and current_state is GroundState:
		#if next_to_previous_state is Run:
			#apply_land_kick(multiplier_on_land_after_run)
		#else:
			#apply_land_kick(multiplier_on_land)
		#
	#elif current_state is Crouch or (previous_state is Crouch and (current_state is Idle or current_state is Walk)):
		#apply_jump_kick(multiplier_on_crouch)
		
	
func apply_jump_kick(multiplier):
	current_rotation = Vector3(jump_rotation.x * multiplier, jump_rotation.y * multiplier, 0.0)
	current_kick = Vector3(0.0, jump_kick * multiplier, 0.0)
	
	if camera:
		current_rotation.x *= -1


func apply_land_kick(multiplier):
	current_rotation = Vector3(-jump_rotation.x * multiplier, jump_rotation.y * multiplier, 0.0)
	current_kick = Vector3(0.0, -jump_kick * multiplier, 0.0)
	
	if camera:
		current_rotation.x *= -1
