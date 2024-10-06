class_name Camera3DHelper


static func center_by_ray_origin(camera: Camera3D) -> Vector3:
	return camera.project_ray_origin(Vector2.ZERO)


static func center_by_origin(camera: Camera3D) -> Vector3:
	return camera.global_transform.origin


static func forward_direction(camera: Camera3D) -> Vector3:
	return Vector3.FORWARD.z * camera.global_transform.basis.z.normalized()
	
	
static func is_facing_camera(camera: Camera3D, node: Node) -> bool:
	return camera.global_position.dot(node.basis.z) < 0
