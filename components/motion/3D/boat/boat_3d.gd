## Recommended to set linear damp to 1 and angular damp to 2
class_name Boat3D extends RigidBody3D

signal started_engine
signal stopped_engine

@export var boat_mesh: MeshInstance3D
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
@export var boat_rudder_lerp_factor: float = 15.0

var current_engine_force: float = 0.0
var buoyancy_spots: Array[Node3D] = []

var engine_on: bool = false:
	set(value):
		if value != engine_on:
			engine_on = value
			
			if engine_on:
				started_engine.emit()
			else:
				current_engine_force = 0
				stopped_engine.emit()


func _ready() -> void:
	if buoyancy_root:
		buoyancy_spots.assign(buoyancy_root.get_children())


func _physics_process(delta: float) -> void:
	if engine_on:
		
		if Input.is_action_pressed(InputControls.VehicleAccelerate):
			if boat_acceleration > 0:
				current_engine_force = lerp(current_engine_force, boat_engine_force, boat_acceleration * delta)
			else:
				current_engine_force = boat_engine_force
			
			apply_central_force(global_transform.basis * (Vector3.FORWARD * current_engine_force) )
			
			if Input.is_action_pressed(InputControls.VehicleSteerLeft):
				apply_torque(Vector3.UP * boat_steering_force)
			
			if Input.is_action_pressed(InputControls.VehicleSteerRight):
				apply_torque(Vector3.DOWN * boat_steering_force)
				
		elif Input.is_action_pressed(InputControls.VehicleReverseAccelerate):
			if boat_acceleration > 0:
				current_engine_force = lerp(current_engine_force, boat_reverse_engine_force, boat_reverse_acceleration * delta)
			else:
				current_engine_force = boat_reverse_engine_force
				
			apply_central_force(global_transform.basis * (Vector3.BACK * current_engine_force) )
			
			if Input.is_action_pressed(InputControls.VehicleSteerLeft):
				apply_torque(Vector3.UP * boat_steering_force)
			
			if Input.is_action_pressed(InputControls.VehicleSteerRight):
				apply_torque(Vector3.DOWN * boat_steering_force)
	

	for buoyancy_spot: Node3D in buoyancy_spots:
		if buoyancy_spot.global_position.y <= water_level:
			apply_force(Vector3.UP * randf_range(buoyancy_force - buoyancy_force_variation, buoyancy_force) * -buoyancy_spot.global_position, buoyancy_spot.global_position - global_position)
