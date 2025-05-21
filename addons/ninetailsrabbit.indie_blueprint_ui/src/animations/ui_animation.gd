extends Node

#region Animations
func screen_top_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO):
	node.position.y = -node.size.y
	
	if position.is_zero_approx():
		## Target position to center by default
		position = _node_viewport_center_position(node)
		
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position', position, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return tween.finished


func screen_bottom_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO):
	node.position.y = get_viewport().get_visible_rect().size.y + node.size.y
	
	if position.is_zero_approx():
		## Target position to center by default
		position = _node_viewport_center_position(node)
		
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position', position, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return tween.finished


func screen_left_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO):
	node.position.x = -node.size.x
	
	if position.is_zero_approx():
		## Target position to center by default
		position = _node_viewport_center_position(node)
		
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position', position, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return tween.finished


func screen_right_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO):
	node.position.x = get_viewport().get_visible_rect().size.x + node.size.x
	
	if position.is_zero_approx():
		## Target position to center by default
		position = _node_viewport_center_position(node)
		
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position', position, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return tween.finished
	
## Pop the node to the target scale, which defaults to Vector2.ONE.
func pop(node: CanvasItem, speed: float = 0.3, to_scale: Vector2 = Vector2.ONE):
	node.pivot_offset = (node.get_size() / 2).ceil()
	
	var tween: Tween = create_tween()
	tween.tween_property(node, 'scale', to_scale, speed).from(Vector2.ZERO)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return tween.finished

## Shrink the node to the target scale, which defaults to Vector2.ZERO.
func shrink(node: CanvasItem, speed: float = 0.3, to_scale: Vector2 = Vector2.ZERO):
	node.pivot_offset = (node.get_size() / 2).ceil()
	
	var tween: Tween = create_tween()
	tween.tween_property(node, 'scale', to_scale, speed).from(node.scale)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return tween.finished

#endregion

#region Helpers
func _node_viewport_center_position(node: CanvasItem) -> Vector2:
	return (get_viewport().get_visible_rect().size / 2) - node.size / 2
#endregion
