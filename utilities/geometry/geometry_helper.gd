class_name GeometryHelper


static func get_random_mesh_surface_position(target: MeshInstance3D) -> Vector3:
	if target.mesh:
		var target_mesh_faces = target.mesh.get_faces()
		var random_face: Vector3 = target_mesh_faces[randi() % target_mesh_faces.size()]
		
		random_face = Vector3(abs(random_face.x), abs(random_face.y), abs(random_face.z))
		
		return Vector3(
			randf_range(-random_face.x, random_face.x),
		 	randf_range(-random_face.y, random_face.y), 
			randf_range(-random_face.z, random_face.z)
		)
		
	return Vector3.ZERO


static func random_inside_unit_circle(position: Vector2, radius: float = 1.0) -> Vector2:
	var angle := randf() * 2.0 * PI
	return position + Vector2(cos(angle), sin(angle)) * radius


static func random_on_unit_circle(position: Vector2) -> Vector2:
	var angle := randf() * 2.0 * PI
	var radius := randf()
	
	return position + radius * Vector2(cos(angle), sin(angle))


static func random_point_in_rect(rect: Rect2) -> Vector2:
	randomize()
	
	var x = randf()
	var y = randf()
	
	var x_dist = rect.size.x * x
	var y_dist = rect.size.y * y
	
	return Vector2(x_dist, y_dist)

## Two concentric circles (donut basically)
static func random_point_in_annulus(center, radius_small, radius_large) -> Vector2:
	var square = Rect2(center - Vector2(radius_large, radius_large), Vector2(radius_large * 2, radius_large * 2))
	var point = null
	
	while not point:
		var test_point = GeometryHelper.random_point_in_rect(square)
		var distance = test_point.distance_to(center)
		
		if radius_small < distance and distance < radius_large:
			point = test_point
			
	return point

	
static func polygon_bounding_box(polygon: PackedVector2Array) -> Rect2:
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	
	for vec: Vector2 in polygon:
		min_vec = Vector2(min(min_vec.x, vec.x), min(min_vec.y, vec.y))
		max_vec =  Vector2(max(max_vec.x, vec.x), max(max_vec.y, vec.y))
		
	return Rect2(min_vec, max_vec - min_vec)
