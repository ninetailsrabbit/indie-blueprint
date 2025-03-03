@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"IndieBlueprintDiceRoller",
		"Node",
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/probability/dice/dice_roller.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/probability/dice/dice_roller.svg")
	)
	
	add_custom_type(
		"IndieBlueprintHealth",
		"Node",
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/health/health.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/health/health.svg")
	)
	
	add_custom_type(
		"IndieBlueprintLootTable",
		"Node",
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/probability/loot/loot_table.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/probability/loot/loot.svg")
	)
	add_autoload_singleton("IndieBlueprintLootManager", "res://addons/ninetailsrabbit.indie_blueprint_rpg/src/probability/loot/loot_manager.gd")
	
	add_custom_type(
		"IndieBlueprintTurnitySocket",
		"Node",
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/turns/turnity_socket.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_rpg/src/turns/turnity.svg")
	)
	add_autoload_singleton("IndieBlueprintTurnityManager", "res://addons/ninetailsrabbit.indie_blueprint_rpg/src/turns/turnity_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintTurnityManager")
	remove_custom_type("IndieBlueprintTurnitySocket")
	
	remove_autoload_singleton("IndieBlueprintLootManager")
	remove_custom_type("IndieBlueprintLootTable")
	
	remove_custom_type("IndieBlueprintHealth")
	remove_custom_type("IndieBlueprintDiceRoller")
