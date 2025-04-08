class_name IndieBlueprintCamera3DHelper


static func center_by_ray_origin(camera: Camera3D) -> Vector3:
	return camera.project_ray_origin(Vector2.ZERO)


static func center_by_origin(camera: Camera3D) -> Vector3:
	return camera.global_transform.origin


static func forward_direction(camera: Camera3D) -> Vector3:
	return Vector3.FORWARD.z * camera.global_transform.basis.z.normalized()
	
	
static func is_facing_camera(camera: Camera3D, node: Node) -> bool:
	return camera.global_position.dot(node.basis.z) < 0


static func world_to_screen_position(world_position: Vector3, camera: Camera3D) -> Vector2:
	return camera.unproject_position(world_position)


static func update_ui_world_position(ui_element: Control, world_position: Vector3, camera: Camera3D) -> void:
	ui_element.visible = not camera.is_position_behind(world_position)
	ui_element.position = world_to_screen_position(world_position, camera)
