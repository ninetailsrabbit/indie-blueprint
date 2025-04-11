class_name InteractionKit3DPluginUtilities

static func is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed


static func is_mouse_right_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed


static func is_mouse_visible() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_VISIBLE || Input.mouse_mode == Input.MOUSE_MODE_CONFINED


static func action_just_pressed_and_exists(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_just_pressed(action)


static func action_pressed_and_exists(action: String, event: InputEvent = null) -> bool:
	return InputMap.has_action(action) and event.is_action_pressed(action) if event else Input.is_action_pressed(action)


static func global_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.global_position.distance_to(b.global_position)


static func generate_3d_random_fixed_direction() -> Vector3:
	return Vector3(randi_range(-1, 1), randi_range(-1, 1), randi_range(-1, 1)).normalized()


static func rotate_horizontal_random(origin: Vector3 = Vector3.ONE) -> Vector3:
	var arc_direction: Vector3 = [Vector3.DOWN, Vector3.UP].pick_random()
	
	return origin.rotated(arc_direction, randf_range(-PI / 2, PI / 2))


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

## Only works for native custom class not for GDScriptNativeClass
## Example NodeTraversal.first_node_of_custom_class(self, MachineState)
static func first_node_of_custom_class(node: Node, class_to_find: GDScript):
	if node.get_child_count() == 0:
		return null

	for child: Node  in node.get_children():
		if child.get_script() == class_to_find:
			return child
	
	return null
	
	
static func first_node_of_type(node: Node, type_to_find: Node):
	if node.get_child_count() == 0:
		return null

	for child: Node  in node.get_children():
		if child.is_class(type_to_find.get_class()):
			type_to_find.free()
			return child
	
	type_to_find.free()
	
	return null
	
	
static func camera_forward_direction(camera: Camera3D) -> Vector3:
	return Vector3.FORWARD.z * camera.global_transform.basis.z.normalized()


static func create_physics_timer(wait_time: float = 1.0, autostart: bool = false, one_shot: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.autostart = autostart
	timer.one_shot = one_shot
	
	return timer
	

@warning_ignore("narrowing_conversion")
static func layer_to_value(layer: int) -> int:
	if layer > 32:
		push_error("CollisionHelper->layer_to_value: The specified collision layer (%d) is invalid. Please ensure the layer value is between 1 and 32" % layer)
	
	return pow(2, clampi(layer, 1, 32) - 1)

@warning_ignore("narrowing_conversion")
static func value_to_layer(value: int) -> int:
	if value == 1:
		return value
		
	## This bitwise operation check if the value is a valid base 2
	if value > 0 and (value & (value - 1)) == 0:
		return (log(value) / log(2)) + 1
	
	push_error("CollisionHelper->value_to_layer: The specified value %d) is invalid. Please ensure the value is a power of 2" % value)
	
	return 0
