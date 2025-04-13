@icon("res://components/motion/3D/first_person/footsteps/footstep_manager_3d.svg")
class_name FootstepsManager3D extends Node3D

signal added_footstep_sound(footstep_sound: FootstepSound)
signal removed_footstep_sound(footstep_sound: FootstepSound)

## The raycast that will be responsible to detect collisions in the world that represents a ground material
@export var floor_detector_raycast: RayCast3D
## The sound queue component to play the footstep sounds
@export var sound_queue: IndieBlueprintSoundQueue
## The default interval to wait between footsteps
@export var default_interval_time: float = 0.6
## The meta tag where the ground material information is saved. This allows to support Area3D nodes also.
@export var material_meta_tag: StringName = &"ground_material"
## A dictionary that contains [StringName, FootstepSound] where the key is the material of the ground
@export var sounds_bank: Array[FootstepSound] = []


var interval_timer: Timer
var sfx_playing: bool = false


func _ready() -> void:
	if floor_detector_raycast == null:
		floor_detector_raycast = IndieBlueprintNodeTraversal.first_node_of_type(self, RayCast3D.new())
		
	if sound_queue == null:
		sound_queue = IndieBlueprintNodeTraversal.first_node_of_custom_class(self, IndieBlueprintSoundQueue)
		
	assert(floor_detector_raycast is RayCast3D, "FoostepManager: This node needs a raycast to detect the ground material")
	assert(sound_queue is IndieBlueprintSoundQueue, "FoostepManager: This node needs a SoundQueue to play the footstep sounds")
	
	if sounds_bank.is_empty():
		push_warning("FootstepManager: The sounds bank dictionary does not have any key/value to map the material to a sound")
	
	floor_detector_raycast.enabled = sounds_bank.size() > 0
	
	_create_interval_timer()
	
	added_footstep_sound.connect(on_added_foostep_sound)
	removed_footstep_sound.connect(on_removed_foostep_sound)
	

func footstep(
	interval_time: float = default_interval_time, 
	footstep_type: FootstepSound.FootstepType = FootstepSound.FootstepType.Ground
) -> void:
	if sounds_bank.is_empty() \
		or sfx_playing \
		or interval_timer.time_left > 0 \
		or not floor_detector_raycast.enabled:
		return
		
	var collider = floor_detector_raycast.get_collider()
	
	if collider != null and collider.has_meta(material_meta_tag):
		var material_id: StringName = collider.get_meta(material_meta_tag)
		var found_sounds: Array[FootstepSound] = sounds_bank\
			.filter(func(sound: FootstepSound): return sound.material == material_id)
		var footstep_sound: FootstepSound
		
		if found_sounds.size() > 0:
			footstep_sound = found_sounds.front() as FootstepSound
			
			match footstep_type:
				FootstepSound.FootstepType.Ground:
					if footstep_sound.ground_stream:
						interval_timer.start(interval_time)
						sfx_playing = true
						
						sound_queue.audio_stream = footstep_sound.ground_stream
						sound_queue.play_sound_with_pitch_range(
							footstep_sound.ground_min_pitch_range, 
							footstep_sound.ground_max_pitch_range
							)
						
				FootstepSound.FootstepType.Land:
					if footstep_sound.land_stream:
						interval_timer.start(interval_time)
						sfx_playing = true
						
						sound_queue.audio_stream = footstep_sound.land_stream
						sound_queue.play_sound_with_pitch_range(
							footstep_sound.land_min_pitch_range, 
							footstep_sound.land_max_pitch_range
							)
				FootstepSound.FootstepType.Jump:
					if footstep_sound.jump_stream:
						interval_timer.start(interval_time)
						sfx_playing = true
						
						sound_queue.audio_stream = footstep_sound.jump_stream
						sound_queue.play_sound_with_pitch_range(
							footstep_sound.jump_min_pitch_range, 
							footstep_sound.jump_max_pitch_range
							)
			

func add_footstep_sound(footstep_sound: FootstepSound) -> void:
	if sounds_bank.has(footstep_sound):
		return
		
	sounds_bank.append(footstep_sound)
	added_footstep_sound.emit(footstep_sound)
	
	
func remove_footstep_sound(footstep_sound: FootstepSound) -> void:
	if sounds_bank.has(footstep_sound):
		removed_footstep_sound.emit(footstep_sound)
		
	sounds_bank.erase(footstep_sound)
	

func _create_interval_timer():
	if interval_timer == null:
		interval_timer = IndieBlueprintTimeHelper.create_physics_timer(default_interval_time, false, true)
		interval_timer.name = "FoostepIntervalTimer"
		
		add_child(interval_timer)
		interval_timer.timeout.connect(on_interval_timer_timeout)


func on_interval_timer_timeout():
	sfx_playing = false


func on_added_foostep_sound(_footstep_sound: FootstepSound) -> void:
	floor_detector_raycast.enabled = sounds_bank.size() > 0
	
	
func on_removed_foostep_sound(_footstep_sound: FootstepSound) -> void:
	floor_detector_raycast.enabled = sounds_bank.size() > 0
