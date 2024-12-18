@icon("res://components/rpg/inventory/3D/circular_inventory.svg")
class_name CircularInventory3D extends Node3D

signal current_item_changed(item: InventoryItem3D)
signal added_item
signal add_item_request_denied(item: InventoryItem3D)
signal item_delete_requested(item: InventoryItem3D)
signal item_deleted(item: InventoryItem3D)

@export var next_item_left_action: StringName = InputControls.ItemLeft
@export var next_item_right_action: StringName = InputControls.ItemRight
@export var toggle_inventory_action: StringName = InputControls.ToggleInventory
@export var max_items: int = 6
@export var radius: float = 3.0: 
	set(value):
		radius = maxf(0, value)
		
		if is_node_ready():
			adjust_to_camera(radius, distance_from_camera)
@export var next_item_spin_duration: float = 0.3
@export var distance_from_camera: float = 0.5
@export var items_can_be_deleted: bool = false
@export var item_delete_needs_confirmation: bool = true
@export var delete_item_input_actions: Array[String]= ["ui_accept"]

@onready var camera_3d: Camera3D = $Camera3D
@onready var items_container: Node3D = $Items

var inventory: Array[InventoryItem3D] = []
var current_item: Dictionary = {"item": null, "requested_to_delete": false}


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed(toggle_inventory_action):
		visible = !visible
		
	if visible:
		handle_movement()
		delete_current_item()
		
	
func _ready():
	#hide()
	
	adjust_items()
	adjust_to_camera()
	
	if inventory.size() > 0:
		current_item.item = inventory.front()
	
	items_container.child_entered_tree.connect(on_item_child_added)
	items_container.child_exiting_tree.connect(on_item_child_deleted)
	visibility_changed.connect(on_visibility_changed)


func add_item(item: InventoryItem3D, amount: int = 1) -> void:
	if inventory.has(item) and item.can_be_stacked():
		item.add_stack_amount(amount)
	elif not inventory.has(item) and inventory.size() < max_items:
		items_container.add_child(item)
	else:
		add_item_request_denied.emit(item)


func get_item_from_tree(idx: int) -> InventoryItem3D:
	return items_container.get_child(idx)


func get_item_by_index(idx: int) -> InventoryItem3D:
	var item_index: int = inventory.find(idx)
	
	if item_index != -1:
		return inventory[idx]
		
	return null


func get_item_by_id(id: StringName) -> InventoryItem3D:
	var items: Array[InventoryItem3D] = inventory.filter(func(item: InventoryItem3D): return item.id == id)
	
	if items.is_empty():
		return null
		
	return items.front()


func adjust_items() -> void:
	inventory.clear()

	var number_of_items = mini(max_items, items_container.get_child_count())
	
	for index in number_of_items:
		var item: InventoryItem3D = items_container.get_child(index)
		
		var angle: float = deg_to_rad(360.0 / number_of_items * index) + PI / 2.0
		var x: float = radius * cos(angle)
		var z: float = radius * sin(angle) 
		
		item.position = Vector3(x, 0, z)
		
		if not inventory.has(item):
			inventory.append(item)


func adjust_to_camera(_radius: int = radius, _distance_from_camera: float = distance_from_camera):
	items_container.global_position.z = (_radius + _distance_from_camera) * -sign(_radius)


func next_item(direction: Vector2):
	var inventory_size: int = inventory.size()
	
	if inventory_size > 1:    
		var angleIncrement: float = 360.0 / inventory_size
		
		for index in range(inventory_size):
			var item = inventory[index]
			var angle: float = deg_to_rad(angleIncrement * (index + direction.x)) + PI / 2.0

			var tween: Tween = create_tween()
			tween.tween_property(item, "position", Vector3(radius * cos(angle), 0, radius * sin(angle)), next_item_spin_duration)
			
		if direction.is_equal_approx(Vector2.RIGHT):
			rotate_array_radial_right(inventory)
			current_item.item = inventory.back()
			current_item.requested_to_delete = false
			current_item_changed.emit(current_item.item)
		
		if direction.is_equal_approx(Vector2.LEFT):
			rotate_array_radial_left(inventory)
			current_item.item = inventory.back()
			current_item.requested_to_delete = false
			current_item_changed.emit(current_item.item)
			


# Rotate the array radially to the right
func rotate_array_radial_right(array):
	var last_element = array.pop_back()
	array.insert(0, last_element)

# Rotate the array radially to the left
func rotate_array_radial_left(array):
	var first_element = array.pop_front()
	array.append(first_element)
	
	
func handle_movement():
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_just_pressed(next_item_left_action):
			direction = Vector2.LEFT
	elif Input.is_action_just_pressed(next_item_right_action):
			direction = Vector2.RIGHT
		
	if direction in VectorHelper.horizontal_directions_v2:
		next_item(direction)

	
func delete_current_item():
	if items_can_be_deleted and InputHelper.is_any_action_just_pressed(delete_item_input_actions):
		if current_item.item and item_delete_needs_confirmation and not current_item.requested_to_delete:
			item_delete_requested.emit(current_item.item)
			current_item.requested_to_delete = true
			return
		
		if current_item.item or (current_item.item and item_delete_needs_confirmation and current_item.requested_to_delete):
			inventory.erase(current_item.item)
			item_deleted.emit(current_item.item)
			
			next_item(Vector2.RIGHT)
			
			current_item.item.queue_free()
			current_item.item = null if inventory.is_empty() else inventory.back()
			current_item.requested_to_delete = false
			
	
func on_item_child_added(child: Node) -> void:
	if child is InventoryItem3D:
		adjust_items()
		added_item.emit(child)


func on_item_child_deleted(child: Node) -> void:
	if child is InventoryItem3D:
		adjust_items()
		item_deleted.emit(child)
	

func on_visibility_changed() -> void:
	set_process_unhandled_input(visible)
	
	## Here if any pointer exists, can be hidded here
	if visible:
		camera_3d.current = false
	else:
		camera_3d.make_current()
