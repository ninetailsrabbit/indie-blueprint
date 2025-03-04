class_name IndieBlueprintMachineState extends Node

signal entered
signal finished(next_state: IndieBlueprintMachineState)

var FSM: IndieBlueprintFiniteStateMachine


func ready() -> void:
	pass


func enter() -> void:
	pass
	

func exit(_next_state: IndieBlueprintMachineState) -> void:
	pass
	

func handle_input(_event: InputEvent):
	pass
	

func handle_unhandled_input(_event: InputEvent):
	pass
	

func handle_key_input(_event: InputEvent):
	pass


func physics_update(_delta: float):
	pass
	
	
func update(_delta: float):
	pass
	
