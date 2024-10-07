@icon("res://autoload/camera/camera_shifter.svg")
extends Node


signal transition_2d_started(from: Camera2D, to: Camera2D, duration: float)
signal transition_2d_finished(from: Camera2D, to: Camera2D, duration: float)
signal transition_3d_started(from: Camera3D, to: Camera3D, duration: float)
signal transition_3d_finished(from: Camera3D, to: Camera3D, duration: float)

@export var transition_duration: float = 1.5
@export var remove_last_transition_step_2d_on_back: bool = false
@export var remove_last_transition_step_3d_on_back: bool = false

@onready var global_camera_2d: Camera2D = $GlobalCamera2D
@onready var global_camera_3d: Camera3D = $GlobalCamera3D

var transition_steps_2d: Array[TransitionStep2D] = []
var transition_steps_3d: Array[TransitionStep3D] = []

var transition_tween_2d: Tween
var transition_tween_3d: Tween


func _ready():
	assert(global_camera_2d is Camera2D, "The autoload GlobalCameraTransition needs a Camera2D in scene to allow the transitions")
	assert(global_camera_3d is Camera3D, "The autoload GlobalCameraTransition needs a Camera3D in scene to allow the transitions")
	
	global_camera_2d.enabled = false
	global_camera_3d.clear_current()
	
	
func transition_to_requested_camera_2d(from: Camera2D, to: Camera2D, duration: float = transition_duration, record_transition: bool = true):
	if is_transitioning_2d():
		return
	
	transition_2d_started.emit(from, to, duration)

	global_camera_2d.enabled = true
	global_camera_2d.make_current()
	
	global_camera_2d.offset = from.offset
	global_camera_2d.global_transform = from.global_transform
	global_camera_2d.anchor_mode = from.anchor_mode
	global_camera_2d.zoom = from.zoom
	global_camera_2d.process_callback = from.process_callback
	global_camera_2d.limit_smoothed = from.limit_smoothed
	global_camera_2d.position_smoothing_enabled = from.position_smoothing_enabled
	global_camera_2d.rotation_smoothing_enabled = from.rotation_smoothing_enabled
	
	transition_tween_2d = create_tween()
	transition_tween_2d.set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	transition_tween_2d.tween_property(global_camera_2d, "global_transform", to.global_transform, duration).from(global_camera_2d.global_transform)
	transition_tween_2d.tween_property(global_camera_2d, "zoom", to.zoom, duration).from(global_camera_2d.zoom)
	
	await transition_tween_2d.finished
	
	if record_transition:
		transition_steps_2d.append(TransitionStep2D.new(from, to, duration))
	
	to.make_current()
	transition_2d_finished.emit(from, to, duration)
	
	global_camera_2d.enabled = false



func transition_to_requested_camera_3d(from: Camera3D, to: Camera3D, duration: float = transition_duration, record_transition: bool = true):
	if is_transitioning_3d():
		return
	
	transition_3d_started.emit(from, to, duration)
	
	global_camera_3d.process_mode = Node.PROCESS_MODE_INHERIT
	global_camera_3d.make_current()
	global_camera_3d.projection = to.projection
	
	match to.projection:
		Camera3D.PROJECTION_ORTHOGONAL:
			global_camera_3d.size = from.size
		Camera3D.PROJECTION_FRUSTUM:
			global_camera_3d.frustum_offset = from.frustum_offset
		Camera3D.PROJECTION_PERSPECTIVE:
			global_camera_3d.fov = from.fov
		
	global_camera_3d.far = from.far
	global_camera_3d.near = from.near
	global_camera_3d.keep_aspect = from.keep_aspect
	global_camera_3d.fov = from.fov
	global_camera_3d.cull_mask = from.cull_mask
	global_camera_3d.global_transform = from.global_transform
	
	global_camera_3d.environment = from.environment
	global_camera_3d.attributes = from.attributes
	global_camera_3d.doppler_tracking = from.doppler_tracking
	
	transition_tween_3d = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	transition_tween_3d.tween_property(global_camera_3d, "global_transform", to.global_transform, duration).from(global_camera_3d.global_transform)
	
	match to.projection:
		Camera3D.PROJECTION_ORTHOGONAL:
			transition_tween_3d.tween_property(global_camera_3d, "size", to.size, duration).from(global_camera_3d.size)
		Camera3D.PROJECTION_FRUSTUM:
			transition_tween_3d.tween_property(global_camera_3d, "frustum_offset", to.frustum_offset, duration).from(global_camera_3d.frustum_offset)
		Camera3D.PROJECTION_PERSPECTIVE:
			transition_tween_3d.tween_property(global_camera_3d, "fov", to.fov, duration).from(global_camera_3d.fov)
	
	await transition_tween_3d.finished
	
	if record_transition:
		transition_steps_3d.append(TransitionStep3D.new(from, to, duration))
	
	to.make_current()
	transition_3d_finished.emit(from, to, duration)
	
	global_camera_3d.clear_current()


