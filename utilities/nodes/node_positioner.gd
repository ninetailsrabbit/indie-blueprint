class_name NodePositioner


static func global_direction_to_v2(a: Node2D, b: Node2D) -> Vector2:
	return a.global_position.direction_to(b.global_position)


static func local_direction_to_v2(a: Node2D, b: Node2D) -> Vector2:
	return a.position.direction_to(b.position)


static func global_distance_to_v2(a: Node2D, b: Node2D) -> float:
	return a.global_position.distance_to(b.global_position)


static func local_distance_to_v2(a: Node2D, b: Node2D) -> float:
	return a.position.distance_to(b.position)
	
	
static func global_direction_to_v3(a: Node3D, b: Node3D) -> Vector3:
	return a.global_position.direction_to(b.global_position)


static func local_direction_to_v3(a: Node3D, b: Node3D) -> Vector3:
	return a.position.direction_to(b.position)


static func global_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.global_position.distance_to(b.global_position)


static func local_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.position.distance_to(b.position)


static func a_is_facing_b(a: Node3D, b: Node3D) -> bool:
	return b.global_position.dot(a.basis.z) < 0
	
# Use on _process or _physic_process
static func rotate_toward_v2(from: Node2D, to: Node2D, lerp_weight: float = 0.5) -> void:
	from.rotation = lerp_angle(from.rotation, global_direction_to_v2(to, from).angle(), clamp(lerp_weight, 0.0, 1.0))

# Use on _process or _physic_process
static func rotate_toward_v3(from: Node3D, to: Node3D, lerp_weight: float = 0.5) -> void:
	from.basis = from.basis.slerp(Basis.looking_at(global_direction_to_v3(from, to)), clamp(lerp_weight, 0.0, 1.0))


static func align_nodes_v2(from: Node2D, to: Node2D, align_position: bool = true, align_rotation: bool = true) -> void:
	var original_parent = from.get_parent()
	from.reparent(to, false)
	
	if align_position:
		from.position = Vector2.ZERO
		
	if align_rotation:
		from.rotation = 0
	
	from.reparent(original_parent)


static func align_nodes_v3(from: Node3D, to: Node3D, align_position: bool = true, align_rotation: bool = true) -> void:
	var original_parent = from.get_parent()
	from.reparent(to, false)
	
	if align_position:
		from.position = Vector3.ZERO
		
	if align_rotation:
		from.rotation =  Vector3.ZERO
	
	from.reparent(original_parent)


static func get_nearest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var result := {"target": null, "distance": null}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (result.target == null or (distance_to_target < result.distance)):
			result.target = node
			result.distance = distance_to_target
		
	return result
	

static func get_nearest_nodes_sorted_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Array:
	var nodes_copy = nodes.duplicate()\
		.filter(func(node): return (node is Node2D or node is Node3D) and MathHelper.decimal_value_is_between(node.global_position.distance_to(from), min_distance, max_range))
		
	nodes_copy.sort_custom(func(a, b): return a.global_position.distance_to(from) < b.global_position.distance_to(from))
	
	return nodes_copy


static func get_farthest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var farthest := {"target": null, "distance": 0.0}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (farthest.target == null or (distance_to_target > farthest.distance)):
			farthest.target = node
			farthest.distance = distance_to_target
		
	return farthest


static func mouse_grid_snap(node: Node2D, size: int, use_local_position: bool = false) -> Vector2:
	if node.is_inside_tree():
		var mouse_position: Vector2 = node.get_local_mouse_position() if use_local_position else node.get_global_mouse_position()
		var grid_position: Vector2 = (mouse_position / size).floor()
		
		if use_local_position:
			node.position = grid_position * size
		else:
			node.global_position = grid_position * size
			
		return grid_position
		
	return Vector2.ZERO


static func mouse_grid_snap_by_texture(sprite: Sprite2D, use_local_position: bool = false) -> Vector2:
	var texture_size: Vector2 = sprite.texture.get_size()
	
	return mouse_grid_snap(sprite, floor(max(texture_size.x, texture_size.y)), use_local_position)
