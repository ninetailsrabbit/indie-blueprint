class_name IndieBlueprintMouseRayCastDiceInteractor3D extends Node3D

@export var origin_camera: Camera3D
@export_range(1, 32, 1) var dices_collision_layer: int = 8
@export var drag_input_action: StringName = &"drag_dice"
@export var ray_length: float = 100.0
@export var dragging_height: float = 1.0
@export var interact_mouse_button = MOUSE_BUTTON_LEFT
@export var cancel_interact_input_action: StringName = &"cancel_interaction"

@onready var current_camera: Camera3D = origin_camera:
	set(new_camera):
		if new_camera != current_camera:
			current_camera = new_camera
			
			set_process_unhandled_input(current_camera is Camera3D)
			set_process(current_camera is Camera3D)

var current_dice: IndieBlueprintDice:
	set(value):
		if value != current_dice:
			current_dice = value
			
			if current_dice:
				current_dice.change_state_to_hovered()
					
var focused: bool = false
var interacting: bool = false

## We save both to calculate the direction when roll the dice by drag
var previous_mouse_position: Vector3 = Vector3.ZERO
var mouse_position: Vector3 = Vector3.ZERO:
	set(value):
		if value != mouse_position:
			previous_mouse_position = mouse_position
			mouse_position = value
			

func _ready() -> void:
	set_physics_process(current_camera is Camera3D)
	

func _physics_process(_delta: float) -> void:
	update_mouse_screen_position()
	
	if current_dice and not current_dice.is_rolling:
		if InputMap.has_action(drag_input_action) and Input.is_action_pressed(drag_input_action):
			current_dice.reset_forces()
			current_dice.change_state_to_dragged()
			current_dice.freeze = true
			current_dice.global_position = Vector3(mouse_position.x, dragging_height, mouse_position.z)
		else:
			if current_dice.current_state_is_dragged():
				current_dice.roll(previous_mouse_position.direction_to(mouse_position))


func update_mouse_screen_position(screen_position: Vector2 = get_viewport().get_mouse_position()):
	var world_space := get_world_3d().direct_space_state
	var ray_origin := origin_camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = origin_camera.project_ray_normal(screen_position)
	var target := ray_origin + ray_direction * ray_length
	
	var ray_query = PhysicsRayQueryParameters3D.create(
		ray_origin, 
		target,
		1 | IndieBlueprintRpgUtils.layer_to_value(dices_collision_layer)
	)
	
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true
	
	var result := world_space.intersect_ray(ray_query)
	
	if ray_direction.y != 0: 
		var distance = (-ray_origin.y + dragging_height) / ray_direction.y
		var y_plane_hit_position = ray_origin + ray_direction * distance
		mouse_position =  y_plane_hit_position
	
	if IndieBlueprintRpgUtils.is_mouse_visible() \
		and result.has("collider") \
		and result.collider is IndieBlueprintDice:
			
		current_dice = result.collider
	else:
		if current_dice and not current_dice.current_state_is_dragged():
			current_dice = null


func change_camera_to(new_camera: Camera3D) -> void:
	current_camera = new_camera


func return_to_original_camera() -> void:
	change_camera_to(origin_camera)


func enable() -> void:
	set_physics_process(true)
	

func disable() -> void:
	set_physics_process(false)
