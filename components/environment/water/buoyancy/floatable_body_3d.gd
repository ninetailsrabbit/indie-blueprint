## Recommended settings: Mass: 4, Can sleep: false Linear damp: 4, Angular damp: 4
@icon("res://components/environment/water/buoyancy/floatable.svg")
class_name FloatableBody3D extends Node3D

const GroupName: StringName = &"floatable_bodies"

@export var body: RigidBody3D
@export var buoyancy_power: float = 1.0
@export var damper: float = 1.0
@export var archimedes_force: float = 20.0
@export var y_offset: float = -1.0
@export var min_max_rotation: Vector3 = Vector3.ONE
## Enable when the object is far away from the player
@export var fast_mode: bool = false
@export var buoyancy_points : Array[Node3D]

var is_enabled: bool = true


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if buoyancy_points.is_empty():
		for child in body.get_children().filter(func(child: Node): return child is Marker3D):
			buoyancy_points.append(child)
	
	assert(buoyancy_points.size() > 1, "FloatableBody3D: This node need at least 2 buoyancy points")


func enable() -> void:
	is_enabled = true


func disable() -> void:
	is_enabled = false


func apply_fast_mode_buoyancy(force: float) -> void:
	body.apply_central_force(Vector3.UP * force * buoyancy_power * buoyancy_points.size())


func apply_buoyancy(force: float, buoyancy_point: Marker3D) -> void:
	body.apply_force(Vector3.UP * force * buoyancy_power, (body.global_position - buoyancy_point.global_position))


func calculate_damping_force(factor_k: float) -> float:
	var local_damping_force : float = -body.linear_velocity.y * damper * body.mass
	var force : float = local_damping_force + sqrt(factor_k) * archimedes_force
	
	return force
	
	
func limit_rotation() -> void:
	var x: float = minf(abs(body.rotation.x), min_max_rotation.x) * sign(body.rotation.x)
	var y: float = minf(abs(body.rotation.y), min_max_rotation.y) * sign(body.rotation.y)
	var z: float = minf(abs(body.rotation.z), min_max_rotation.z) * sign(body.rotation.z)
	
	body.rotation = Vector3(x, y, z)
