class_name WeaponBob extends FireArmWeaponMotion


#@export var actor: FirstPersonController
@export var noise: FastNoiseLite
@export var headbob_intensity: float = 0.005
@export var headbob_lerp_speed: float = 5.0
@export var headbob_index_lerp_speed: float = 10.0
@export var	target_frequency: float = 1.0
@export var	target_amplitude: float = 0.04
@export var	target_lerp_speed: float = 2.0

var weapon_noise_offset = Vector3.ZERO
var weapon_noise = Vector3.ZERO

var final_frequency: float = 0.0
var final_amplitude: float = 0.0

var headbob_index: float = 0.0
var headbob_vector = Vector2.ZERO

var arm_multiplier: float = 1.0

var original_position: Vector3 = Vector3.ZERO

var current_headbob_intensity: float = headbob_intensity
var current_headbob_index_lerp_speed: float = headbob_lerp_speed
var current_target_frequency: float = target_frequency
var current_target_amplitude: float = target_amplitude
var current_target_lerp_speed: float = target_lerp_speed


func _ready() -> void:
	original_position = position
	
	#actor.get_node("FiniteStateMachine").state_changed.connect(on_actor_state_changed)


#func _physics_process(delta: float) -> void:
	#if not actor.velocity.length() <= 0.2 and actor.is_grounded:
		#headbob_index += current_headbob_index_lerp_speed * delta
#
		#headbob_vector.x = sin(headbob_index / 2)
		#headbob_vector.y = sin(headbob_index)
		#
		#position.x = lerp(position.x, headbob_vector.x * current_headbob_intensity, delta * headbob_lerp_speed)
		#position.y = lerp(position.y, headbob_vector.y * (current_headbob_intensity * 2), delta * headbob_lerp_speed)
		#
		#final_frequency = lerpf(final_frequency, current_target_frequency * arm_multiplier, delta * current_target_lerp_speed)
		#final_amplitude = lerpf(final_amplitude, current_target_amplitude * arm_multiplier, delta * current_target_lerp_speed)
#
		#var weaponScrollOffset: float = delta * final_frequency
		#
		#weapon_noise_offset += Vector3.ONE * weaponScrollOffset
	#
		#weapon_noise.x = noise.get_noise_2d(weapon_noise_offset.x, 0.0)
		#weapon_noise.y = noise.get_noise_2d(weapon_noise_offset.y, 1.0)
		#weapon_noise.z = noise.get_noise_2d(weapon_noise_offset.z, 2.0)
#
		#weapon_noise *= final_amplitude
		#
		#rotation = weapon_noise
	#else:
		#position.y = lerp(position.y, original_position.y, headbob_lerp_speed * delta)
		#position.x = lerp(position.x, original_position.x, headbob_lerp_speed * delta)


func return_to_default_values() -> void:
	current_headbob_intensity = headbob_intensity
	current_headbob_index_lerp_speed = headbob_lerp_speed
	current_target_frequency = target_frequency
	current_target_amplitude = target_amplitude
	current_target_lerp_speed = target_lerp_speed

#
#func on_actor_state_changed(from: MachineState, to: MachineState) -> void:
	#if to is GroundState:
		### Intensity and headbox index changes when aiming or not
		#if actor.is_aiming():
			#
			#if not to is Crouch and not to is Run:
				#current_headbob_intensity = 0.004
				#current_headbob_index_lerp_speed = 10.0
			#elif to is Crouch:
				#current_headbob_intensity = 0.005
				#current_headbob_index_lerp_speed = 8.0
			#elif to is Run:
				#current_headbob_intensity = 0.01
				#current_headbob_index_lerp_speed = 15.0
		#else:
			#if to is Walk:
				#current_headbob_intensity = 0.005
				#current_headbob_index_lerp_speed = 10.0
			#elif to is Crouch:
				#current_headbob_intensity = 0.005
				#current_headbob_index_lerp_speed = 8.0
			#elif to is Run:
				#current_headbob_intensity = 0.01
				#current_headbob_index_lerp_speed = 15.0
		#
		### Normal frequency amplitude to use in bob depending on the current actor state
		#if to is Idle:
			#current_target_frequency = 0.2
			#current_target_amplitude = 0.05
			#current_target_lerp_speed = 2.0
		#elif to is Walk:
			#current_target_frequency = 1.0
			#current_target_amplitude = 0.04
			#current_target_lerp_speed = 2.0
		#elif to is Run:
			#current_target_frequency = 1.0
			#current_target_amplitude = 0.08
			#current_target_lerp_speed = 2.0
		#elif to is Crouch:
			#current_target_frequency = 1.0
			#current_target_amplitude = 0.05
			#current_target_lerp_speed = 2.0
