@tool
class_name IndieBlueprintSwingComponent2D extends Node2D

signal started
signal stopped

## The target where the swing will be applied
@export var target: Node2D
@export var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			if value:
				started.emit()
			else:
				stopped.emit()
				
		set_process(active)
## The frequency of the swing, greater values, swing faster.
@export var frequency: float = 1.0
## The amplitude of the angle while swinging, more the amplitude more the swing.
@export_range(0, PI / 2) var amplitude: float = PI / 4
@export_group("Decay")
@export var apply_decay: bool = false
## The amount where the decay will be applied, a greater amount means more time swinging.
@export var amount: float = 10.0
## The decay value reduce the amount value until reachs 0
@export_range(0.9, 1.0) var decay: float = 0.99


var time: float = 0.0


func _ready():
	if target == null:
		target = get_parent()
	
	assert(target != null and target is Node2D, "IndieBlueprintSwingComponent2D: This component needs a Node2D target to apply the swing rotation effect")


func _process(delta):
	time += delta
	
	if apply_decay:
		amount *= decay
	
	target.rotation = sin(time * frequency) * amplitude * (amount if apply_decay else 1.0)
	

func start():
	active = true
	
	
func stop():
	active = false
