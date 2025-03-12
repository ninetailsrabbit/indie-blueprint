@icon("res://components/collisions/hitbox_hurtbox/hurtbox.svg")
class_name Hurtbox2D extends Area2D

signal hitbox_detected(hitbox: Hitbox2D)


func _init() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = IndieBlueprintGameGlobals.hitboxes_collision_layer
	

func _ready():
	area_entered.connect(on_area_entered)


func enable():
	set_deferred("monitoring", true)
	

func disable():
	set_deferred("monitoring", false)


func on_area_entered(hitbox: Hitbox2D) -> void:
	hitbox_detected.emit(hitbox)
