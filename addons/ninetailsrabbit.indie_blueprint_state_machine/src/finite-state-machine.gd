class_name IndieBlueprintFiniteStateMachine extends Node

signal states_initialized(states: Dictionary)
signal state_changed(from_state: IndieBlueprintMachineState, state: IndieBlueprintMachineState)
signal state_change_failed(from: IndieBlueprintMachineState, to: IndieBlueprintMachineState)
signal stack_pushed(new_state: IndieBlueprintMachineState, stack: Array[IndieBlueprintMachineState])
signal stack_flushed(stack: Array[IndieBlueprintMachineState])

@export var initial_state: IndieBlueprintMachineState
@export var enable_stack: bool = true
@export var stack_capacity: int = 3
@export var flush_stack_when_reach_capacity: bool = false

var states: Dictionary[String, Node] = {}
var transitions: Dictionary[String, IndieBlueprintMachineTransition] = {}
var states_stack: Array[IndieBlueprintMachineState] = []

var is_transitioning: bool = false
var locked: bool = false

var current_state: IndieBlueprintMachineState

func _ready():
	assert(initial_state != null and initial_state is IndieBlueprintMachineState, "IndieBlueprintFiniteStateMachine: This FSM does not have an initial state defined")
	current_state = initial_state
	
	state_changed.connect(on_state_changed)
	state_change_failed.connect(on_state_change_failed)
	
	_prepare_states()
	enter_state(current_state)
	states_initialized.emit(states)
	

func _input(event: InputEvent):
	current_state.handle_input(event)


func _unhandled_input(event: InputEvent):
	current_state.handle_unhandled_input(event)


func _unhandled_key_input(event: InputEvent):
	current_state.handle_key_input(event)


func _physics_process(delta: float):
	current_state.physics_update(delta)


func _process(delta: float):
	current_state.update(delta)


## Alternative syntax to change state
func travel(next_state: Variant, parameters: Dictionary = {}) -> void:
	change_state_to(next_state, parameters)

## Alternative syntax to change state
func travel_to(next_state: Variant, parameters: Dictionary = {}) -> void:
	change_state_to(next_state, parameters)


func change_state_to(next_state: Variant, parameters: Dictionary = {}):
	if not is_transitioning:
		
		if next_state is GDScript:
			if current_state_is_by_class(next_state):
				return
				
			var state_name: String = next_state.get_global_name()
			
			if states.has(state_name):
				run_transition(current_state, states[state_name], parameters)
			else:
				push_error("IndieBlueprintFiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % state_name)
		
		elif typeof(next_state) == TYPE_STRING:
			if current_state_is_by_name(next_state):
				return
			
			if states.has(next_state):
				run_transition(current_state, states[next_state], parameters)
			else:
				push_error("IndieBlueprintFiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % next_state)
		
		elif next_state is IndieBlueprintMachineState:
			if current_state_is(next_state):
				return
				
			if states.values().has(next_state):
				run_transition(current_state, next_state, parameters)
			else:
				push_error("IndieBlueprintFiniteStateMachine: The change of state cannot be done because %s does not exist in this Finite State Machine" % next_state.name)
		
		
func run_transition(from: IndieBlueprintMachineState, to: IndieBlueprintMachineState, parameters: Dictionary = {}):
	is_transitioning = true

	var transition_name = _build_transition_name(from, to)

	if not transitions.has(transition_name):
		transitions[transition_name] = NeutralMachineTransition.new()
	
	var transition: IndieBlueprintMachineTransition = transitions[transition_name] as IndieBlueprintMachineTransition
	transition.from_state = from
	transition.to_state = to
	transition.parameters = parameters
	
	if transition.should_transition():
		transition.on_transition()
		state_changed.emit(from, to)
		
		return
	
	state_change_failed.emit(from, to)

## Example register_transition(WalkToRun.new())
func register_transition(transition: IndieBlueprintMachineTransition):
	transitions[transition.get_script().get_global_name()] = transition


func register_transitions(new_transitions: Array[IndieBlueprintMachineTransition]):
	for transition in new_transitions:
		register_transition(transition)
	

func enter_state(state: IndieBlueprintMachineState):
	is_transitioning = false
	state.entered.emit()
	state.enter()
		

func exit_state(state: IndieBlueprintMachineState, _next_state: IndieBlueprintMachineState):
	state.finished.emit(_next_state)
	state.exit(_next_state)


func current_state_is_by_name(state: String) -> bool:
	return current_state.name.strip_edges().to_lower() == state.strip_edges().to_lower()


func current_state_is(state: IndieBlueprintMachineState) -> bool:
	return current_state_is_by_name(state.name)


func current_state_is_by_class(state: GDScript) -> bool:
	return current_state.get_script() == state


func current_state_is_not(_states: Array = []) -> bool:
	return _states.any(func(state):
		if typeof(state) == TYPE_STRING:
			return current_state_is_by_name(state)
		
		if state is IndieBlueprintMachineState:
			return current_state_is(state)
		
		return false
	)
	

func old_state() -> IndieBlueprintMachineState:
	return null if states_stack.is_empty() else states_stack.front()


func next_to_old_state() -> IndieBlueprintMachineState:
	return state_from_stack_on_position(1)


func last_state() -> IndieBlueprintMachineState:
	return null if states_stack.is_empty() else states_stack.back()


func next_to_last_state() -> IndieBlueprintMachineState:
	return state_from_stack_on_position(maxi(1, states_stack.size() - 2))


func state_from_stack_on_position(position: int) -> IndieBlueprintMachineState:
	if states_stack.is_empty() or position < 0 or position >= states_stack.size():
		return null
	
	return states_stack[position]
	

func _build_transition_name(from: IndieBlueprintMachineState, to: IndieBlueprintMachineState) -> String:
	var transition_name: String = "%sTo%sTransition" % [from.name.strip_edges(), to.name.strip_edges()]
	
	if not transitions.has(transition_name):
		transition_name = "AnyTo%sTransition" % to.name.strip_edges()
	
	return transition_name
	

func push_state_to_stack(state: IndieBlueprintMachineState) -> void:
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
	locked = true

	
func unlock_state_machine():
	process_mode =  ProcessMode.PROCESS_MODE_INHERIT
	locked = false


func _prepare_states(node: Node = self):
	for child in node.get_children(true):
		if child is IndieBlueprintMachineState:
			_add_state_to_dictionary(child)
		else:
			if child.get_child_count() > 0:
				_prepare_states(child)


func _add_state_to_dictionary(state: IndieBlueprintMachineState):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())
		state.FSM = self
		state.ready()


func on_state_changed(from: IndieBlueprintMachineState, to: IndieBlueprintMachineState):
	push_state_to_stack(from)
	exit_state(from, to)
	enter_state(to)

	current_state = to


func on_state_change_failed(_from: IndieBlueprintMachineState, _to: IndieBlueprintMachineState):
	is_transitioning = false
