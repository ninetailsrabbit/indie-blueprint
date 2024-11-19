extends Node

@export_file(".tscn") var next_scene: String = ""

@onready var content_warnings: ContentWarnings = $ContentWarnings

func _ready() -> void:
	content_warnings.all_content_warnings_displayed.connect(on_all_content_warnings_displayed)
	
	var roller = DiceRoller.new()
	add_child(roller)
	
	print(roller.roll_dices_detailed(3, 6))
	print(roller.roll_dices_detailed(5, 8))
	print(roller.roll_dices_detailed(7, 20))


func on_all_content_warnings_displayed() -> void:
	if not next_scene.is_empty():
		SceneTransitionManager.transition_to_scene(next_scene)