func transition_to_next_camera_2d(to: Camera2D, duration: float = transition_duration):
	if(transition_steps_2d.is_empty() or is_transitioning_2d()):
		return
		
	var last_step: TransitionStep2D = transition_steps_2d.back()
	
	transition_to_requested_camera_2d(last_step.to, to, duration)


func transition_to_previous_camera_2d(delete_step: bool = remove_last_transition_step_2d_on_back):
	if(transition_steps_2d.is_empty() or is_transitioning_2d()):
		return
		
	var last_step: TransitionStep2D = transition_steps_2d.pop_back() if delete_step else transition_steps_2d.back()
	
	transition_to_requested_camera_2d(last_step.to, last_step.from, last_step.duration, false)


func transition_to_first_camera_through_all_steps_2d(clean_steps_on_finished: bool = false):
	var transition_steps = transition_steps_2d.duplicate()
	transition_steps.reverse()
	
	for step in transition_steps:
		transition_to_requested_camera_2d(step.to, step.from, step.duration, false)
		await transition_2d_finished
		
	if clean_steps_on_finished:
		transition_steps_2d.clear()
	
	
func transition_to_next_camera_3d(to: Camera3D, duration: float = transition_duration):
	if(transition_steps_3d.is_empty() or is_transitioning_3d()):
		return
		
	var last_step: TransitionStep3D = transition_steps_3d.back()
	
	transition_to_requested_camera_3d(last_step.to, to, duration)


func transition_to_previous_camera_3d(delete_step: bool = remove_last_transition_step_3d_on_back):
	if(transition_steps_3d.is_empty() or is_transitioning_3d()):
		return
		
	var last_step: TransitionStep3D = transition_steps_3d.pop_back() if delete_step else transition_steps_3d.back()
	
	transition_to_requested_camera_3d(last_step.to, last_step.from, last_step.duration, false)
	

func transition_to_first_camera_through_all_steps_3d(clean_steps_on_finished: bool = false):
	var transition_steps = transition_steps_3d.duplicate()
	transition_steps.reverse()
	
	for step in transition_steps:
		transition_to_requested_camera_3d(step.to, step.from, step.duration, false)
		await transition_3d_finished
		
	if clean_steps_on_finished:
		transition_steps_3d.clear()


func is_transitioning_2d() -> bool:
	return transition_tween_2d and transition_tween_2d.is_running()
	

func is_transitioning_3d() -> bool:
	return transition_tween_3d and transition_tween_3d.is_running()
	
	
func on_transition_camera_2d_requested(from: Camera2D, to: Camera2D, duration: float = transition_duration):
	transition_to_requested_camera_2d(from, to, duration)


func on_transition_camera_3d_requested(from: Camera3D, to: Camera3D, duration: float = transition_duration):
	transition_to_requested_camera_3d(from, to, duration)


class TransitionStep2D:
	var from: Camera2D
	var to: Camera2D
	var duration: float
	
	func _init(_from: Camera2D, _to: Camera2D, _duration: float):
		from = _from
		to = _to
		duration = absf(_duration)


class TransitionStep3D:
	var from: Camera3D
	var to: Camera3D
	var duration: float
	
	func _init(_from: Camera3D, _to: Camera3D, _duration: float):
		from = _from
		to = _to
		duration = absf(_duration)
