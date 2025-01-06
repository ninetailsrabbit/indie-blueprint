class_name Boid3D extends Node3D

@export var unit_scenes: Array[PackedScene] = []
@export var group: StringName = &""
@export var num_of_units: int = 20
@export var spawn_area_limits: Vector3 = Vector3(5, 5, 5)
@export var vertical_offset: float = -3.0
@export var min_scale: float = 1.0
@export var max_scale: float = 1.0


var units: Array[BoidUnit3D] = []


func _ready() -> void:
	assert(unit_scenes.size() > 0, "Boid3D: This boid need at least one unit scene assigned to spawn")
	
	for i in num_of_units:
		var spawn_position: Vector3 = Vector3(
			randf_range(-spawn_area_limits.x, spawn_area_limits.x),
			randf_range(-spawn_area_limits.y + vertical_offset, spawn_area_limits.y),
			randf_range(-spawn_area_limits.z, spawn_area_limits.z),
		)
		
		spawn_position.y = clampf(spawn_position.y, vertical_offset, spawn_area_limits.y)
		
		spawn_unit(spawn_position)
	
	await get_tree().physics_frame
	
	units.assign(get_tree().get_nodes_in_group(group)\
		.map(func(node: Node3D): 
			return node if node is BoidUnit3D else NodeTraversal.first_node_of_custom_class(node, BoidUnit3D))
			)


func spawn_unit(spawn_position: Vector3) -> void:
	if get_child_count() >= num_of_units:
		return
		
	var boid_scene: Node3D = unit_scenes[0].instantiate() if unit_scenes.size() == 1 else unit_scenes.pick_random().instantiate()
	NodeTraversal.first_node_of_custom_class(boid_scene, BoidUnit3D).boid = self
	
	add_child(boid_scene)
	boid_scene.add_to_group(group)
	boid_scene.position = spawn_position
	boid_scene.scale = randf_range(min_scale, max_scale) * Vector3.ONE
