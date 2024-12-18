class_name InventoryItem3D extends Node3D

const GroupName: StringName = &"item"

signal collected
signal used
signal dropped
signal consumed
signal stack_changed(from: int, to: int)

@export var id: StringName = ""
@export var item_name: StringName = ""
@export_multiline var description: String = ""
@export var name_translation_key: StringName = ""
@export var description_translation_key: StringName = ""
@export var mesh_node: Node3D
@export var mesh: MeshInstance3D
@export var interactable: Interactable3D
@export var collectable: bool = true
@export var stackable: bool = false
@export var single_use: bool = false
@export var can_be_dropped: bool = true
@export var size_in_inventory: int = 1
@export var max_stack_amount: int = 1

var on_inventory: bool = false
var stack_amount: int = 0:
	set(value):
		if value != stack_amount:
			var previous_value: int = stack_amount
			stack_amount = clampi(value, 0, max_stack_amount)
			stack_changed.emit(previous_value, stack_amount)
			
			
func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if interactable:
		interactable.interacted.connect(on_item_interacted)
		interactable.focused.connect(on_item_focused)
		interactable.unfocused.connect(on_item_unfocused)


func add_stack_amount(amount: int) -> void:
	stack_amount += amount


func can_be_stacked() -> bool:
	return stackable and stack_amount < max_stack_amount


#region Signal callbacks
func on_item_interacted() -> void:
	print("interacted with item ", id)


func on_item_focused() -> void:
	print("focused item ", id)
	

func on_item_unfocused() -> void:
	print("unfocused item ", id)

#endregion
