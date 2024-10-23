class_name FireArmWeaponMesh extends Node3D

@export var muzzle_marker: Marker3D
@export var barrel_marker: Marker3D
@export var animation_player: AnimationPlayer
@export var apply_viewmodel: bool = true
@export var viewmodel_fov: float = 75.0


func _ready() -> void:
	if apply_viewmodel:
		setup_viewmodel_fov(viewmodel_fov)


func setup_viewmodel_fov(fov_value: float = viewmodel_fov) -> void:
	for mesh_instance: MeshInstance3D in NodeTraversal.find_nodes_of_type(self, MeshInstance3D.new()):
		for surface in range(mesh_instance.mesh.get_surface_count()):
			var material = mesh_instance.get_active_material(surface)
			if material is ShaderMaterial:
				material.set_shader_parameter("viewmodel_fov", fov_value)


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
