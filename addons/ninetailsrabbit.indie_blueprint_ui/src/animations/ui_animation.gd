extends Node

@export var screen_to_animation_options: UIAnimationOptions
@export var shrink_animation_options: UIAnimationOptions
@export var pop_animation_options: UIAnimationOptions
@export var out_screen_animation_options: UIAnimationOptions


#region Animations
func screen_top_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO, options: UIAnimationOptions = screen_to_animation_options):
	node.position.y = -node.size.y
	
	return screen_to_position(node, position, options)


func screen_bottom_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO, options: UIAnimationOptions = screen_to_animation_options):
	node.position.y = get_viewport().get_visible_rect().size.y + node.size.y
	
	return screen_to_position(node, position, options)


func screen_left_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO, options: UIAnimationOptions = screen_to_animation_options):
	node.position.x = -node.size.x
	
	return screen_to_position(node, position, options)


func screen_right_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO, options: UIAnimationOptions = screen_to_animation_options):
	node.position.x = get_viewport().get_visible_rect().size.x + node.size.x
	
	return screen_to_position(node, position, options)


func to_out_of_screen_right(node: CanvasItem, options: UIAnimationOptions = out_screen_animation_options):
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position:x', get_viewport().get_visible_rect().size.x + node.size.x, options.time)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished


func to_out_of_screen_left(node: CanvasItem, options: UIAnimationOptions = out_screen_animation_options):
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position:x', -node.size.x, options.time)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished


func to_out_of_screen_top(node: CanvasItem, options: UIAnimationOptions = out_screen_animation_options):
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position:y', -node.size.y, options.time)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished


func to_out_of_screen_bottom(node: CanvasItem, options: UIAnimationOptions = out_screen_animation_options):
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position:y', get_viewport().get_visible_rect().size.y + node.size.y, options.time)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished


func screen_to_position(node: CanvasItem, position: Vector2 = Vector2.ZERO, options: UIAnimationOptions = screen_to_animation_options):
	if position.is_zero_approx():
		## Target position to center by default
		position = _node_viewport_center_position(node)
		
	var tween: Tween = create_tween()
	tween.tween_property(node, 'position', position, options.time)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished


func pop(node: CanvasItem, target_scale:Vector2 = Vector2.ONE, options:UIAnimationOptions = pop_animation_options):
	_adjust_pivot_offset(node, options)
	
	var tween: Tween = create_tween()
	tween.tween_property(node, 'scale', target_scale, options.time).from(Vector2.ZERO)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished

func shrink(node: CanvasItem, options: UIAnimationOptions = shrink_animation_options):
	_adjust_pivot_offset(node, options)
	
	var tween: Tween = create_tween()
	tween.tween_property(node, 'scale', Vector2.ZERO, options.time).from(node.scale)\
		.set_trans(options.transition).set_ease(options.easing)
	
	return tween.finished

#endregion

#region Helpers
func _adjust_pivot_offset(node: CanvasItem, options: UIAnimationOptions) -> void:
	match options.pivot_offset:
		UIAnimationOptions.PivotOffset.Center:
			node.pivot_offset = (node.get_size() / 2).ceil()
		UIAnimationOptions.PivotOffset.TopLeft:
			node.pivot_offset = Vector2.ZERO
		UIAnimationOptions.PivotOffset.TopRight:
			node.pivot_offset = Vector2(node.size.x, 0)
		UIAnimationOptions.PivotOffset.BottomLeft:
			node.pivot_offset = Vector2(0, node.size.y)
		UIAnimationOptions.PivotOffset.BottomRight:
			node.pivot_offset = Vector2(node.size.x, node.size.y)


func _node_viewport_center_position(node: CanvasItem) -> Vector2:
	return (get_viewport().get_visible_rect().size / 2) - node.size / 2
#endregion
