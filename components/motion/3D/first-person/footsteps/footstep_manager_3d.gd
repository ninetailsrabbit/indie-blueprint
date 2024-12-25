@icon("res://components/motion/3D/first-person/footsteps/footstep_manager_3d.svg")
class_name FootstepsManager3D extends Node3D

## The raycast that will be responsible to detect collisions in the world that represents a ground material
@export var floor_detector_raycast: RayCast3D
## The sound queue component to play the footstep sounds
@export var sound_queue: SoundQueue
@export var default_interval_time: float = 0.6
## A dictionary that contains [StringName, FootstepSound] where the key is the material of the ground
@export var sounds_bank: Dictionary = {}


var interval_timer: Timer
var sfx_playing: bool = false


func _ready() -> void:
	assert(floor_detector_raycast is RayCast3D, "FoostepManager: This node needs a raycast to detect the ground material")
	assert(sound_queue is SoundQueue, "FoostepManager: This node needs a SoundQueue to play the footstep sounds")
	
	if sounds_bank.is_empty():
		push_error("FootstepManager: The sounds bank dictionary does not have any key/value to map the material to a sound")

	_create_interval_timer()
	

func _create_interval_timer():
	if interval_timer == null:
		interval_timer = Timer.new()
		interval_timer.name = "FoostepIntervalTimer"
		interval_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		interval_timer.autostart = false
		interval_timer.one_shot = true
		
		add_child(interval_timer)
		interval_timer.timeout.connect(on_interval_timer_timeout)


func on_interval_timer_timeout():
	sfx_playing = false
