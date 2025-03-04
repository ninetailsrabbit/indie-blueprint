class_name IndieBlueprintFollowComponent2D extends Node2D

signal enabled
signal disabled

@export var actor: Node2D
@export var target: Node2D:
	set(value):
		target = value
		active = target is Node2D and speed > 0
@export var distance_to_target: float = 25.0
@export var mode: FollowModes = FollowModes.Normal
@export var speed: float = 100.0:
	set(value):
		speed = max(0.0, absf(value))
		set_physics_process(active and speed > 0)
@export var rotation_speed: float = 1.0
@export_range(0, 360.0, 0.01, "degrees") var angle_offset: float = 0.0


enum FollowModes {
	Snake,
	ConstantSpeed,
	Normal
}

var offset: Vector2 = Vector2.ZERO
var target_rotation: float = 0.0
var target_position: Vector2 = Vector2.ZERO
var active: bool = false:
	set(value):
		if value != active:
			active = value
			
			if active:
				enabled.emit()
			else:
				disabled.emit()
		
		set_physics_process(active and speed > 0)


func _ready():
	if actor == null:
		actor = get_parent()
		
	assert(actor is Node2D, "IndieBlueprintFollowComponent2D: This component needs a valid Node2D actor to apply the follow behaviour")
	assert(target is Node2D, "IndieBlueprintFollowComponent2D: This component needs a valid Node2D to follow")
	
	set_physics_process(active and speed > 0)
	

func _physics_process(delta):
	update_target_parameters()
	
	if _global_distance_to_v2(actor, target) >= distance_to_target:
		if is_snake_mode():
			target_rotation = lerp(actor.global_rotation, target_rotation, delta * rotation_speed)
			target_position = lerp(global_position, target_position, delta * speed)

			actor.global_rotation = target_rotation
			actor.global_position = target_position

		elif is_constant_mode():
			offset = global_position.direction_to(target.global_position) * delta * speed
			actor.global_position += offset
			
		elif is_normal_mode():
			offset = Vector2.RIGHT.rotated(deg_to_rad(angle_offset)) * distance_to_target
			actor.global_position = lerp(global_position, target.global_position + offset, delta * speed)
		

func update_target_parameters():
	offset = -target.transform.x * distance_to_target
	target_rotation = global_position.direction_to(target.global_position).angle()
	target_position = target.global_position + offset


func enable():
	active = true
	

func disable():
	active = false

#region Modes
func change_to_snake_mode() -> void:
	mode = FollowModes.Snake


func change_to_constant_speed_mode() -> void:
	mode = FollowModes.ConstantSpeed


func change_to_normal_mode() -> void:
	mode = FollowModes.Normal


func is_snake_mode() -> bool:
	return mode == FollowModes.Snake
	
	
func is_constant_mode() -> bool:
	return mode == FollowModes.ConstantSpeed
	

func is_normal_mode() -> bool:
	return mode == FollowModes.Normal


func _global_distance_to_v2(a: Node2D, b: Node2D) -> float:
	return a.global_position.distance_to(b.global_position)

#endregion
