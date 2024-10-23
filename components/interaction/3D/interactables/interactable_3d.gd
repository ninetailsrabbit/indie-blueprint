@icon("res://components/interaction/3D/grabbable.svg")
class_name Interactable3D extends Area3D

const GroupName = "interactables"

signal interacted()
signal canceled_interaction()
signal focused()
signal unfocused()
signal interaction_limit_reached()


enum OutlineMode {
	EdgeShader,
	InvertedHull
}

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
@export_group("Scan")
@export var scannable: bool = false
@export var can_be_rotated_on_scan: bool = true
@export var target_scannable_object: Node3D
@export_group("Outline")
@export var interactable_mesh: MeshInstance3D
@export var outline_mode: OutlineMode = OutlineMode.EdgeShader
@export var outline_on_focus: bool = true
@export_category("Edge shader") # https://www.videopoetics.com/tutorials/pixel-perfect-outline-shaders-unity/
@export var outline_shader_color: Color = Color.WHITE
@export var outline_width: float = 2.0
@export var outline_shader: Shader = preload("res://shaders/environment/pixel_perfect_outline.gdshader")
@export_category("Inverted hull")
@export var outline_hull_color: Color = Color.WHITE
@export_range(0, 16, 0.01) var outline_grow_amount: float = 0.02
@export_group("Screen pointers")
@export var focus_screen_pointer: CompressedTexture2D
@export var interact_screen_pointer: CompressedTexture2D
@export_group("Cursors")
@export var focus_cursor: CompressedTexture2D
@export var interact_cursor: CompressedTexture2D
@export var scan_rotate_cursor: CompressedTexture2D

var can_be_interacted: bool = true
var times_interacted: int = 0:
	set(value):
		var previous_value = times_interacted
		times_interacted = value
		
		if previous_value != times_interacted && times_interacted >= number_of_times_can_be_interacted:
			interaction_limit_reached.emit()
			deactivate()
			
var outline_material: StandardMaterial3D
var outline_shader_material: ShaderMaterial


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if activate_on_start:
		activate()
	
	interacted.connect(on_interacted)
	focused.connect(on_focused)
	unfocused.connect(on_unfocused)
	canceled_interaction.connect(on_canceled_interaction)
	
	
func activate() -> void:
	priority = 3
	collision_layer = GameGlobals.interactables_collision_layer
	collision_mask = 0
	monitorable = true
	monitoring = false
	
	can_be_interacted = true
	times_interacted = 0
	
	
func deactivate() -> void:
	priority = 0
	collision_layer = 0
	monitorable = false
	
	can_be_interacted = false


func _apply_outline_shader() -> void:
	if outline_on_focus and interactable_mesh:
		var material: StandardMaterial3D = interactable_mesh.get_active_material(0)
		
		match outline_mode:
			OutlineMode.EdgeShader:
				if material and not material.next_pass:
				
					if not outline_shader_material:
						outline_shader_material = ShaderMaterial.new()
						outline_shader_material.shader = outline_shader
						
					outline_shader_material.set_shader_parameter("outline_color", outline_shader_color)
					outline_shader_material.set_shader_parameter("outline_width", outline_width)
					material.next_pass = outline_shader_material
					
			OutlineMode.InvertedHull:
				if not outline_material:
					outline_material = StandardMaterial3D.new()
					outline_material.grow = true
					outline_material.blend_mode = BaseMaterial3D.BLEND_MODE_PREMULT_ALPHA
					outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
					outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				
				outline_material.albedo_color = outline_hull_color
				outline_material.grow_amount = outline_grow_amount
				interactable_mesh.material_overlay = outline_material


func _remove_outline_shader() -> void:
	if outline_on_focus and interactable_mesh:
		var material: StandardMaterial3D = interactable_mesh.get_active_material(0)
		
		match outline_mode:
			OutlineMode.EdgeShader:
				if material:
					material.next_pass = null
			OutlineMode.InvertedHull:
				interactable_mesh.material_overlay = null
			
#region Signal callbacks
func on_interacted() -> void:
	if disable_after_interaction:
		deactivate()
	
	GlobalGameEvents.interactable_interacted.emit(self)
		
func on_focused() -> void:
	_apply_outline_shader()
	
	GlobalGameEvents.interactable_focused.emit(self)
	

func on_unfocused() -> void:
	_remove_outline_shader()
	
	GlobalGameEvents.interactable_unfocused.emit(self)
	
func on_canceled_interaction() -> void:
	GlobalGameEvents.interactable_canceled_interaction.emit(self)
	
#endregion
