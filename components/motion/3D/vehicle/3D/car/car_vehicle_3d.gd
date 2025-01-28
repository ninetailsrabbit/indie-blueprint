################## STEPS ##################
# 1. Set the car model mesh and collision shape
# 2. Adjust the parameters of the vehicles and wheel depending on the type of vehicle
# 3. Collision shape always needs to be above the wheels for the suspension to apply correctly.
# 4. Add the wheel meshes as child of the wheel nodes
# 5. (Optional) Set the node that displays a steering wheel in the exported parameter (first person view mostly)
################## END ##################
class_name CarVehicle3D extends VehicleBody3D

const GroupName: StringName = &"vehicles"

signal started_engine
signal stopped_engine

## The acceleration will be applied to the engine force. More acceleration takes less time to achieve max speed
@export_category("Input")
@export var start_engine_action: StringName = InputControls.StartVehicleEngine
@export var vehicle_acceleration_action: StringName = InputControls.VehicleAccelerate:
	set(new_action):
		if new_action != vehicle_acceleration_action:
			vehicle_acceleration_action = new_action
			_update_input_actions()
@export var vehicle_reverse_acceleration_action: StringName = InputControls.VehicleReverseAccelerate:
	set(new_action):
		if new_action != vehicle_reverse_acceleration_action:
			vehicle_reverse_acceleration_action = new_action
			_update_input_actions()
@export var vehicle_steer_right_action: StringName = InputControls.VehicleSteerRight:
	set(new_action):
		if new_action != vehicle_steer_right_action:
			vehicle_steer_right_action = new_action
			_update_input_actions()
@export var vehicle_steer_left_action: StringName = InputControls.VehicleSteerLeft:
	set(new_action):
		if new_action != vehicle_steer_left_action:
			vehicle_steer_left_action = new_action
			_update_input_actions()
@export var vehicle_hand_brake: StringName = InputControls.VehicleHandBrake

@export_category("Engine")
@export var engine_acceleration: float = 200.0
@export var engine_reverse_acceleration: float = 100.0
## The maximum value the wheels can be turned at
@export var max_rpm: float = 500.0
@export_category("Steering")
## Decides how much a wheel can be turned. Higher values means that it can turn more easily
@export var kb_steering_ramp_up_factor: float = 30.0
## The node that displays a steering wheel that can be rotated
@export var steering_wheel: Node3D
@export var steering_wheel_maximum_rotation: Vector3 = Vector3.ZERO
@export var steering_wheel_idle_rotation: Vector3 = Vector3.ZERO
@export var steering_wheel_lerp_factor: float = 15.0

@onready var front_right_wheel: VehicleWheel3D = %FrontRightWheel
@onready var front_left_wheel: VehicleWheel3D = %FrontLeftWheel
@onready var rear_right_wheel: VehicleWheel3D = %RearRightWheel
@onready var rear_left_wheel: VehicleWheel3D = %RearLeftWheel


var motion_input: TransformedInput = TransformedInput.new(self)
var engine_on: bool = false:
	set(value):
		if value != engine_on:
			engine_on = value
			
			if engine_on:
				started_engine.emit()
			else:
				engine_force = 0
				stopped_engine.emit()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(start_engine_action):
		engine_on = !engine_on


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	_update_input_actions()
	
	process_mode = PROCESS_MODE_PAUSABLE
	

func _physics_process(delta: float) -> void:
	motion_input.update()
	
	var steering_input: float = -motion_input.input_direction_horizontal_axis
	var turn_direction: float =  clampf(steering_input * delta * kb_steering_ramp_up_factor, -1.0, 1.0)
	
	if steering_wheel:
		var target_steering_wheel_rotation: Vector3 = steering_wheel_idle_rotation if is_zero_approx(steering_input) else steering_wheel_maximum_rotation
		steering_wheel.rotation = steering_wheel.rotation.lerp(target_steering_wheel_rotation, clampf(delta * steering_wheel_lerp_factor, 0.0, 1.0))
	
	steering = lerp(steering, turn_direction, steering_wheel_lerp_factor * delta)
	
	if engine_on:
		var engine_acceleration_input: float = -motion_input.input_direction_vertical_axis
		var left_wheel_rpm: float = absf(rear_left_wheel.get_rpm())
		var right_wheel_rpm: float = absf(rear_right_wheel.get_rpm())
		var acceleration: float = engine_acceleration_input * (engine_acceleration if sign(engine_acceleration_input) == 1 else engine_reverse_acceleration)
		
		rear_left_wheel.engine_force = acceleration * (1.0 - left_wheel_rpm / max_rpm)
		rear_right_wheel.engine_force = acceleration * (1.0 - right_wheel_rpm / max_rpm)
				
	
func start_engine() -> void:
	engine_on = true
	
	
func stop_engine() -> void:
	engine_on = false


func _update_input_actions() -> void:
	if motion_input == null:
		motion_input = TransformedInput.new(self)
		
	motion_input.change_move_right_action(vehicle_steer_right_action)\
		.change_move_left_action(vehicle_steer_left_action)\
		.change_move_forward_action(vehicle_acceleration_action)\
		.change_move_back_action(vehicle_reverse_acceleration_action)
