class_name Camera2DHelper


func get_panning_camera_position(camera: Camera2D) -> Vector2:
	var viewport: Viewport = camera.get_viewport()
	
	var current_mouse_screen_position = viewport.get_mouse_position()
	var original_mouse_global_position = (viewport.get_screen_transform() * viewport.get_canvas_transform()).affine_inverse() * viewport.get_mouse_position()
	var final_mouse_global_position = (viewport.get_screen_transform() * viewport.get_canvas_transform()).affine_inverse() * current_mouse_screen_position
	var mouse_global_diff = original_mouse_global_position - final_mouse_global_position
	var new_camera_position = camera.global_position + mouse_global_diff
	
	if new_camera_position != camera.global_position:
		return new_camera_position
		
	return Vector2.ZERO
