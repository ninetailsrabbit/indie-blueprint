class_name SpinCard extends Node2D

const GroupName: StringName = &"spin_cards"

signal maximum_ticks_reached

@export var data: SpinCardResource

@onready var tick_detector: Area2D = $TickDetector
@onready var orbit_component: OrbitComponent2D = $OrbitComponent2D


var disabled: bool = false:
	set(value):
		if value != disabled:
			disabled = value
			tick_detector.monitorable = not disabled
		
var current_damage: float = 0
var current_elemental_damage: float = 0

var current_ticks: int = 0:
	set(value):
		if value != current_ticks:
			current_ticks = maxi(0, value)
			
			if data.amount_of_ticks != 0 and current_ticks >= data.amount_of_ticks:
				maximum_ticks_reached.emit()


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	assert(data != null, "SpinCard: This spin card %s needs a SpinCardResource to be valid" % name)
	
	current_damage = data.base_damage
	current_damage = data.base_elemental_damage
	
	
func enable() -> void:
	disabled = false


func disable() -> void:
	disabled = true


func _prepare_tick_detector() -> void:
	tick_detector.monitorable = true
	tick_detector.monitoring = false
	tick_detector.collision_layer = GameGlobals.playing_cards_collision_layer
	tick_detector.collision_mask = 0
	
