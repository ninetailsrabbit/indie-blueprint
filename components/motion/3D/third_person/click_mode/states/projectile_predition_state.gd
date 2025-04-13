class_name ThirdPersonClickModeProjectilePredictionState extends ThirdPersonClickModeBaseState


@export var prediction_distance: float = 10.0
@export var confirm_input_action: StringName = &"confirm_throw"
@export var cancel_input_action: StringName = &"ui_cancel"


func handle_unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed(cancel_input_action):
		FSM.change_state_to(ThirdPersonClickModeNeutralState)


func physics_update(_delta: float) -> void:
	actor.look_at_mouse()
