@icon("res://components/behaviour/finite-state-machine/fsm.png")
class_name FiniteStateMachine extends Node


signal states_initialized(states: Dictionary)
signal state_changed(from_state: MachineState, state: MachineState)
signal state_change_failed(from: MachineState, to: MachineState)
signal stack_pushed(new_state: MachineState, stack: Array[MachineState])
signal stack_flushed(stack: Array[MachineState])

@export var current_state: MachineState
@export var enable_stack: bool = true
@export var stack_capacity: int = 3
@export var flush_stack_when_reach_capacity: bool = false

var states: Dictionary = {}
var transitions: Dictionary = {}
var states_stack: Array[MachineState] = []

var is_transitioning: bool = false
var locked: bool = false


func _ready():
	assert(current_state is MachineState, "FiniteStateMachine: This Finite state machine does not have an initial state defined")

	state_changed.connect(on_state_changed)
	state_change_failed.connect(on_state_change_failed)
	
	_prepare_states()
	enter_state(current_state)
	states_initialized.emit(states)
	

func _unhandled_input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.physics_update(delta)


func _process(delta):
	current_state.update(delta)


func change_state_to(next_state: Variant, parameters: Dictionary = {}):
	if not is_transitioning:
		
		if next_state is GDScript:
			if current_state_is_by_class(next_state):
				return
				
			var state_name: String = next_state.get_global_name()
			
			if states.has(state_name):
				run_transition(current_state, states[state_name], parameters)
			else:
				push_error("FiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % state_name)
		
		elif typeof(next_state) == TYPE_STRING:
			if current_state_is_by_name(next_state):
				return
			
			if states.has(next_state):
				run_transition(current_state, states[next_state], parameters)
			else:
				push_error("FiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % next_state)
		
		elif next_state is MachineState:
			if current_state_is(next_state):
				return
				
			if states.values().has(next_state):
				run_transition(current_state, next_state, parameters)
			else:
				push_error("FiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % next_state.name)
		
		
func run_transition(from: MachineState, to: MachineState, parameters: Dictionary = {}):
	is_transitioning = true

	var transition_name = _build_transition_name(from, to)

	if not transitions.has(transition_name):
		transitions[transition_name] = NeutralMachineTransition.new()
	
	var transition := transitions[transition_name] as MachineTransition
	transition.from_state = from
	transition.to_state = to
	transition.parameters = parameters
	
	if transition.should_transition():		
		transition.on_transition()
		state_changed.emit(from, to)
		
		return
	
	state_change_failed.emit(from, to)

## Example register_transition(WalkToRun.new())
func register_transition(transition: MachineTransition):
	transitions[transition.get_script().get_global_name()] = transition


func register_transitions(new_transitions: Array[MachineTransition]):
	for transition in new_transitions:
		register_transition(transition)
	

func enter_state(state: MachineState):
	is_transitioning = false
	state.entered.emit()
	state.enter()
		

func exit_state(state: MachineState, _next_state: MachineState):
	state.finished.emit(_next_state)
	state.exit(_next_state)


func current_state_is_by_name(state: String) -> bool:
	return current_state.name.strip_edges().to_lower() == state.strip_edges().to_lower()


func current_state_is(state: MachineState) -> bool:
	return current_state_is_by_name(state.name)


func current_state_is_by_class(state: GDScript) -> bool:
	return current_state.get_script() == state


func current_state_is_not(_states: Array = []) -> bool:
	return _states.any(func(state):
		if typeof(state) == TYPE_STRING:
			return current_state_is_by_name(state)
		
		if state is MachineState:
			return current_state_is(state)
		
		return false
	)
	

func last_state() -> MachineState:
	return states_stack.back() if states_stack.size() > 0 else null


func next_to_last_state() -> MachineState:
	return states_stack[states_stack.size() - 2] if states_stack.size() > 1 else null


func _build_transition_name(from: MachineState, to: MachineState) -> String:
	var transition_name: String = "%sTo%sTransition" % [from.name.strip_edges(), to.name.strip_edges()]
	
	if not transitions.has(transition_name):
		transition_name = "AnyTo%sTransition" % to.name.strip_edges()
	
	return transition_name
	

func push_state_to_stack(state: MachineState) -> void:
	if enable_stack and stack_capacity > 0:
		if states_stack.size() >= stack_capacity:
			if flush_stack_when_reach_capacity:
				stack_flushed.emit(states_stack)
				states_stack.clear()
			else:
				states_stack.pop_front()
			
		states_stack.append(state)
		stack_pushed.emit(state, states_stack)
			


func lock_state_machine():
	process_mode =  ProcessMode.PROCESS_MODE_DISABLED

	
func unlock_state_machine():
		process_mode =  ProcessMode.PROCESS_MODE_INHERIT


func _prepare_states(node: Node = self):
	for child in node.get_children(true):
		if child is MachineState:
			
			_add_state_to_dictionary(child)
		else:
			if child.get_child_count() > 0:
				_prepare_states(child)


func _add_state_to_dictionary(state: MachineState):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())
		state.FSM = self
		state.ready()


func on_state_changed(from: MachineState, to: MachineState):
	push_state_to_stack(from)
	exit_state(from, to)
	enter_state(to)

	current_state = to


func on_state_change_failed(_from: MachineState, _to: MachineState):
	is_transitioning = false
