class_name Ladder3D extends Node3D

@export var climb_area: Area3D
@export var top_of_ladder: Marker3D
@export var press_to_climb: bool = false
@export var press_to_release: bool = true
@export var input_action_to_climb_ladder: StringName = InputControls.ClimbLadder
@export var input_action_to_release_ladder: StringName = InputControls.ClimbLadder


func _ready() -> void:
	climb_area.collision_layer = GameGlobals.ladders_collision_layer
	climb_area.collision_mask = 0
	climb_area.monitorable = true
	climb_area.monitoring = false
	climb_area.priority = 1
