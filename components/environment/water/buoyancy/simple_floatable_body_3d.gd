## Recommended settings: Mass: 4, Can sleep: false Linear damp: 4, Angular damp: 4
@icon("res://components/environment/water/buoyancy/floatable.svg")
class_name SimpleFloatableBody3D extends Node3D

@export var water_manager : WaterManager
@export var body: RigidBody3D
@export var buoyancy_power: float = 4.0

var original_gravity_scale: float


func _ready() -> void:
	if body == null:
		body = get_parent()
	
	assert(body != null and body is RigidBody3D, "SimpleFloatableBody3D: This node needs a RigidBody3D")
	
	if water_manager == null:
		water_manager = get_tree().get_first_node_in_group(WaterManager.GroupName)
		
	assert(water_manager != null and water_manager is WaterManager, "FloatableBody3D: This node needs a water manager to access water height information to apply the floatability effect")
	
	original_gravity_scale = body.gravity_scale
	

func _physics_process(_delta: float) -> void:
	var water_height = water_manager.calculate_water_height(body.global_position)
	
	if body.global_position.y > water_height:
		body.gravity_scale = original_gravity_scale;
	else:
		body.gravity_scale = -buoyancy_power * (water_height - body.global_position.y)
