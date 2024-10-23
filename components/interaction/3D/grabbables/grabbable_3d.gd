#1. Force vs.Impulse:
#
#Force: Represents a continuous application of force over time (measured in newtons). When applied to a rigid body, it produces acceleration in the direction of the force.
#Impulse: Represents a sudden change in momentum delivered instantly(measured in newton-seconds). Applying an impulse directly changes the linear or angular velocity of the rigid body based on the impulse magnitude and direction.
#
#2. Application Point:
#
#Central vs.Non-Central:
#Central: Applied at the center of mass of the rigid body. This results in pure translation (linear movement) without rotation.
#Non-Central: Applied at a specific point relative to the body's center of mass. This can produce both translation and rotation (torque) depending on the force/impulse direction and its distance from the center of mass. 
#
#Continuous vs. Instantaneous: Use force methods (apply_force or apply_central_force) for situations where you want to continuously influence the body's movement over time. Use impulse methods (apply_impulse or apply_central_impulse) when you want to cause an immediate change in velocity without applying a prolonged force.
#Central vs. Non-Central: Use central methods (apply_central_force or apply_central_impulse) if you only want to translate the body without introducing rotation. Use non-central methods (apply_force or apply_impulse) if you want to introduce both translation and rotation based on the application point relative to the center of mass.
#Torque: Use apply_torque when you want to directly rotate the body around a specific axis without applying a force.
@icon("res://components/interaction/3D/grabbable.svg")
class_name Grabbable3D extends RigidBody3D

const MaximumTransparency: int = 255
const GroupName: String = "grabbables"

signal pulled(grabber: Node3D)
signal throwed
signal dropped
signal focused
signal unfocused

enum GrabState {
	Neutral,
	Pull,
	Throw
}

enum GrabMode {
	Pull, # Pull the body to the selected slot
	InPlace # Move the body in place, no pulling is applied
}

enum OutlineMode {
	EdgeShader,
	InvertedHull
}

## The mesh related to this grabbable to apply the outline
@export var grabbable_mesh: MeshInstance3D
@export_group("Force")
@export var grab_mode: GrabMode = GrabMode.Pull
## The initial pull power to attract and manipulate this grabbable
@export var pull_power: float = 7.5
## The initial throw power to apply force impulses this grabbable
@export var throw_power: float = 10.0
## Rotation force to apply
@export var angular_power = 0.01
@export_group("Transparency")
@export var transparency_on_pull: bool = false
@export_range(0, 255, 1) var transparency_value_on_pull: int = MaximumTransparency
@export_group("Rotation")
@export var adjust_rotation_on_pull: bool = false
@export var target_rotation: Vector3 = Vector3.ZERO
@export var lerp_adjust_speed: float = 7.0
@export_group("Outline")
@export var outline_mode: OutlineMode = OutlineMode.EdgeShader
@export var outline_on_focus: bool = true
@export_category("Edge shader") # https://www.videopoetics.com/tutorials/pixel-perfect-outline-shaders-unity/
@export var outline_shader_color: Color = Color.WHITE
@export var outline_width: float = 2.0
@export var outline_shader: Shader = preload("res://shaders/environment/pixel_perfect_outline.gdshader")
@export_category("Inverted hull")
@export var outline_hull_color: Color = Color.WHITE
@export_range(0, 16, 0.01) var outline_grow_amount: float = 0.02
@export_group("Information")
@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var title_translation_key: String = ""
@export var description_translation_key: String = ""
@export_group("Screen pointers")
@export var focus_screen_pointer: CompressedTexture2D
@export var interact_screen_pointer: CompressedTexture2D
@export_group("Cursors")
@export var focus_cursor: CompressedTexture2D
@export var interact_cursor: CompressedTexture2D


var original_gravity_scale: float  = gravity_scale
var original_transparency: int = MaximumTransparency

var outline_material: StandardMaterial3D
var outline_shader_material: ShaderMaterial

var current_state: GrabState = GrabState.Neutral
var current_grabber: Node3D
var current_linear_velocity: Vector3 = Vector3.ZERO
var current_angular_velocity: Vector3 = Vector3.ZERO


func _enter_tree() -> void:
	add_to_group(GroupName)

	focused.connect(on_focused)
	unfocused.connect(on_unfocused)
	
	collision_layer = GameGlobals.grabbables_collision_layer


func _apply_outline_shader() -> void:
	if outline_on_focus and grabbable_mesh:
		var material: StandardMaterial3D = grabbable_mesh.get_active_material(0)
		
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
				grabbable_mesh.material_overlay = outline_material


func _remove_outline_shader() -> void:
	if outline_on_focus:
		var material: StandardMaterial3D = grabbable_mesh.get_active_material(0)
		
		match outline_mode:
			OutlineMode.EdgeShader:
				if material:
					material.next_pass = null
			OutlineMode.InvertedHull:
				grabbable_mesh.material_overlay = null
			

#region Signal callbacks
func on_focused() -> void:
	_apply_outline_shader()

	GlobalGameEvents.grabbable_focused.emit(self)

func on_unfocused() -> void:
	_remove_outline_shader()
	
	GlobalGameEvents.grabbable_unfocused.emit(self)
#endregion
