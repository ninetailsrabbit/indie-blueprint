class_name IndieBlueprintLoadingScreen extends Control

signal failed(status: ResourceLoader.ThreadLoadStatus)
signal finished(next_scene: PackedScene)

@export_file var next_scene_path: String:
	set(new_path):
		if new_path != next_scene_path:
			next_scene_path = new_path
			
		set_process(loading and not next_scene_path.is_empty())
@export var use_subthreads: bool = false
@export var progress_smooth_factor: float = 5.0

@onready var current_progress: Array = []
@onready var scene_load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS

var current_progress_value: float = 0.0:
	set(value):
		current_progress_value = clampf(value, 0.0, 100.0)
		
var loading: bool = false:
	set(value):
		if value != loading:
			loading = value
			
		set_process(loading and not next_scene_path.is_empty())


func _ready() -> void:
	set_process(false)
	assert(_filepath_is_valid(next_scene_path), "The loading screen does not have a valid scene path or it's empty -> %s" % next_scene_path)
	
	var load_error: Error = ResourceLoader.load_threaded_request(next_scene_path, "", use_subthreads)
	
	if load_error != OK:
		push_error("An error %s happened when trying to load the scene %s " % [error_string(load_error), next_scene_path])
		return
		
	loading = true
	set_process(loading)


func _process(delta):
	if loading:
		scene_load_status = ResourceLoader.load_threaded_get_status(next_scene_path, current_progress)
		current_progress_value = lerpf(current_progress_value, current_progress[0] * 100.0, delta * progress_smooth_factor)
		
		match scene_load_status:
			ResourceLoader.THREAD_LOAD_LOADED:
				if snappedf(current_progress_value, 0.1) >= 100.0:
					finished.emit(ResourceLoader.load_threaded_get(next_scene_path))
					loading = false
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				loading = true
			[ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
				push_error("IndieBlueprintLoadingScreen: The resource load failed with status %s " % scene_load_status)
				loading = false
				failed.emit(scene_load_status)


func _filepath_is_valid(path: String) -> bool:
	return not path.is_empty() and path.is_absolute_path() and ResourceLoader.exists(path)
