@icon("res://components/vfx/2D/pop_effect/pop-effect.svg")
@tool
class_name PopCircleSpawner extends Node2D

signal spawn_finished

const PopCircleScene: PackedScene = preload("res://components/vfx/2D/pop_effect/pop.tscn")

@export var emitting: bool = true:
	set(value):
		if value != emitting:
			emitting = value
			
			if Engine.is_editor_hint():
				if emitting:
					spawn()
				else:
					for child in get_children():
						child.queue_free()
			
@export var amount_of_circles: int = 25
@export var times: int = 3
@export var autostart: bool = true
@export var colors: PackedColorArray = []


func _ready():
	if Engine.is_editor_hint():
		if emitting:
			spawn()
	else:
		if autostart:
			spawn()


func spawn():
	for _i: int in range(amount_of_circles):
		var circle: PopCircleEffect = PopCircleScene.instantiate() as PopCircleEffect
		circle.circle_color = colors[randi() % colors.size()]
		circle.times = times
		add_child(circle)
		circle.finished.connect(func(): circle.queue_free(), CONNECT_ONE_SHOT)

	spawn_finished.emit()
