class_name FirstPersonDebugUI extends CanvasLayer


@export var first_person_controller: IndieBlueprintFirstPersonController
@export var speed_unit: IndieBlueprintVelocityHelper.SpeedUnit = IndieBlueprintVelocityHelper.SpeedUnit.KilometersPerHour

@onready var state_label: Label = %State
@onready var velocity_label: Label = %Velocity
@onready var speed_label: Label = %Velocity


func _ready() -> void:
	if first_person_controller == null:
		first_person_controller = get_parent()
		
	assert(first_person_controller != null and first_person_controller is IndieBlueprintFirstPersonController, "FirstPersonDebugUI: First person controller not assigned")
	
	call_deferred("connect_state_machine")
	set_process(visible)
	
	visibility_changed.connect(on_visibility_changed)
	
	
func _process(_delta: float) -> void:
	var velocity = first_person_controller.get_real_velocity()
	var velocity_snapped : Array[float] = [
		snappedf(velocity.x, 0.001),
		snappedf(velocity.y, 0.001),
		snappedf(velocity.z, 0.001)
	]
	
	velocity_label.text = "Velocity: (%s, %s, %s)" % [velocity_snapped[0], velocity_snapped[1], velocity_snapped[2]]
	
	match speed_unit:
		IndieBlueprintVelocityHelper.SpeedUnit.KilometersPerHour:
			speed_label.text = "Speed: %d km/h" % IndieBlueprintVelocityHelper.current_speed_on_kilometers_per_hour(velocity)
		IndieBlueprintVelocityHelper.SpeedUnit.MilesPerHour:
			speed_label.text = "Speed: %d mp/h" % IndieBlueprintVelocityHelper.current_speed_on_miles_per_hour(velocity)
	
	
func connect_state_machine() -> void:
	state_label.text = first_person_controller.state_machine.current_state.name
	first_person_controller.state_machine.state_changed.connect(on_state_changed)
	
	
func on_state_changed(from:IndieBlueprintMachineState, to: IndieBlueprintMachineState) -> void:
	state_label.text = "%s -> [%s]" % [from.name, to.name]


func on_visibility_changed() -> void:
	set_process(visible)
