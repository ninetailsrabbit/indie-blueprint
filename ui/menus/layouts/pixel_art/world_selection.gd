class_name WorldSelection extends Control

@export var preview_empty_slots: int = 4
@export var main_game_scene: PackedScene

@onready var world_save_slots: VBoxContainer = %WorldSaveSlots
@onready var new_save_screen: NewSaveScreen = $NewSaveScreen
@onready var back_button: MenuBackButton = $MarginContainer/BackButton


func _ready() -> void:
	IndieBlueprintNodeRemover.free_children(world_save_slots)
	
	await get_tree().process_frame
	
	display_saved_games()
	
	new_save_screen.visibility_changed.connect(on_new_save_screen_visibility_changed)
	new_save_screen.created_new_save.connect(on_created_new_save)


func display_saved_games() -> void:
	var saved_game_index: int = 0
	
	for saved_game: IndieBlueprintSavedGame in IndieBlueprintSaveManager.list_of_saved_games.values():
		saved_game_index += 1
		var world_save_slot: WorldSaveSlotPanel = Preloader.WorldSaveSlotPanelScene.instantiate()
		world_save_slots.add_child(world_save_slot)
		
		world_save_slot.set_list_number(saved_game_index)
		world_save_slot.display_saved_game(saved_game)
		world_save_slot.selected.connect(on_save_slot_selected.bind(world_save_slot))
	
	
	for index in preview_empty_slots:
		var current_index: int = IndieBlueprintSaveManager.list_of_saved_games.size() + (index + 1)
		var world_save_slot: WorldSaveSlotPanel = Preloader.WorldSaveSlotPanelScene.instantiate()
		
		world_save_slots.add_child(world_save_slot)
		world_save_slot.set_list_number(current_index)
		world_save_slot.selected.connect(on_save_slot_selected.bind(world_save_slot))
		
		
func on_save_slot_selected(world_save_slot: WorldSaveSlotPanel) -> void:
	if world_save_slot.saved_game:
		IndieBlueprintSaveManager.make_current(world_save_slot.saved_game)
		IndieBlueprintSceneTransitioner.transition_to(main_game_scene)
	else:
		new_save_screen.show()


func on_created_new_save(_new_save: IndieBlueprintSavedGame) -> void:
	IndieBlueprintSceneTransitioner.transition_to(main_game_scene)


func on_new_save_screen_visibility_changed() -> void:
	await get_tree().physics_frame
	
	if new_save_screen.visible:
		back_button.disable()
	else:
		back_button.enable()
