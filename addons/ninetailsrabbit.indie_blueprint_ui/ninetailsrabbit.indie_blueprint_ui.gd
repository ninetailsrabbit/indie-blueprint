@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"IndieBlueprintResizableNinePatchRect", 
		"NinePatchRect",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/resizable_ninepatchrect/resizable_ninepatchrect.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/resizable_ninepatchrect/box_transparent.png")
	)
	
	add_custom_type(
		"IndieBlueprintMouseParallax",
		"Control",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/mouse/parallax/mouse_parallax.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/mouse/parallax/mouse_parallax.svg")
	)
	
	add_custom_type(
		"IndieBlueprintContentWarnings",
		"Control",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/content_warning/content_warning_displayer.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/content_warning/content_warning.svg")
	)
	
	add_custom_type(
		"IndieBlueprintPixelViewportDraw",
		"Node2D",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/debug_ui/pixel-viewport-draw.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/debug_ui/pixel_viewport_draw.svg")
	)

	add_custom_type(
		"IndieBlueprintMenuBackButton",
		"Button",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/menus/menu_back_button.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/menus/back_button.svg")
	)
	
	add_custom_type(
		"IndieBlueprintProjectVersion",
		"Label",
		preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/information/project_version.gd"),
		null
	)
	
	add_autoload_singleton("IndieBlueprintUIAnimation", "res://addons/ninetailsrabbit.indie_blueprint_ui/src/animations/ui_animation.gd")
	
	
func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintUIAnimation")
	remove_custom_type("IndieBlueprintProjectVersion")
	remove_custom_type("IndieBlueprintMenuBackButton")
	remove_custom_type("IndieBlueprintPixelViewportDraw")
	remove_custom_type("IndieBlueprintContentWarnings")
	remove_custom_type("IndieBlueprintMouseParallax")
	remove_custom_type("IndieBlueprintResizableNinePatchRect")
