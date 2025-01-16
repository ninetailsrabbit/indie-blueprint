@icon("res://components/environment/water/water.svg")
class_name WaterManager extends Node

const GroupName: StringName = &"water_manager"

signal started
signal stopped

@export var water: MeshInstance3D
@export var reference_node_to_activate_fast_mode: Node3D
@export var distance_from_floatables_for_fast_mode: float = 200.0
@export_range(0.0, 1.0, 0.01) var water_sync_percent: float = 1.0
@export var start_on_ready: bool = true

var water_material: ShaderMaterial
var sync_time: float = 0.0
var v_noise_1: NoiseTexture2D
var v_noise_2: NoiseTexture2D
var v_noise_1_image: Image
var v_noise_2_image: Image
var v_noise_1_size: Vector2
var v_noise_2_size: Vector2
var v_noise_tile: int
var amplitude_1: float
var amplitude_2: float
var height_scale: float
var wave_speed: float

var fixed_time : float
var running: bool = false:
	set(value):
		if value != running:
			running = value
			
			if running:
				started.emit()
			else:
				stopped.emit()
			
			if is_inside_tree():
				set_process(running)
				set_physics_process(running)


var floatable_bodies: Array[FloatableBody3D] = []
var current_relative_distance: float = 0.0


func _enter_tree() -> void:
	add_to_group(GroupName)
	
	
func _ready() -> void:
	assert(water != null, "WaterManager: This manager needs a water mesh to work")
	
		
	if start_on_ready:
		start()
	
	floatable_bodies.assign(get_tree().get_nodes_in_group(FloatableBody3D.GroupName))
	
	set_process(running)
	set_physics_process(running)
	

func _process(delta: float):
	sync_time += delta * water_sync_percent
	water_material.set_shader_parameter("sync_time", sync_time)
	
	if reference_node_to_activate_fast_mode and Engine.get_process_frames() % 30 == 0:
		_update_floatables_fast_mode()
			
func _physics_process(_delta: float) -> void:
	## It's more performant one physic process that handle all floatable bodies
	## that individual physics on each floatable body
	for floatable_body in floatable_bodies.filter(func(body: FloatableBody3D): return body.is_enabled):
		if floatable_body.fast_mode:
			var water_y: float = fast_water_height(floatable_body.body.global_position)
			var k: float = clampf((water_y - floatable_body.body.global_position.y), 0.0, 1.0)
				
			floatable_body.apply_fast_mode_buoyancy(floatable_body.calculate_damping_force(k))
		else:
			for buoyancy_point: Marker3D in floatable_body.buoyancy_points:
				var buoyancy_point_position : Vector3 = floatable_body.body.global_position + (floatable_body.body.global_position - buoyancy_point.global_position)
				buoyancy_point_position.y += floatable_body.y_offset
				
				var water_y = calculate_water_height(buoyancy_point_position)
				
				# snippet from: // http://forum.unity3d.com/threads/72974-Buoyancy-script
				if buoyancy_point_position.y < water_y:
					var k: float = clampf(water_y - buoyancy_point_position.y, 0.0, 1.0)
					floatable_body.apply_buoyancy(floatable_body.calculate_damping_force(k), buoyancy_point)
					
		floatable_body.limit_rotation()


func start() -> void:
	if running:
		return
		
	water_material = water.get_surface_override_material(0)
	
	if water_material == null:
		water_material = water.get_active_material(0)
	
	sync_time = water_material.get_shader_parameter("sync_time")
	
	v_noise_1 = water_material.get_shader_parameter("vertex_noise_big")
	v_noise_2 = water_material.get_shader_parameter("vertex_noise_big2")

	amplitude_1 = water_material.get_shader_parameter("amplitude1")
	amplitude_2 = water_material.get_shader_parameter("amplitude2")
	
	height_scale = water_material.get_shader_parameter("height_scale")

	v_noise_tile = water_material.get_shader_parameter("v_noise_tile")
	wave_speed = water_material.get_shader_parameter("wave_speed")

	await get_tree().process_frame

	v_noise_1_image = v_noise_1.get_image()
	v_noise_2_image = v_noise_2.get_image()
	v_noise_1_size = Vector2(v_noise_1_image.get_width() - 1, v_noise_1_image.get_height() - 1)
	v_noise_2_size = Vector2(v_noise_2_image.get_width() - 1, v_noise_2_image.get_height() - 1)
	
	running = true
	
	
func stop() -> void:
	running = false


func calculate_water_height(floatable_body_position: Vector3) -> float:
	if running:
		return (wave(floatable_body_position) * height_scale) + water.position.y
	else:
		return floatable_body_position.y


