@icon("res://autoload/screen/dynamic_crosshair.svg")
extends Control

## It's enabled draw the dynamic pointer in the center of the screen
@export var use_dynamic_pointer: bool = false:
	set(value):
		if value != use_dynamic_pointer:
			use_dynamic_pointer = value
			
			if use_dynamic_pointer:
				queue_redraw()
				show()
			else:
				hide()
			
@export var dot_radius: float = 1.5:
	set(value):
		if value != dot_radius:
			dot_radius = value
			
			if dot_radius:
				queue_redraw()
				
@export var dot_color: Color = Color.WHITE:
	set(value):
		if value != dot_color:
			dot_color = value
			
			if dot_color:
				queue_redraw()
## This reticle width means the distance between the two points in the line so we can adjust them using the reticle_scale value using this as base
@export var reticle_width: Vector2 = Vector2(5, 15):
	set(value):
		if value != reticle_width:
			reticle_width = value
			
			if reticle_width:
				prepare_reticles()
## Scale the reticle width properly scaling the base width
@export_range(1.0, 10.0, 0.1) var reticle_scale: float = 1.0:
	set(value):
		if value != reticle_scale:
			reticle_scale = value
			
			if reticle_scale:
				prepare_reticles()

@onready var top_reticle: Line2D = $TopReticle
@onready var bottom_reticle: Line2D = $BottomReticle
@onready var right_reticle: Line2D = $RightReticle
@onready var left_reticle: Line2D = $LeftReticle

var top_reticle_original_position: Vector2
var bottom_reticle_original_position: Vector2
var right_reticle_original_position: Vector2
var left_reticle_original_position: Vector2

var top_reticle_original_rotation: float
var bottom_reticle_original_rotation: float
var right_reticle_original_rotation: float
var left_reticle_original_rotation: float

var reticle_original_dot_radius: float
var reticle_original_dot_color: Color


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	if use_dynamic_pointer:
		queue_redraw()
	else:
		hide()
		
	prepare_reticles()
	_save_reticle_original_values()


func prepare_reticles() -> void:
	if is_node_ready():
		var reticle_width_scaled = reticle_width.x * reticle_scale
		var reticle_scale_difference = reticle_width_scaled - reticle_width.x 
		var reticle_y_scaled = absf(reticle_width.y + reticle_scale_difference)
		
		top_reticle.add_point(Vector2(0, -reticle_width_scaled))
		top_reticle.add_point(Vector2(0, -reticle_y_scaled ))
		
		bottom_reticle.add_point(Vector2(0, reticle_width_scaled))
		bottom_reticle.add_point(Vector2(0, reticle_y_scaled))
		
		right_reticle.add_point(Vector2(reticle_width_scaled, 0))
		right_reticle.add_point(Vector2(reticle_y_scaled, 0))
		
		left_reticle.add_point(Vector2(-reticle_width_scaled, 0))
		left_reticle.add_point(Vector2(-reticle_y_scaled, 0))
		
		
func expand_reticles(distance: float = 5.0, time: float = 0.15) -> void:
		var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		tween.tween_property(top_reticle, "position", top_reticle.position + Vector2.UP.rotated(top_reticle.rotation) * distance, time)
		tween.tween_property(bottom_reticle, "position", bottom_reticle.position + Vector2.DOWN.rotated(bottom_reticle.rotation) * distance, time)
		tween.tween_property(right_reticle, "position", right_reticle.position + Vector2.RIGHT.rotated(right_reticle.rotation) * distance, time)
		tween.tween_property(left_reticle, "position", left_reticle.position + Vector2.LEFT.rotated(left_reticle.rotation) * distance, time)
		
		await tween.finished


func rotate_reticles(angle_in_degrees: float = 45, time: float = 0.15) -> void:
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(top_reticle, "rotation", top_reticle.rotation + deg_to_rad(angle_in_degrees), time)
	tween.tween_property(bottom_reticle, "rotation", bottom_reticle.rotation + deg_to_rad(angle_in_degrees), time)
	tween.tween_property(right_reticle, "rotation", right_reticle.rotation + deg_to_rad(angle_in_degrees), time)
	tween.tween_property(left_reticle, "rotation", left_reticle.rotation + deg_to_rad(angle_in_degrees), time)

	await tween.finished
	
	
func reset_reticles_position_to_default(time: float = 0.15) -> void:
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(top_reticle, "position", top_reticle_original_position, time)
	tween.tween_property(bottom_reticle, "position", bottom_reticle_original_position, time)
	tween.tween_property(right_reticle, "position", right_reticle_original_position, time)
	tween.tween_property(left_reticle, "position", left_reticle_original_position, time)

	
func reset_reticles_rotation_to_default(time: float = 0.15) -> void:
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(top_reticle, "rotation", top_reticle_original_rotation, time)
	tween.tween_property(bottom_reticle, "rotation", bottom_reticle_original_rotation, time)
	tween.tween_property(right_reticle, "rotation", right_reticle_original_rotation, time)
	tween.tween_property(left_reticle, "rotation", left_reticle_original_rotation, time)


func reset_dot_radius_to_default() -> void:
	dot_radius = reticle_original_dot_radius


func reset_dot_color_to_default() -> void:
	dot_color = reticle_original_dot_color


func reset_all_values_to_default() -> void:
	reset_reticles_rotation_to_default()
	reset_reticles_position_to_default()
	reset_dot_radius_to_default()
	reset_dot_color_to_default()


func _save_reticle_original_values() -> void:
	if is_node_ready():
		top_reticle_original_position = top_reticle.position
		bottom_reticle_original_position = bottom_reticle.position
		right_reticle_original_position = right_reticle.position
		left_reticle_original_position = left_reticle.position
		
		top_reticle_original_rotation = top_reticle.rotation
		bottom_reticle_original_rotation = bottom_reticle.rotation
		right_reticle_original_rotation = right_reticle.rotation
		left_reticle_original_rotation = left_reticle.rotation
		
		reticle_original_dot_radius = dot_radius
		reticle_original_dot_color = dot_color


func _draw() -> void:
	draw_circle(Vector2.ZERO, dot_radius, dot_color)


#region Signal callbacks
func on_expanded_requested(distance: float) -> void:
	expand_reticles(distance)

func on_rotation_requested(angle_in_degrees: float) -> void:
	rotate_reticles(angle_in_degrees)

func on_reset_requested() -> void:
	reset_all_values_to_default()
#endregion
