@icon("res://components/interaction/2D/interactables/interactable_2d.svg")
class_name IndieBlueprintInteractable2D extends Area2D

const GroupName: StringName = &"interactables"

signal interacted
signal canceled_interaction
@warning_ignore("unused_signal")
signal focused
@warning_ignore("unused_signal")
signal unfocused
signal interaction_limit_reached


@export var activate_on_start: bool = true
@export var disable_after_interaction: bool = false
@export var number_of_times_can_be_interacted: int = 0
@export var change_cursor_on_focus: bool = true
@export var change_screen_pointer_focus: bool = true
@export var lock_player_on_interact: bool = false
@export_group("Information")
@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var title_translation_key: String = ""
@export var description_translation_key: String = ""


var can_be_interacted: bool = true
var times_interacted: int = 0:
	set(value):
		var previous_value = times_interacted
		times_interacted = value
		
		if previous_value != times_interacted && times_interacted >= number_of_times_can_be_interacted:
			interaction_limit_reached.emit()
			deactivate()


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if activate_on_start:
		activate()
	
	interacted.connect(on_interacted)
	canceled_interaction.connect(on_canceled_interaction)
	
	times_interacted = 0
	
	
func activate() -> void:
	priority = 3
	collision_layer = IndieBlueprintGameGlobals.interactables_collision_layer
	collision_mask = 0
	monitorable = true
	monitoring = false
	
	can_be_interacted = true
	
	
func deactivate() -> void:
	priority = 0
	collision_layer = 0
	monitorable = false
	
	can_be_interacted = false

			
#region Signal callbacks
func on_interacted() -> void:
	if disable_after_interaction:
		deactivate()
	

func on_canceled_interaction() -> void:
	if times_interacted < number_of_times_can_be_interacted:
		activate()
		
#endregion
