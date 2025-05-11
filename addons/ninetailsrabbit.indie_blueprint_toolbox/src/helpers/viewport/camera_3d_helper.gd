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


static func world_position_to_ui(ui_element: Control, world_position: Vector3, camera: Camera3D) -> void:
	ui_element.visible = not camera.is_position_behind(world_position)
	ui_element.position = world_to_screen_position(world_position, camera)


static func project_raycast(
	viewport: Viewport,
	from: Vector3,
	to: Vector3,
	collide_with_bodies: bool = true,
	collide_with_areas: bool = false,
	collision_mask: int = 1
) -> RaycastResult:
	
	var ray_query = PhysicsRayQueryParameters3D.create(
		from, 
		to,
		collision_mask
	)
	
	ray_query.collide_with_bodies = collide_with_bodies
	ray_query.collide_with_areas = collide_with_areas
	
	var result := viewport.get_world_3d().direct_space_state.intersect_ray(ray_query)

	return RaycastResult.new(result)
	

static func project_raycast_from_camera_center(
	camera: Camera3D,
	distance: float = 1000.0, 
	collide_with_bodies: bool = true,
	collide_with_areas: bool = false,
	collision_mask: int = 1
) -> RaycastResult:
		
	var viewport: Viewport = camera.get_viewport()
	var screen_center: Vector2i = viewport.get_visible_rect().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var to: Vector3 = origin + camera.project_ray_normal(screen_center) * distance
	
	return project_raycast(viewport, origin, to, collide_with_bodies, collide_with_areas, collision_mask)
	
	
static func project_raycast_to_mouse(
	camera: Camera3D,
	distance: float = 1000.0,
	collide_with_bodies: bool = true,
	collide_with_areas: bool = false,
	collision_mask: int = 1
) -> RaycastResult:
	
	var viewport: Viewport = camera.get_viewport()
	var mouse_position: Vector2 = viewport.get_mouse_position()
			
	var world_space := viewport.get_world_3d().direct_space_state
	var from := camera.project_ray_origin(mouse_position)
	var to := camera.project_position(mouse_position, distance)
	
	return project_raycast(viewport, from, to, collide_with_bodies, collide_with_areas, collision_mask)
