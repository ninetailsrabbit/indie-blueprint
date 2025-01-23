@icon("res://components/vfx/2D/shockwave/shockwave.svg")
extends Node2D

## When autostart is true, once is instantiated into the scene tree it will be triggered
@export var autostart: bool = true
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


func _ready():
	size = start_radius
	set_process(autostart)


func _process(delta: float) -> void:
	delta *= timescale
	timer += 1.0 / expand_time * delta
	
	if timer >= 1.0:
		queue_free()
		
	sizeT = TorCurve.run(timer, 1.5, 0.0, 1.0)
	size = lerp(start_radius, end_radius, sizeT)
	
	queue_redraw()
	

func spawn():
	set_process(true)
	
	
func _draw():
	var smoothness_factor = lerp(start_width, end_width, sizeT)
	
	if outline:
		draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, outline_color * Color(0, 0, 0, 1.0 - pow(sizeT, 4.0) ), min(smoothness_factor + 8.0, smoothness_factor * 4.0), false)
	draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, shockwave_color * Color(1.0, 1.0, 1.0, 1.0 - pow(sizeT, 4.0) ), smoothness_factor, false)
