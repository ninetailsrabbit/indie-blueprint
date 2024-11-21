class_name GeometryHelper


static func get_random_mesh_surface_position(target: MeshInstance3D) -> Vector3:
	if target.mesh:
		var target_mesh_faces = target.mesh.get_faces()
		var random_face: Vector3 = target_mesh_faces[randi() % target_mesh_faces.size()] * target.scale
		
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


static func create_box_mesh(size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	
	return mesh
	

static func create_plane_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = size
	mesh.mesh = plane
	
	return mesh
	
	
static func create_quad_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = size
	mesh.mesh = quad
	
	return mesh


static func create_prism_mesh(size: Vector3 = Vector3.ONE, left_to_right: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = size
	prism.left_to_right = clampf(left_to_right, -2, 2)
	mesh.mesh = prism
	
	return mesh
	
	
static func create_cilinder_mesh(height: float = 2.0, top_radius: float = 0.5, bottom_radius: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = clampf(height, 0.001, 100.0)
	cylinder.top_radius = clampf(top_radius, 0, 100.0)
	cylinder.bottom_radius = clampf(bottom_radius, 0, 100.0)
	mesh.mesh = cylinder
	
	return mesh
	

	
static func create_sphere_mesh(height: float = 2.0, radius: float = 0.5, is_hemisphere: bool = false) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var cylinder = SphereMesh.new()
	cylinder.height = clampf(height, 0.001, 100.0)
	cylinder.radius = clampf(radius, 0, 100.0)
	cylinder.is_hemisphere = is_hemisphere
	mesh.mesh = cylinder
	
	return mesh
	
	
static func create_capsule_mesh(height: float = 2.0, radius: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.height = clampf(height, 0.001, 100.0)
	capsule.radius = clampf(radius, 0, 100.0)
	mesh.mesh = capsule
	
	return mesh

# Time complexity O(n^2), the more complex method is faster, but is harder to write
static func is_valid_polygon(points: PackedVector2Array) -> bool:
	if points.size() < 3:
		return false  # A polygon must have at least 3 points

	for i in points.size():
		var start1: Vector2 = points[i]
		var end1: Vector2 = points[(i + 1) % points.size()]  # Wrap around to the first point
		
		for j in range(i + 1, points.size()):
			var start2: Vector2 = points[j]
			var end2: Vector2 = points[(j + 1) % points.size()]  # Wrap around to the first point
			
			# Skip adjacent edges or edges sharing a vertex
			if start1 == end2 or start2 == end1:
				continue
				
			if Geometry2D.segment_intersects_segment(start1, end1, start2, end2):
				return false  # Found an intersection, invalid polygon
	
	return true  # No intersections found


static func calculate_polygon_area(polygon: PackedVector2Array) -> float:
	if polygon.size() < 3:
		return 0.0
	
	var area: float = 0.0
	
	for i in polygon.size():
		var current: Vector2 = polygon[i]
		var next: Vector2 = polygon[(i + 1) % polygon.size()]
		
		area += current.x * next.y - current.y * next.x
		
	return abs(area) / 2.0


static func fracture_polygons_triangles(polygon: PackedVector2Array) -> Array:
	var fractured_polygons: Array = []
	var trianglies: Array = Geometry2D.triangulate_polygon(polygon)
	var chunks: Array
	
	for i in range(0, trianglies.size(), 3):
		chunks.append(trianglies.slice(i, i + 3))

	for n in chunks:
		var triangle_points: PackedVector2Array
		
		for point in n:
			triangle_points.append(polygon[point])
			
		fractured_polygons.append(triangle_points)
	
	return fractured_polygons
