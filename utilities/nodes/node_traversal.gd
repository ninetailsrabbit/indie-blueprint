class_name NodeTraversal


static func set_owner_to_edited_scene_root(node: Node) -> void:
	if Engine.is_editor_hint() and node.get_tree():
		node.owner = node.get_tree().edited_scene_root
	
	
static func get_all_children(from_node: Node) -> Array: 
	var nodes := []
	
	for child in from_node.get_children():
		if child.get_child_count() > 0:
			nodes.append(child)
			nodes.append_array(get_all_children(child))
		else:
			nodes.append(child)
			
	return nodes


static func get_all_ancestors(from_node: Node) -> Array:
	if from_node.get_parent() == null:
		return []
	
	var ancestors := []
	var node := from_node.get_parent()
	
	while(node.get_parent() != null):
		ancestors.append(node)
		node = node.get_parent()
	
	return ancestors
	

## Only works for native custom class not for GDScriptNativeClass
## Example NodePositioner.find_nodes_of_custom_class(self, MachineState)
static func find_nodes_of_custom_class(node: Node, class_to_find: Variant) -> Array:
	var  result := []
	
	var childrens = node.get_children(true)

	for child in childrens:
		if child.get_script() == class_to_find:
			result.append(child)
		else:
			result.append_array(find_nodes_of_custom_class(child, class_to_find))
	
	return result
	
## Only works for native nodes like Area2D, Camera2D, etc.
## Example NodePositioner.find_nodes_of_type(self, Control.new())
static func find_nodes_of_type(node: Node, type_to_find: Node) -> Array:
	var  result := []
	
	var childrens = node.get_children(true)

	for child in childrens:
		if child.is_class(type_to_find.get_class()):
			result.append(child)
		else:
			result.append_array(find_nodes_of_type(child, type_to_find))
	
	return result


## Only works for native Godot Classes like Area3D, Camera2D, etc.
## Example NodeTraversal.first_node_of_type(self, Control.new())
static func first_node_of_type(node: Node, type_to_find: Node):
	if node.get_child_count() == 0:
		return null

	for child in node.get_children():
		if child.is_class(type_to_find.get_class()):
			type_to_find.free()
			return child
	
	type_to_find.free()
	
	return null
	
## Only works for native custom class not for GDScriptNativeClass
## Example NodeTraversal.first_node_of_custom_class(self, MachineState)
static func first_node_of_custom_class(node: Node, class_to_find: GDScript):
	if node.get_child_count() == 0:
		return null

	for child in node.get_children():
		if child.get_script() == class_to_find:
			return child
	
	return null
	

static func get_first_child(node: Node):
	var node_count := node.get_child_count()
	
	if node_count == 0:
		return null
		
	return node.get_child(0)


static func get_last_child(node: Node):
	var node_count := node.get_child_count()
	
	if node_count == 0:
		return null
		
	return node.get_child(node_count - 1)


static func first_child_node_in_group(node: Node, group: String):
	if node.get_child_count() == 0 || group.is_empty():
		return null
		
	for child in node.get_children(true):
		if child.is_in_group(group):
			return child
			
	return null
	
	
static func hide_nodes(nodes: Array[Node] = []) -> void:
	for node in nodes:
		if node.has_method("hide"):
			node.hide()


static func show_nodes(nodes: Array[Node] = []) -> void:
	for node in nodes:
		if node.has_method("show"):
			node.show()


static func add_all_childrens_to_group(node: Node, group: String, filter: Array[Node] = []) -> void:
	for child in get_all_children(node).filter(func(_node: Node): return not filter.has(_node)):
		child.add_to_group(group)
	

static func add_meta_to_all_children(node: Node, meta: String, value: Variant, filter: Array[Node] = []) -> void:
	for child in get_all_children(node).filter(func(_node: Node): return not filter.has(_node)):
		child.set_meta(meta, value)


static func remove_meta_from_all_children(node: Node, meta: String) -> void:
	for child in get_all_children(node):
		if child.has_meta(meta):
			child.remove_meta(meta)
			

static func get_nearest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var result := {"target": null, "distance": null}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (result.target == null or (distance_to_target < result.distance)):
			result.target = node
			result.distance = distance_to_target
		
		
	return result
	

static func get_farthest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var farthest := {"target": null, "distance": 0.0}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (farthest.target == null or (distance_to_target > farthest.distance)):
			farthest.target = node
			farthest.distance = distance_to_target
		
		
	return farthest


static func get_nearest_nodes_sorted_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Array:
	var nodes_copy = nodes.duplicate()\
		.filter(func(node): return (node is Node2D or node is Node3D) and MathHelper.decimal_value_is_between(node.global_position.distance_to(from), min_distance, max_range))
		
	nodes_copy.sort_custom(func(a, b): return a.global_position.distance_to(from) < b.global_position.distance_to(from))
	
	return nodes_copy


static func get_tree_depth(node: Node) -> int:
	var depth := 0
	
	while(node.get_parent() != null):
		depth += 1
		node = node.get_parent()
		
	return depth
	
	
static func get_absolute_z_index(node: Node2D) -> int:
	var z := 0
	
	while node is Node2D:
		z += node.z_index
		
		if not node.z_as_relative:
			break
			
		node = node.get_parent()
		
	return z
