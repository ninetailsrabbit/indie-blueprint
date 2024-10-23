extends CanvasLayer

@export var actor: FirstPersonController
@export var finite_state_machine: FiniteStateMachine
@export var speed_unit: VelocityHelper.SpeedUnit = VelocityHelper.SpeedUnit.KilometersPerHour

@onready var velocity_label: Label = %VelocityLabel
@onready var speed_label: Label = %SpeedLabel
@onready var state_label: Label = %State
@onready var fov_label: Label = %FOV


@onready var control: Control = $Control


func _ready() -> void:
	assert(actor is FirstPersonController, "FirstPersonControllerDebugUI: Needs a FirstPersonController to display the debug parameters")
	
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if finite_state_machine:
		finite_state_machine.state_changed.connect(on_state_changed)
		
		state_label.text = "State: [%s]" % finite_state_machine.current_state.name
	
	if actor.camera:
		fov_label.text = str(actor.camera.fov)
	

func _process(_delta: float) -> void:
	var velocity = actor.get_real_velocity()
	var velocity_snapped : Array[float] = [
		snappedf(velocity.x, 0.001),
		snappedf(velocity.y, 0.001),
		snappedf(velocity.z, 0.001)
	]
	
	velocity_label.text = "Velocity: (%s, %s, %s)" % [velocity_snapped[0], velocity_snapped[1], velocity_snapped[2]]
	
	match speed_unit:
		VelocityHelper.SpeedUnit.KilometersPerHour:
			speed_label.text = "Speed: %d km/h" % VelocityHelper.current_speed_on_kilometers_per_hour(velocity)
		VelocityHelper.SpeedUnit.MilesPerHour:
			speed_label.text = "Speed: %d mp/h" % VelocityHelper.current_speed_on_miles_per_hour(velocity)
	
		
	if actor.camera:
		fov_label.text = str(actor.camera.fov)
	
func on_state_changed(from: MachineState, to: MachineState) -> void:
	state_label.text = "State: %s -> [%s]" % [from.name, to.name]
	
