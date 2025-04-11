@icon("res://components/interaction/3D/visuals/visual_hint_3d.svg")
class_name IndieBlueprintVisualHint3D extends Node3D

@export var interactable: Interactable3D
@export_category("Image")
@export var image_hint: Sprite3D
@export var image_hint_texture: CompressedTexture2D
@export var image_hint_focus_texture: CompressedTexture2D
## The distance in meters at which the visual runway can be seen
@export var image_hint_visible_distance: float = 3.0
@export var image_billboard_mode: BaseMaterial3D.BillboardMode = BaseMaterial3D.BillboardMode.BILLBOARD_FIXED_Y
@export_category("Text")
@export var text_hint: Label3D
## The distance in meters at which the text runway can be seen
@export var text_hint_visible_distance: float = 3.0
@export var text_billboard_mode: BaseMaterial3D.BillboardMode = BaseMaterial3D.BillboardMode.BILLBOARD_FIXED_Y


func _ready() -> void:
	if image_hint == null:
		image_hint = IndieBlueprintNodeTraversal.first_node_of_type(self, Sprite3D.new())
		
	if text_hint == null:
		text_hint = IndieBlueprintNodeTraversal.first_node_of_type(self, Label3D.new())
		
	assert(image_hint != null or text_hint != null, "IndieBlueprintVisualHint3D: This node needs at least one Sprite3D or Label3D to work as expected")
	
	if interactable == null:
		interactable = IndieBlueprintNodeTraversal.first_node_of_custom_class(self, Interactable3D)
	
	assert(interactable != null, "VisualHint3D: This node needs at least one Interactable3D so that it can be interactive")
	
	image_hint.texture = image_hint_texture
	
	interactable.focused.connect(on_focused_interactable)
	interactable.unfocused.connect(on_unfocused_interactable)
	
	_setup_image_hint()
	_setup_text_hint()
	

func _setup_image_hint() -> void:
	if image_hint != null:
		image_hint.texture = image_hint_texture
		image_hint.billboard = image_billboard_mode
		image_hint.render_priority = 2
		image_hint.transparent = true
		image_hint.no_depth_test = true
		image_hint.visibility_range_end = image_hint_visible_distance

	
func _setup_text_hint() -> void:
	if text_hint != null:
		text_hint.billboard = text_billboard_mode
		text_hint.render_priority = 2
		text_hint.visibility_range_end = text_hint_visible_distance


func display_image_hint() -> void:
	if image_hint != null and image_hint_focus_texture != null:
		image_hint.texture = image_hint_focus_texture
	

func hide_image_hint() -> void:
	if image_hint != null and image_hint_texture != null:
		image_hint.texture = image_hint_texture
	

func display_text_hint() -> void:
	if text_hint != null:
		text_hint.show()


func hide_text_hint() -> void:
	if text_hint != null:
		text_hint.hide()
	
	
func on_focused_interactable() -> void:
	display_image_hint()
	display_text_hint()


func on_unfocused_interactable() -> void:
	hide_image_hint()
	hide_text_hint()
