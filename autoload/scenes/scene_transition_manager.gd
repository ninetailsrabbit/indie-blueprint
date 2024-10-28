extends Node

signal transition_requested(next_scene: String)
signal transition_finished(next_scene: String)

const voronoi_material = preload("res://autoload/scenes/transitions/voronoi_material.tres")

@export var loading_screen_scene: PackedScene = preload("res://autoload/scenes/loading/loading_screen.tscn")

@onready var transition_animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = %ColorRect


enum Transitions {
	NoTransition,
	FadeToBlack,
	FadeFromBlack,
	VoronoiInLeftToRight,
	VoronoiInRightToLeft,
	VoronoiOutLeftToRight,
	VoronoiOutRightToLeft,
}

var next_scene_path: String
var previous_animations := []
var remaining_animations := []


func _ready():
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.z_index = 100
	
	transition_animation_player.animation_finished.connect(on_animation_finished)
	
	
func reload_current_scene() -> void:
	get_tree().reload_current_scene()


func transition_to_scene(
	scene, 
	loading_screen: bool = false,
	out_transition: Transitions = Transitions.FadeToBlack,
	in_transition: Transitions =  Transitions.FadeFromBlack, 
):
	if not loading_screen:
		previous_animations.clear()
		
	_prepare_transition_animations(loading_screen, out_transition, in_transition)
	next_scene_path = scene.resource_path if scene is PackedScene else scene
	
	transition_requested.emit(next_scene_path)
	
	if typeof(scene) == TYPE_STRING and _is_valid_scene_path(scene):
		if not remaining_animations.is_empty():
			await trigger_transition(remaining_animations.pop_back())
			
		_transition_to_scene_file(scene, loading_screen)
	
	elif scene is PackedScene:
		if not remaining_animations.is_empty():
			await trigger_transition(remaining_animations.pop_back())
				
		_transition_to_packed_scene(scene, loading_screen)


func _prepare_transition_animations(loading_screen: bool, out_transition: Transitions, in_transition: Transitions):
	remaining_animations.clear()
	
	if loading_screen:
		remaining_animations.append(out_transition)
		previous_animations.append_array([in_transition, out_transition])
	else:
		remaining_animations.append_array([in_transition, out_transition])
		
	remaining_animations = remaining_animations.filter(func(transition): return transition != Transitions.NoTransition)

	
func _transition_to_scene_file(scene_path: String, loading_screen: bool = false):
	if loading_screen:
		_transition_with_loading_screen(scene_path)
	else:
		transition_finished.emit(scene_path)
		get_tree().call_deferred("change_scene_to_file", scene_path)
	

func _transition_to_packed_scene(scene: PackedScene,  loading_screen: bool = false):
	if loading_screen:
		_transition_with_loading_screen(scene.resource_path)
	else:
		transition_finished.emit(next_scene_path)
		get_tree().call_deferred("change_scene_to_packed", scene)
	
	
func _transition_with_loading_screen(_scene):
	if loading_screen_scene:
		transition_finished.emit(loading_screen_scene.resource_path)
		get_tree().call_deferred("change_scene_to_packed", loading_screen_scene)
		
	
func trigger_transition(transition: Transitions) -> void:
	if transition_animation_player.is_playing():
		return
		
	var transition_name: String = _enum_transition_to_animation_name(transition)
	
	if transition_animation_player.get_animation_list().has(transition_name):
		transition_animation_player.play(transition_name)
		await transition_animation_player.animation_finished


func voronoi_in_transition(flip: bool = false, duration: float = 1.0):
	color_rect.material = voronoi_material as ShaderMaterial
	color_rect.material.set_shader_parameter("flip", flip)
	
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/threshold", 1.0, duration).from(0.0)
	

func voronoi_out_transition(flip: bool = false, duration: float = 1.0):
	color_rect.material = voronoi_material as ShaderMaterial
	color_rect.material.set_shader_parameter("flip", flip)
	
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/threshold", 0.0, duration).from(1.0)
	
func _enum_transition_to_animation_name(transition: Transitions) -> String:
	var transition_name: String = ""
	
	match transition:
		Transitions.FadeToBlack:
			transition_name = "fade_to_black"
		Transitions.FadeFromBlack:
			transition_name = "fade_from_black"
		Transitions.VoronoiInLeftToRight:
			transition_name = "voronoi_in_left"
		Transitions.VoronoiInRightToLeft:
			transition_name = "voronoi_in_right"
		Transitions.VoronoiOutRightToLeft:
			transition_name = "voronoi_out_left"
		Transitions.VoronoiOutLeftToRight:
			transition_name = "voronoi_out_right"
		_:
			transition_name = ""
			
	return transition_name


func _is_valid_scene_path(scene: String) -> bool:
	return not scene.is_empty() and scene.is_absolute_path() and ResourceLoader.exists(scene)

### SIGNAL CALLBACKS ###

func on_animation_finished(_animation_name: String):
	if remaining_animations.is_empty():
		return
		
	var animation = _enum_transition_to_animation_name(remaining_animations.pop_back())
	
	if animation and transition_animation_player.get_animation_list().has(animation):
		transition_animation_player.play(animation)
