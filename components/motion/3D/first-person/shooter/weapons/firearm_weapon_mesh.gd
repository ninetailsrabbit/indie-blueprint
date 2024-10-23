class_name FireArmWeaponMesh extends Node3D

## The muzzle emitter will spawn in the place this marker it's on the weapon mesh
@export var muzzle_marker: Marker3D
## When projectile mode it's enabled, the bullets will spawn in this marker position
@export var barrel_marker: Marker3D
@export var animation_player: AnimationPlayer
## Technique to avoid weapon clipping using a shader, the fov of the weapon it's separated from the world fov
@export var apply_viewmodel: bool = true
## The Fov of the weapon in the camera using the viewmodel shader, this a fov on his own separated from the main 3D world
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
