class_name PushWaveArea3D extends Area3D

signal activated

@export var pushable_bodies: int = 7
@export var min_push_force: float = 5.0
@export var max_push_force: float = 20.0
@export var min_upward_force: float = 0.1
@export var max_upward_force: float = 1.0
@export var wave_speed: float = 2.0
@export var wave_radius: float = 5.0
@export var time_alive: float = 1.0

var active: bool = false:
	set(value):
		if value != active:
			active = value
			
			if active:
				activated.emit()
				
			monitoring = active
			set_physics_process(active)
			
	
var direction: Vector3 = Vector3.FORWARD
var bodies_pushed: Dictionary[String, RigidBody3D] = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var alive_timer: Timer


func _init(wave_direction: Vector3):
	direction = wave_direction


func _enter_tree() -> void:
	_create_alive_timer()
	
	
func _ready():
	monitorable = false
	monitoring = active
	collision_layer = 0
	collision_mask = 1 | InteractionKit3DPluginUtilities.layer_to_value(ProjectSettings.get_setting(InteractionKit3DPluginSettings.GrabbablesCollisionLayerSetting))
	
	linear_damp_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	linear_damp = 0.5
	angular_damp_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	angular_damp = 0.5

	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = wave_radius
	add_child(collision)
	
	set_physics_process(active)


func _physics_process(_delta):
	global_position += wave_speed * direction
	push_bodies_on_range()
	
	
func activate():
	if is_instance_valid(alive_timer):
		alive_timer.start()

	active = true
	
	
func push_bodies_on_range():
	for body: RigidBody3D in get_overlapping_bodies()\
		.filter(
			func(detected_body): 
				return detected_body is RigidBody3D and not bodies_pushed.has(detected_body.name)):
					
		var upward_offset = Vector3.ZERO if max_upward_force == 0 else Vector3.UP * rng.randf_range(min_upward_force, max_upward_force)
		bodies_pushed[body.name] = body
		body.angular_velocity = InteractionKit3DPluginUtilities.generate_3d_random_fixed_direction() * rng.randf_range(0.5, 1.0)
		body.apply_impulse(InteractionKit3DPluginUtilities.rotate_horizontal_random(direction) * rng.randf_range(min_push_force, max_push_force), -body.position.normalized() + upward_offset)

	active = bodies_pushed.size() < pushable_bodies
	
	
func _create_alive_timer():
	if alive_timer == null:
		alive_timer = InteractionKit3DPluginUtilities.create_physics_timer(max(0.05, time_alive), false, true)
		alive_timer.name = "PushWaveAliveTimer"
		add_child(alive_timer)
		alive_timer.timeout.connect(on_alive_timer_timeout)
		
		
func on_alive_timer_timeout():
	queue_free()
