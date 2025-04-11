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
class_name Grabbable3D extends RigidBody3D

const MaximumTransparency: int = 255
const GroupName: StringName = &"grabbable"

enum GrabState {
	Neutral,
	Pull,
	Throw
}

enum OutlineMode {
	EdgeShader,
	InvertedHull
}

signal pulled(grabber: Node3D)
signal throwed
signal dropped
signal focused
signal unfocused

@export var mesh_instance: MeshInstance3D
@export_group("Force")
## The initial pull power to attract and manipulate grabbables
@export var pull_power: float = 7.5
## The initial throw power to apply force impulses to grabbables
@export var throw_power: float = 10.0
## Rotation force to apply
@export var angular_power: float = 0.0
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
@export var outline_shader: Shader = preload("res://addons/ninetailsrabbit.interaction_kit_3d/src/shaders/pixel_perfect_outline.gdshader")
@export_category("Inverted hull")
@export var outline_hull_color: Color = Color.WHITE
@export_range(0, 16, 0.01) var outline_grow_amount: float = 0.02
@export_group("Information")
@export var title: String = ""
@export var description: String = ""
@export var title_translation_key: StringName
@export var description_translation_key: StringName
@export_group("Pointers and cursors")
@export var focus_screen_pointer: CompressedTexture2D
@export var interact_screen_pointer: CompressedTexture2D
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
	focused.connect(on_focused)
	unfocused.connect(on_unfocused)
	
	collision_layer = InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting))
	collision_mask = 1 | InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting))
	
	add_to_group(GroupName)


func _ready() -> void:
	if mesh_instance == null:
		mesh_instance = InteractionKit3DPluginUtilities.first_node_of_type(self, MeshInstance3D.new())


func _physics_process(delta: float) -> void:
	if state_is_pull() and adjust_rotation_on_pull:
		rotation = rotation.lerp(target_rotation, delta * lerp_adjust_speed)
		
		if rotation.is_equal_approx(target_rotation):
			set_physics_process(false)
		
		
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state_is_pull():
		state.linear_velocity = current_linear_velocity
		state.angular_velocity = current_angular_velocity
	
	elif state_is_throw() and state.linear_velocity.is_zero_approx():
		current_state = GrabState.Neutral
	
	
func pull(grabber: Node3D) -> void:
	if not state_is_pull() and current_grabber == null:
		current_state = GrabState.Pull
		current_grabber = grabber
		gravity_scale = 0.0
		sleeping = false
		
		if transparency_on_pull:
			_apply_transparency()

		pulled.emit(grabber)


func throw() -> void:
	if state_is_pull():
		gravity_scale = original_gravity_scale
	
		var impulse: Vector3 = InteractionKit3DPluginUtilities.camera_forward_direction(get_viewport().get_camera_3d()) * throw_power
		apply_impulse(impulse)
		
		current_state = GrabState.Throw
		current_grabber = null
		
		if transparency_on_pull:
			_recover_transparency()
			
		throwed.emit()


func drop() -> void:
	if state_is_pull():
		gravity_scale = original_gravity_scale
		
		var impulse: Vector3 = InteractionKit3DPluginUtilities.camera_forward_direction(get_viewport().get_camera_3d()) * Vector3.ZERO
		apply_impulse(impulse)
		
		current_state = GrabState.Neutral
		current_grabber = null
		
		if transparency_on_pull:
			_recover_transparency()
			
		dropped.emit()

	
func update_linear_velocity() -> void:
	if current_grabber:
		current_linear_velocity = (current_grabber.global_position - global_position) * pull_power


func update_angular_velocity() -> void:
	if current_grabber and angular_power > 0:
		var q1: Quaternion = global_basis.get_rotation_quaternion()
		var q2: Quaternion = current_grabber.global_basis.get_rotation_quaternion()

		# Quaternion that transforms q1 into q2
		var qt = q2 * q1.inverse()

		# Angle from quaternion
		var angle = 2 * acos(qt.w)

		# There are two distinct quaternions for any orientation.
		# Ensure we use the representation with the smallest angle.
		if angle > PI:
			qt = -qt
			angle = TAU - angle

		current_angular_velocity =  Vector3.ZERO if angle <  0.000001 else (Vector3(qt.x, qt.y, qt.z) / sqrt(1 -qt.w * qt.w)) * angular_power


func state_is_throw() -> bool:
	return current_state == GrabState.Throw


func state_is_neutral() -> bool:
	return current_state == GrabState.Neutral


func state_is_pull() -> bool:
	return current_state == GrabState.Pull


func _apply_transparency():
	if transparency_value_on_pull == MaximumTransparency:
		return
		
	var material: StandardMaterial3D = mesh_instance.get_active_material(0)
	
	if material:
		original_transparency = material.albedo_color.a8
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a8 = transparency_value_on_pull


func _recover_transparency():
	if transparency_value_on_pull == 255:
		return
		
	var material: StandardMaterial3D = mesh_instance.get_active_material(0)
	
	if material:
		material.albedo_color.a8  = original_transparency

	
func _apply_outline_shader() -> void:
	if outline_on_focus:
		var material: StandardMaterial3D = mesh_instance.get_active_material(0)
		
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
				mesh_instance.material_overlay = outline_material

	
func _remove_outline_shader() -> void:
	if outline_on_focus:
		var material: StandardMaterial3D = mesh_instance.get_active_material(0)
		
		match outline_mode:
			OutlineMode.EdgeShader:
				if material:
					material.next_pass = null
			OutlineMode.InvertedHull:
				mesh_instance.material_overlay = null
			

#region Signal callbacks
func on_focused() -> void:
	_apply_outline_shader()


func on_unfocused() -> void:
	_remove_outline_shader()

#endregion
