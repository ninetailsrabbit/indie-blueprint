class_name FireArmWeaponMesh extends Node3D

## The muzzle emitter will spawn in the place this marker it's on the weapon mesh
@export var muzzle_marker: Marker3D
## When projectile mode it's enabled, the bullets will spawn in this marker position
@export var barrel_marker: Marker3D
@export var animation_player: AnimationPlayer
## Technique to avoid weapon clipping using a shader, the fov of the weapon it's separated from the world fov
@export var apply_viewmodel: bool = true
@export var viewmodel_shader: Shader = preload("res://shaders/viewmodel/viewmodel.gdshader")
## The Fov of the weapon in the camera using the viewmodel shader, this a fov on his own separated from the main 3D world
@export var viewmodel_fov: float = 75.0


func _ready() -> void:
	if apply_viewmodel and viewmodel_shader is Shader:
		setup_viewmodel_fov(viewmodel_fov)


func setup_viewmodel_fov(fov_value: float = viewmodel_fov) -> void:
	for mesh_instance: MeshInstance3D in NodeTraversal.find_nodes_of_type(self, MeshInstance3D.new()):
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		for surface_idx in range(mesh_instance.mesh.get_surface_count()):
			var material = mesh_instance.mesh.surface_get_material(surface_idx)
			
			if material is ShaderMaterial and material.shader == viewmodel_shader:
				material.set_shader_parameter("viewmodel_fov", fov_value)
			elif material is StandardMaterial3D:
				var weapon_shader_material: ShaderMaterial = ShaderMaterial.new()
				weapon_shader_material.shader = viewmodel_shader
				weapon_shader_material.set_shader_parameter("texture_albedo", material.albedo_texture)
				weapon_shader_material.set_shader_parameter("texture_metallic", material.metallic_texture)
				weapon_shader_material.set_shader_parameter("texture_roughness", material.roughness_texture)
				weapon_shader_material.set_shader_parameter("texture_normal", material.normal_texture)
				weapon_shader_material.set_shader_parameter("albedo", material.albedo_color)
				weapon_shader_material.set_shader_parameter("metallic", material.metallic)
				weapon_shader_material.set_shader_parameter("specular", material.metallic_specular)
				weapon_shader_material.set_shader_parameter("roughness", material.roughness)
				weapon_shader_material.set_shader_parameter("viewmodel_fov", fov_value)
				var tex_channels = { 0: Vector4(1., 0., 0., 0.), 1: Vector4(0., 1., 0., 0.), 2: Vector4(0., 0., 1., 0.), 3: Vector4(1., 0., 0., 1.), 4: Vector4() }
				weapon_shader_material.set_shader_parameter("metallic_texture_channel", tex_channels[material.metallic_texture_channel])
				mesh_instance.mesh.surface_set_material(surface_idx, weapon_shader_material)

#region Animation overrides
func idle_animation() -> void:
	pass
	

func run_animation() -> void:
	pass


func reload_animation() -> void:
	pass


func draw_animation() -> void:
	pass
	

func store_animation() -> void:
	pass
#endregion