# samples the position without bilinear and returns the height value
func fast_water_height(floatable_body_position : Vector3) -> float:
	if running:
		return (fast_wave(floatable_body_position) * height_scale) + water.position.y
	else:
		return floatable_body_position.y
	

func wave(y : Vector3) -> float:
	var _y2 :Vector2 = Vector2(y.x, y.z)
	
	var v_noise_1_uv = g_v(_y2, false)
	var v_noise_2_uv = g_v(_y2 + Vector2(0.3, 0.476), false)
	
	var v_x = lerp(0.0, v_noise_1_size.x, v_noise_1_uv.x)
	var v_y = lerp(0.0, v_noise_1_size.y, v_noise_1_uv.y)
	
	v_noise_1_uv = Vector2(v_x, v_y)
	
	v_x = lerp(0.0, v_noise_2_size.x, v_noise_2_uv.x)
	v_y = lerp(0.0, v_noise_2_size.y, v_noise_2_uv.y)
	
	v_noise_2_uv = Vector2(v_x, v_y)
	
	var s : float = 0.0;
	
	s += get_4_points(v_noise_1_uv, v_noise_1_image) * amplitude_1
	s += get_4_points(v_noise_2_uv, v_noise_2_image) * amplitude_2
	
	s -= height_scale/2.;
	
	return s;


func g_v(v: Vector2, flipped: bool = false) -> Vector2:
	pass
	
	v.x = fmod(v.x, v_noise_tile)
	v.y = fmod(v.y, v_noise_tile)
	
	var _mapped : Vector2 = Vector2(remap(v.x, 0, v_noise_tile, 0, 1), remap(v.y, 0, v_noise_tile, 0, 1));
	
	fixed_time = float(Time.get_ticks_msec()) / 1000.0

	if flipped:
		_mapped.y -= sync_time * wave_speed;
	else:
		_mapped.x += sync_time * wave_speed;

	_mapped.x = fmod(_mapped.x, 1)
	_mapped.y = fmod(_mapped.y, 1)
	
	if sign(_mapped.x) == -1:
		_mapped.x += 1
	if sign(_mapped.y) == -1:
		_mapped.y += 1
	
	return _mapped
	

func get_4_points(point : Vector2, image : Image) -> float:
	var x0 = int(floor(point.x))
	var x1 = int(ceil(point.x))
	var y0 = int(floor(point.y))
	var y1 = int(ceil(point.y))


	var wx1 = point.x - x0
	var wx0 = 1 - wx1
	var wy1 = point.y - y0
	var wy0 = 1 - wy1

	var result_top = (
		(wx0 * image.get_pixel(x0, y0).r) + 
		(wx1 * image.get_pixel(x1, y0).r)
	)
	
	var result_bottom = (
		(wx0 * image.get_pixel(x0, y1).r) + 
		(wx1 * image.get_pixel(x1, y1).r)
	)
			
	var result = (
		(wy0 * result_top) +
		(wy1 * result_bottom)
	)

	return result

# wave that doesnt do the 4 point sample
func fast_wave(y : Vector3) -> float:
	
	var _y2 :Vector2 = Vector2(y.x, y.z)
	
	var v_noise_1_uv = g_v(_y2, false)
	var v_noise_2_uv = g_v(_y2 + Vector2(0.3, 0.476), false)
	
	var v_x = lerp(0.0, v_noise_1_size.x, v_noise_1_uv.x)
	var v_y = lerp(0.0, v_noise_1_size.y, v_noise_1_uv.y)
	
	v_noise_1_uv = Vector2(v_x, v_y)
	
	v_x = lerp(0.0, v_noise_2_size.x, v_noise_2_uv.x)
	v_y = lerp(0.0, v_noise_2_size.y, v_noise_2_uv.y)
	
	v_noise_2_uv = Vector2(v_x, v_y)
	
	var s : float = 0.0;
	
	var _v_uvi_1 = Vector2i(roundi(v_noise_1_uv.x), roundi(v_noise_1_uv.y))
	var _v_uvi_2 = Vector2i(roundi(v_noise_2_uv.x), roundi(v_noise_2_uv.y))
	

	s += v_noise_1_image.get_pixelv(_v_uvi_1).r * amplitude_1
	s += v_noise_2_image.get_pixelv(_v_uvi_2).r * amplitude_2
	
	s -= height_scale / 2.0
	
	return s


func _update_floatables_fast_mode() -> void:
	floatable_bodies.assign(get_tree().get_nodes_in_group(FloatableBody3D.GroupName))
	current_relative_distance = NodePositioner.global_distance_to_v3(water, reference_node_to_activate_fast_mode)
	
	for floatable_body in floatable_bodies:
		floatable_body.fast_mode = current_relative_distance >= distance_from_floatables_for_fast_mode
