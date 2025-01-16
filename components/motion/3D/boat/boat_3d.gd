## Recommended to set linear damp to 1 and angular damp to 2
class_name Boat3D extends RigidBody3D

const GroupName: StringName = &"boats"

signal started_engine
signal stopped_engine

@export var boat_mesh: Node3D
@export var water_level: float = 0.0
@export_category("Engine")
@export var boat_engine_force: float = 20.0
@export var boat_reverse_engine_force: float = 10.0
@export var boat_acceleration: float = 5.0
@export var boat_reverse_acceleration: float = 5.0
@export var boat_steering_force: float = 1.0
@export_category("Bouyancy")
@export var buoyancy_root: Node3D:
	set(value):
		if value != buoyancy_root:
			buoyancy_root = value
			
			if is_node_ready() and buoyancy_root:
				buoyancy_spots.assign(buoyancy_root.get_children())
@export var buoyancy_force: float = 20.0
@export var buoyancy_force_variation: float = 2.0
@export_category("Boat rudder")
@export var boat_rudder: Node3D
@export var boat_rudder_maximum_rotation: Vector3 = Vector3.ZERO
@export var boat_rudder_idle_rotation: Vector3 = Vector3.ZERO
@export var boat_rudder_lerp_factor: float = 5.0
@export var boat_rudder_idle_lerp_factor: float = 2.0

@onready var floatable_body_3d: FloatableBody3D = $FloatableBody3D


var motion_input: TransformedInput = TransformedInput.new(self)
var current_engine_force: float = 0.0
var buoyancy_spots: Array[Node3D] = []
var is_being_driven: bool = false
var engine_on: bool = false:
	set(value):
		if value != engine_on:
			engine_on = value
			
			if engine_on:
				started_engine.emit()
			else:
				current_engine_force = 0
				stopped_engine.emit()


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if buoyancy_root:
		buoyancy_spots.assign(buoyancy_root.get_children())


func start_engine() -> void:
	engine_on = true


func stop_engine() -> void:
	engine_on = false


func drive() -> void:
	is_being_driven = true
	
	
func stop_drive() -> void:
	is_being_driven = false
	

func _physics_process(delta: float) -> void:
	if engine_on and is_being_driven:
		if boat_rudder:
			motion_input.update()
			var steering_input: float = -motion_input.input_direction_horizontal_axis
			
			if is_zero_approx(steering_input):
				boat_rudder.rotation_degrees = boat_rudder.rotation_degrees.lerp(boat_rudder_idle_rotation, delta * boat_rudder_idle_lerp_factor)
			else:
				boat_rudder.rotation_degrees = boat_rudder.rotation_degrees.lerp(sign(steering_input) * boat_rudder_maximum_rotation, delta * boat_rudder_lerp_factor)
		
		if Input.is_action_pressed(InputControls.VehicleAccelerate):
			if boat_acceleration > 0:
				current_engine_force = lerp(current_engine_force, boat_engine_force, boat_acceleration * delta)
			else:
				current_engine_force = boat_engine_force
			
			apply_central_force(global_transform.basis * (Vector3.FORWARD * current_engine_force) )
		
		elif Input.is_action_pressed(InputControls.VehicleReverseAccelerate):
			if boat_acceleration > 0:
				current_engine_force = lerp(current_engine_force, boat_reverse_engine_force, boat_reverse_acceleration * delta)
			else:
				current_engine_force = boat_reverse_engine_force
				
			apply_central_force(global_transform.basis * (Vector3.BACK * current_engine_force) )
			
		if not is_zero_approx(current_engine_force):
			if Input.is_action_pressed(InputControls.VehicleSteerLeft):
				apply_torque(Vector3.UP * boat_steering_force)
			
			if Input.is_action_pressed(InputControls.VehicleSteerRight):
				apply_torque(Vector3.DOWN * boat_steering_force)
	else:
		if boat_rudder:
			boat_rudder.rotation_degrees = boat_rudder.rotation_degrees.lerp(boat_rudder_idle_rotation, delta * boat_rudder_idle_lerp_factor)
		
	#for buoyancy_spot: Node3D in buoyancy_spots:
		#if buoyancy_spot.global_position.y <= water_level:
			#apply_force(mass * Vector3.UP * randf_range(buoyancy_force - buoyancy_force_variation, buoyancy_force) * -buoyancy_spot.global_position, buoyancy_spot.global_position - global_position)
