### Recommended muzzle light colors
## Warm colors
# Bright orange: #FF8C00
# Golden yellow: #FFD700
# Fiery red: #FF5733
# Hot pink: #FF69B4

## Cold colors
# Electric blue: #00FFFF
# Icy blue: #87CEEB
#Lime green: #00FF00
# Purple haze: #800080

## Neutral colors
# Classic white: #FFFFFF
# Neutral gray: #808080
# Dark brown: #8B4513
# Olive green: #6B8E23
###
class_name MuzzleFlash extends GPUParticles3D

@export_group("Muzzle particle")
@export var particle_lifetime: float = 0.03
@export var min_size: Vector2 = Vector2(0.05, 0.05)
@export var max_size: Vector2 = Vector2(0.35, 0.35)
@export var emit_on_ready: bool = true
@export var texture: Texture2D
@export_group("Muzzle light")
@export var spawn_light: bool = true
@export var light_lifetime: float = 0.01
@export_range(0, 16, 0.1) var min_light_energy: float = 1.0
@export_range(0, 16, 0.1) var max_light_energy: float = 1.0
@export var use_integers: bool = false
@export var light_color: Color = Color("FFD700")

@onready var muzzle_timer: Timer = $MuzzleTimer
@onready var light_timer: Timer = $LightTimer
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var muzzle_material: StandardMaterial3D = (draw_pass_1 as QuadMesh).surface_get_material(0)


func _ready() -> void:
	_prepare_timers()
	
	if texture and muzzle_material:
		muzzle_material.albedo_texture = texture
	
	if emit_on_ready:
		emit()


func change_texture(muzzle_texture: Texture2D) -> void:
	texture = muzzle_texture


func emit(
	emission_lifetime: float = particle_lifetime, 
	min_particle_size: Vector2 = min_size,
 	max_particle_size: Vector2 = max_size
) -> void:
	lifetime = emission_lifetime
	draw_pass_1.size = Vector2(randf_range(min_particle_size.x, max_particle_size.x), randf_range(min_particle_size.y, max_particle_size.y))
	one_shot = true
	emitting = true
	
	spawn_muzzle_light()
	muzzle_timer.start(lifetime)


func spawn_muzzle_light() -> void:
	if omni_light_3d:
		if spawn_light:
			omni_light_3d.light_energy = randf_range(min_light_energy, max_light_energy)
			
			if use_integers:
				omni_light_3d.light_energy = ceil(omni_light_3d.light_energy)
				
			omni_light_3d.light_color = light_color
			omni_light_3d.show()
			light_timer.start()
		else:
			omni_light_3d.hide()


func setup_from_weapon_configuration(configuration: FireArmWeaponConfiguration) -> void:
	texture = configuration.muzzle_texture
	particle_lifetime = configuration.muzzle_lifetime
	min_size = configuration.muzzle_min_size
	max_size = configuration.muzzle_max_size
	emit_on_ready = configuration.muzzle_emit_on_ready
	
	spawn_light = configuration.muzzle_spawn_light
	light_lifetime = configuration.muzzle_light_lifetime
	min_light_energy = configuration.muzzle_min_light_energy
	max_light_energy = configuration.muzzle_max_light_energy
	light_color = configuration.muzzle_light_color


func _prepare_timers() -> void:
	if is_instance_valid(muzzle_timer):
		muzzle_timer.autostart = false
		muzzle_timer.one_shot = true
		muzzle_timer.wait_time = particle_lifetime
		muzzle_timer.timeout.connect(on_muzzle_timeout)
		
	if is_instance_valid(light_timer):
		light_timer.autostart = false
		light_timer.one_shot = true
		light_timer.wait_time = light_lifetime
		light_timer.timeout.connect(on_light_timeout)

	
func on_muzzle_timeout() -> void:
	queue_free()
	

func on_light_timeout() -> void:
	omni_light_3d.hide()
