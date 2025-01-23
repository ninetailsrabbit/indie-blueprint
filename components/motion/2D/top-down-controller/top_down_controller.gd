@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name TopDownController extends CharacterBody2D

const GroupName: StringName = &"player"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

var motion_input: TransformedInput = TransformedInput.new(self)


func _physics_process(_delta: float) -> void:
	motion_input.update()
	
