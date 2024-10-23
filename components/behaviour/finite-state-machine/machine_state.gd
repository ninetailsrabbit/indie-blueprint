@icon("res://components/behaviour/finite-state-machine/state.png")
class_name MachineState extends Node

signal entered
signal finished(next_state: MachineState)

var FSM: FiniteStateMachine


func ready() -> void:
	pass


func enter() -> void:
	pass
	

func exit(_next_state: MachineState) -> void:
	pass
	

func handle_input(_event: InputEvent):
	pass


func physics_update(_delta: float):
	pass
	
	
func update(_delta: float):
	pass
	
