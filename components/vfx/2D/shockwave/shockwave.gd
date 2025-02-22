@icon("res://components/vfx/2D/shockwave/shockwave.svg")
@tool
extends Node2D

signal wave_finished
signal spawn_finished

@export var emitting: bool = true:
	set(value):
		if value != emitting:
			emitting = value
			
			if emitting and Engine.is_editor_hint():
				spawn()
				
			set_process(emitting)
## When autostart is true, once is instantiated into the scene tree it will be triggered
@export var autostart: bool = true
## The times this shockwave raise
@export var times: int = 1
## The shockwave color
@export var shockwave_color: Color =  Color.WHITE
## The outline color, only applies if outline parameter it's true
@export var outline_color: Color =  Color.BLACK
## Draw and outline on the shockwave
@export var outline: bool = false
## The start radius of the shockwave circle
@export var start_radius: float = 10.0
## The end radius of the shockwave circle
@export var end_radius: float = 100.0
## The start circle width of the shockwave
@export var start_width: float = 6.0
## The end circle width of the shockwave when reachs the expansion
@export var end_width: float = 0.2
## The arc points to draw, more points more detailed arc circle
@export var arc_points: int = 24
## the speed at which the shockwave expands, higher values slow it down
@export var expand_time: float = 1.0


var timescale: float = 1.0
var timer: float = 0.0
var size: float = 1.0
var sizeT: float = 1.0 ## Intermediate value used in the code to control the animation of the shockwave's size 
var current_times: int = 0:
	set(value):
		if value != current_times:
			current_times = maxi(0, value)
			
			if current_times != 0:
				if current_times >= times:
					spawn_finished.emit()
				else:
					wave_finished.emit()
					

func _enter_tree() -> void:
	wave_finished.connect(on_shockwave_finished)
	spawn_finished.connect(on_spawn_finished)


func _ready():
	size = start_radius
	
	if Engine.is_editor_hint():
		set_process(emitting)
	else:
		set_process(autostart)


func _process(delta: float) -> void:
	delta *= timescale
	timer += 1.0 / expand_time * delta
	
	if timer >= 1.0 and current_times >= times:
		emitting = false
		
	sizeT = TorCurve.run(timer, 1.5, 0.0, 1.0)
	size = lerp(start_radius, end_radius, sizeT)
	
	if size >= end_radius:
		current_times += 1
	
	queue_redraw()


func spawn():
	current_times = 0
	emitting = true
	set_process(emitting)


func restart() -> void:
	size = start_radius
	sizeT = 1.0
	timer = 0.0
	

func on_spawn_finished() -> void:
	emitting = false
	
	
func on_shockwave_finished() -> void:
	if current_times < times:
		restart()


func _draw():
	var smoothness_factor = lerp(start_width, end_width, sizeT)
	
	if outline:
		draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, outline_color * Color(0, 0, 0, 1.0 - pow(sizeT, 4.0) ), min(smoothness_factor + 8.0, smoothness_factor * 4.0), false)
	draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, shockwave_color * Color(1.0, 1.0, 1.0, 1.0 - pow(sizeT, 4.0) ), smoothness_factor, false)
