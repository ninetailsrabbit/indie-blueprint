class_name IndieBlueprintDice extends RigidBody3D

signal roll_finished
signal rolled_value(value: int)
signal state_changed(from: States, to: States)

## The area collision layer on dice faces to detect the value
@export_range(1, 32, 1) var dice_face_collision_layer: int = 8
@export var dice_mesh: MeshInstance3D
@export var roll_strength: float = 2.0

enum States { Neutral, Hovered, Dragged, Rolling }

var original_position: Vector3
var current_state: States = States.Neutral:
	set(new_state):
		if new_state != current_state:
			## Avoid to Hover & Drag the dice when is rolling
			if current_state_is_dragged() and new_state == States.Hovered \
				or current_state_is_rolling() and new_state in [States.Dragged, States.Hovered]:
				return
			
			state_changed.emit(current_state, new_state)
			current_state = new_state

var is_rolling: bool = false:
	set(value):
		if is_rolling != value:
			if value == false and is_rolling == true:
				roll_finished.emit()
				
			is_rolling = value
			set_physics_process(is_rolling)
			
			if is_rolling:
				change_state_to_rolling()

var face_detector_raycast: RayCast3D


func _ready() -> void:
	_create_face_detector_raycast()
	roll_finished.connect(on_roll_finished)


func _physics_process(_delta: float) -> void:
	is_rolling = not linear_velocity.is_zero_approx()


func roll(direction: Vector3 = Vector3.ZERO, torque: bool = false) -> void:
	if is_rolling:
		return
	
	reset_forces()
	set_deferred("is_rolling", true)
	freeze = false
	
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, TAU)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, TAU)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, TAU)) * transform.basis

	var throw_vector: Vector3 = direction
	
	if throw_vector.is_zero_approx():
		throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	angular_velocity = throw_vector * roll_strength / 2.0
	apply_central_impulse(throw_vector * roll_strength)
	
	if torque:
		apply_torque_impulse(throw_vector * roll_strength / 2.0)


func reset_forces() -> void:
	sleeping = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func get_height() -> float:
	return (dice_mesh.global_transform * dice_mesh.get_aabb()).size.y


func get_face_value() -> int:
	face_detector_raycast.enabled = true
	face_detector_raycast.global_position = global_position
	face_detector_raycast.global_position += Vector3.UP * 0.6
	face_detector_raycast.target_position = Vector3.DOWN * 0.5
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var dice_face_area := face_detector_raycast.get_collider() as IndieBlueprintDiceFaceArea
	var value: int = dice_face_area.value if dice_face_area else 0
	face_detector_raycast.enabled = false
	
	rolled_value.emit(value)
	
	return value
	

#region States
func change_state_to_neutral() -> void:
	current_state = States.Neutral
	
	
func change_state_to_hovered() -> void:
	current_state = States.Hovered
	
	
func change_state_to_dragged() -> void:
	current_state = States.Dragged
	
		
func change_state_to_rolling() -> void:
	current_state = States.Rolling
	

func current_state_is_neutral() -> bool:
	return current_state == States.Neutral


func current_state_is_hovered() -> bool:
	return current_state == States.Hovered
	

func current_state_is_dragged() -> bool:
	return current_state == States.Dragged


func current_state_is_rolling() -> bool:
	return current_state == States.Rolling
#endregion


func _create_face_detector_raycast() -> void:
	if face_detector_raycast == null:
		face_detector_raycast = RayCast3D.new()
		face_detector_raycast.name = "%sFaceDetectorRayCast" % name
		face_detector_raycast.top_level = true
		face_detector_raycast.enabled = false
		face_detector_raycast.collide_with_bodies = false
		face_detector_raycast.collide_with_areas = true
		face_detector_raycast.collision_mask = IndieBlueprintRpgUtils.layer_to_value(dice_face_collision_layer)
		add_child.call_deferred(face_detector_raycast)


func on_roll_finished() -> void:
	get_face_value()
	change_state_to_neutral()
