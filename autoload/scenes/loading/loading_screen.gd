class_name LoadingScreen extends CanvasLayer

signal failed(status: ResourceLoader.ThreadLoadStatus)
signal finished

@export_file var next_scene_path: String
@export var use_subthreads := false

@onready var progress := []
@onready var scene_load_status := ResourceLoader.THREAD_LOAD_IN_PROGRESS

var current_progress_value := 0.0
var smooth_value := 0.0 ## Use this to update values on progress bar nodes
var loading := false


func _ready():
	next_scene_path = SceneTransitionManager.next_scene_path
	
	finished.connect(on_finished)
	failed.connect(on_failed)
	
	if not next_scene_path.is_empty() and next_scene_path.is_absolute_path():
		ResourceLoader.load_threaded_request(next_scene_path, "", use_subthreads)
		loading = true
	else:
		push_error("The scene path %s is not valid to load" % next_scene_path)



func _process(delta):
	if loading:
		var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
		
		## This value can be assigned to some progress bar or progress indicator
		smooth_progress_value(delta)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			finished.emit()
		if status == ResourceLoader.THREAD_LOAD_FAILED || ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			failed.emit(status)


## Useful to display current progress smoothly to the user
func smooth_progress_value(delta) -> float:
	if not progress.is_empty() and progress[0] >= current_progress_value:
		current_progress_value = progress[0]
		
	if smooth_value < current_progress_value:
		smooth_value = lerp(smooth_value, current_progress_value, delta)
	
	smooth_value += delta * 0.2 * (3.0 if current_progress_value >= 1.0 else clamp(0.9 - smooth_value, 0, 1.0))
	
	return smooth_value


func _reset():
	progress.clear()
	current_progress_value = 0.0
	smooth_value = 0.0
	loading = false
	
	
func on_finished():
	SceneTransitionManager.transition_to_scene(
		ResourceLoader.load_threaded_get(next_scene_path), 
		false,
		SceneTransitionManager.previous_animations[1],
		SceneTransitionManager.previous_animations[0],
	)
	SceneTransitionManager.next_scene_path = ""
	
	_reset()

func on_failed(status: ResourceLoader.ThreadLoadStatus):
	_reset()
	push_error("LoadingScreen: The resource load failed with status %s " % status)
