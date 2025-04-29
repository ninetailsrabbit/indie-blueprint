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

	#add_custom_type(
		#"IndieBlueprintPixelViewportDraw",
		#"Node2D",
		#preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/debug_ui/pixel-viewport-draw.gd"),
		#preload("res://addons/ninetailsrabbit.indie_blueprint_ui/src/debug_ui/pixel_viewport_draw.svg")
	#)
	
	
func _exit_tree() -> void:
	remove_custom_type("IndieBlueprintPixelViewportDraw")
	remove_custom_type("IndieBlueprintContentWarnings")
	remove_custom_type("IndieBlueprintMouseParallax")
	remove_custom_type("IndieBlueprintResizableNinePatchRect")
