extends Node

signal transition_requested(next_scene: String)
signal transition_finished(next_scene: String)
signal load_finished(next_scene: String)

@export var transitions: Array[IndieBlueprintSceneTransitionConfiguration] = []
@export var use_subthreads: bool = false

@onready var canvas_layer: CanvasLayer = $CanvasLayer

## After using the ResourceLoader into a PackedScene the resource_path can be returned empty
## so to avoid this error we keep the reference on the first load and use it in the transition
## https://stackoverflow.com/questions/77729092/is-resourceloader-meant-to-cache-loaded-resources
var scenes_references_paths: Dictionary[PackedScene, String] = {}

var next_scene_path: String = ""
## This variable is used as flag to know if the scene is already loaded when the in-transition finished
## or instead follow the _process and change when the loading is finished there.
var is_loaded: bool = false:
	set(value):
		if value != is_loaded:
			is_loaded = value
			
			if is_loaded:
				load_finished.emit(next_scene_path)
				
var current_transition: IndieBlueprintSceneTransition
var current_progress: Array = []


func _process(delta: float) -> void:
	if _filepath_is_valid(next_scene_path):
		var load_status := _get_load_status(current_progress)
		
		match load_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
			ResourceLoader.THREAD_LOAD_LOADED:
				if not is_loaded:
					is_loaded = true
					_change_to_loaded_scene(next_scene_path)
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("IndieBlueprintSceneTransitioner: An error %s happened in the process of loading the scene %s, aborting the transition..." %[error_string(load_status), next_scene_path] )
				next_scene_path = ""
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				#push_error("IndieBlueprintSceneTransitioner: An error %s happened, the scene %s is invalid, aborting the transition..." %[error_string(load_status), next_scene_path] )
				next_scene_path = ""

func _ready() -> void:
	set_process(false)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	transition_finished.connect(on_transition_finished)
	load_finished.connect(on_load_finished)


func add_transition_configuration(conf: IndieBlueprintSceneTransitionConfiguration) -> void:
	if not transitions.has(conf):
		transitions.append(conf)


func remove_transition_configuration(conf: IndieBlueprintSceneTransitionConfiguration) -> void:
	transitions.erase(conf)


func transition_to(
	scene: Variant,
	in_transition_id: StringName = IndieBlueprintPremadeTransitions.ColorFade,
	out_transition_id: StringName = IndieBlueprintPremadeTransitions.ColorFade,
	## A dictionary with "in" and "out" keys to pass the arguments to the corresponding transitions
	args: Dictionary = {} 
) -> void:
	## A current transition is happening
	if is_processing() or not next_scene_path.is_empty():
		return
	
	next_scene_path = _get_scene_path(scene)
	
	if not _filepath_is_valid(next_scene_path):
		push_error("IndieBlueprintSceneTransitioner: The scene path %s is not a valid resource to load, aborting scene transition..." % next_scene_path)
		load_finished.emit(next_scene_path)
		return
	
	current_progress.clear()
	transition_requested.emit(next_scene_path)

	var in_transition: IndieBlueprintSceneTransitionConfiguration = get_transition_by_id(in_transition_id)
	
	if in_transition == null:
		push_error("IndieBlueprintSceneTransitioner: The transition with id %s was not found, aborting the transition..." % in_transition_id)
		load_finished.emit(next_scene_path)
	else:
		## Prepare the in-transition
		current_transition = in_transition.scene.instantiate()
		canvas_layer.add_child(current_transition)
		
		current_transition.in_transition_finished.connect(
			on_in_transition_finished.bind(in_transition_id, out_transition_id, args), 
			CONNECT_ONE_SHOT)
			
		current_transition.out_transition_finished.connect(
			on_out_transition_finished.bind(current_transition), 
			CONNECT_ONE_SHOT)
		
		## Initialize the first transition
		current_transition.transition_in(args.get_or_add("in", {}))


