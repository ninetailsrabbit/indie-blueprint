@icon("res://components/vfx/2D/pop_effect/pop-effect.svg")
class_name PopCircleSpawner extends Node2D

signal spawn_finished

const PopCircleScene: PackedScene = preload("res://components/vfx/2D/pop_effect/pop.tscn")

@export var amount_of_circles: int = 25
@export var autostart: bool = true


func _ready():
	if autostart:
		spawn()


func spawn():
	for i in range(amount_of_circles):
		add_child(PopCircleScene.instantiate() as PopCircleEffect)

	spawn_finished.emit()
