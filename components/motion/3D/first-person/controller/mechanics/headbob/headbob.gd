@icon("res://components/motion/3D/first-person/controller/mechanics/head.svg")
class_name HeadBob extends Node3D

@export var actor: FirstPersonController
@export var head: Node3D
@export var speed: float = 10.0
@export var intensity: float = 0.03
@export var lerp_speed = 5.0

var headbob_index: float = 0.0
var headbob_vector: Vector3 = Vector3.ZERO
var original_head_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	original_head_position = head.position
	

func _physics_process(delta: float) -> void:
	headbob_index += speed * delta
	
	if actor.is_grounded and not actor.motion_input.input_direction.is_zero_approx():
		headbob_vector = Vector3(sin(headbob_index / 2.0), sin(headbob_index), headbob_vector.z)
		
		head.position = Vector3(
			lerp(head.position.x, headbob_vector.x * intensity, delta * lerp_speed),
			lerp(head.position.y, headbob_vector.y * (intensity * 2), delta * lerp_speed),
			head.position.z
		)
		
	else:
		head.position = Vector3(
			lerp(head.position.x, original_head_position.x, delta * lerp_speed),
			lerp(head.position.y, original_head_position.y, delta * lerp_speed),
			head.position.z
		)


func lock() -> void:
	set_physics_process(false)
	

func unlock() -> void:
	set_physics_process(true)