func transition_to_with_loading_screen(
	scene: Variant,
	loading_screen_scene: Variant,
	in_transition_id: StringName = IndieBlueprintPremadeTransitions.ColorFade,
	out_transition_id: StringName = IndieBlueprintPremadeTransitions.ColorFade,
	## A dictionary with "in" and "out" keys to pass the arguments to the corresponding transitions
	args: Dictionary = {} 
	) -> void:
	
	var target_scene_path: String = _get_scene_path(scene)
	next_scene_path = _get_scene_path(loading_screen_scene)
	
	if not _filepath_is_valid(next_scene_path):
		push_error("IndieBlueprintSceneTransitioner: The loading screen scene path %s is not a valid resource to load, aborting scene transition..." % next_scene_path)
		load_finished.emit(next_scene_path)
		return
		
	if not _filepath_is_valid(target_scene_path):
		push_error("IndieBlueprintSceneTransitioner: The target scene path %s is not a valid resource to load, aborting scene transition..." % next_scene_path)
		load_finished.emit(target_scene_path)
		return
	
	var loading_screen: IndieBlueprintLoadingScreen

	if loading_screen_scene is PackedScene:
		loading_screen = loading_screen_scene.instantiate() as IndieBlueprintLoadingScreen
	elif typeof(loading_screen_scene) == TYPE_STRING_NAME or typeof(loading_screen_scene) == TYPE_STRING:
		loading_screen = load(loading_screen_scene).instantiate()
		
	loading_screen.next_scene_path = target_scene_path
	
	current_progress.clear()
	transition_requested.emit(next_scene_path)
	
	var in_transition: IndieBlueprintSceneTransitionConfiguration = get_transition_by_id(in_transition_id)
	
	if in_transition == null:
		push_error("IndieBlueprintSceneTransitioner: The transition with id %s was not found, aborting the transition..." % in_transition_id)
		load_finished.emit(next_scene_path)
	else:
		## Prepare the in-transition
		current_transition = in_transition.scene.instantiate()
		canvas_layer.add_child(current_transition)
		
		current_transition.in_transition_finished.connect(
			func():
				current_transition.hide()
				canvas_layer.add_child(loading_screen)
				
				loading_screen.finished.connect(func(next_scene_loaded: PackedScene):
					if in_transition_id == out_transition_id:
						current_transition.show()
						current_transition.transition_out(args.get_or_add("out", {}))
						get_tree().call_deferred("change_scene_to_packed", next_scene_loaded)
						loading_screen.queue_free()
					else:
						_remove_current_transition()
						var out_transition: IndieBlueprintSceneTransitionConfiguration = get_transition_by_id(out_transition_id)
						
						if out_transition:
							current_transition = out_transition.scene.instantiate()
							canvas_layer.add_child(current_transition)
							
							current_transition.transition_out(args.get_or_add("out", {}))
							get_tree().call_deferred("change_scene_to_packed", next_scene_loaded)
					)
				
				, CONNECT_ONE_SHOT)
		
		current_transition.transition_in(args)
		

func _change_to_loaded_scene(next_scene: String = next_scene_path) -> void:
	load_finished.emit(next_scene)
	get_tree().call_deferred("change_scene_to_packed", ResourceLoader.load_threaded_get(next_scene))


func _get_scene_path(scene: Variant) -> String:
	if scene is PackedScene:
		return scenes_references_paths.get_or_add(scene, scene.resource_path)
	elif typeof(scene) == TYPE_STRING_NAME or typeof(scene) == TYPE_STRING:
		return scene
	else:
		push_error("IndieBlueprintSceneTransitioner: The scene parameter needs to be a PackedScene or String, aborting scene transition...")
		load_finished.emit(next_scene_path)
	
	return ""


func _get_load_status(progress: Array = []) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	

func get_transition_by_id(id: StringName) -> IndieBlueprintSceneTransitionConfiguration:
	if id.is_empty():
		return null
		
	var found_transitions: Array[IndieBlueprintSceneTransitionConfiguration] = transitions.filter(
			func(transition: IndieBlueprintSceneTransitionConfiguration): return transition and id == transition.id
		)
	
	if found_transitions.is_empty():
		return null
		
	return found_transitions.front()


func _remove_current_transition() -> void:
	if current_transition and not current_transition.is_queued_for_deletion():
		current_transition.queue_free()
	
	current_transition = null


func _filepath_is_valid(path: String) -> bool:
	return not path.is_empty() and path.is_absolute_path() and ResourceLoader.exists(path)


#region Signal callbacks
func on_in_transition_finished(in_transition_id: StringName, out_transition_id: StringName, args: Dictionary) -> void:
	var load_error: Error = ResourceLoader.load_threaded_request(next_scene_path, "", use_subthreads)
	
	if load_error != OK:
		push_error("An error %s happened when trying to load the scene %s " % [error_string(load_error), next_scene_path])
		load_finished.emit(next_scene_path)
	
	set_process(true)

	if _get_load_status(current_progress) == ResourceLoader.THREAD_LOAD_LOADED:
		is_loaded = true
		_change_to_loaded_scene(next_scene_path)
	
	if in_transition_id == out_transition_id:
		current_transition.transition_out(args.get_or_add("out", {}))
	else:
		if current_transition:
			current_transition.queue_free()
			current_transition = null
	
		var out_transition: IndieBlueprintSceneTransitionConfiguration = get_transition_by_id(out_transition_id)
		
		if out_transition:
			current_transition = out_transition.scene.instantiate()
			canvas_layer.add_child(current_transition)
			
			current_transition.transition_out(args.get_or_add("out", {}))


func on_out_transition_finished(out_transition: IndieBlueprintSceneTransition) -> void:
	out_transition.queue_free()
	transition_finished.emit(next_scene_path)


func on_transition_finished(_next_scene_path: String) -> void:
	next_scene_path = ""
	is_loaded = false
	_remove_current_transition()
	

func on_load_finished(_next_scene_path: String) -> void:
	current_progress.clear()
	is_loaded = false
	set_process(false)
#endregion
