class_name TopDownDash extends TopDownGround

@export var entry_speed: float = 250
@export var dash_times: float = 2
@export var use_dash_timer: bool = true
@export var dash_duration: float = 0.7
@export_category("Ghost effect")
@export var enable_ghost_effect: bool = true
@export var only_modify_alpha: bool = true
@export var ghost_effect_color: Color = Color.WHITE
@export_range(0, 255, 1) var ghost_effect_alpha: int = 200
@export_range(0, 255, 1) var ghost_effect_vanish_time: float = 0.7

@onready var ghost_effect: GhostTrailEffect = $GhostEffect
@onready var dash_timer: Timer = $DashTimer


var dash_direction: Vector2 = Vector2.ZERO
var current_dash_times: int = 0

func _ready() -> void:
	super._ready()
	await get_tree().physics_frame
	
	if use_dash_timer:
		dash_timer.timeout.connect(on_dash_timer_timeout)
	elif actor.animated_sprite_2d and not actor.animated_sprite_2d.animation_finished.is_connected(on_animation_finished):
		actor.animated_sprite_2d.animation_finished.connect(on_animation_finished)
	

func enter() -> void:
	dash_direction = actor.motion_input.previous_input_axis_as_vector
	
	if dash_direction.is_zero_approx():
		FSM.change_state_to(TopDownWalk)
		return
	
	apply_dash(dash_direction)
	
	
func exit(_next_state: MachineState) -> void:
	current_dash_times = 0
	ghost_effect.stop()


func physics_update(delta: float) -> void:
	actor.velocity = actor.velocity.lerp(dash_direction * speed, acceleration * delta)
	actor.move_and_slide()
	
	if Engine.get_physics_frames() % 15 == 0:
		ghost_effect.start()
	
	if current_dash_times < dash_times and Input.is_action_just_pressed(dash_input_action):
		apply_dash(actor.motion_input.input_axis_as_vector)


func apply_dash(direction: Vector2 = dash_direction) -> void:
	dash_timer.start(dash_duration)
	
	dash_direction = direction
	
	if direction.is_zero_approx():
		return
	
	if not use_dash_timer and actor.animated_sprite_2d:
		actor.update_dash_animation(direction)

	
	if VectorHelper.is_diagonal_direction_v2(direction):
		direction = direction.normalized()
	
	actor.velocity = direction * entry_speed
	actor.move_and_slide()
	
	current_dash_times += 1
	

func on_animation_finished() -> void:
	if actor.animated_sprite_2d.animation.containsn("dash"):
		FSM.change_state_to(TopDownWalk)


func on_dash_timer_timeout() -> void:
	FSM.change_state_to(TopDownWalk)
	
