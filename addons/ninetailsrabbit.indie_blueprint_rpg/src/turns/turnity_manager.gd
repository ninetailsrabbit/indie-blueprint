extends Node
 
signal created_sequencial_turn_session(ordered_sockets: Array[IndieBlueprintTurnitySocket])
signal started_turn_session
signal ended_turn_session(total_turns: Array[IndieBlueprintTurnitySocket])
signal maximum_turns_reached(total_turns: Array[IndieBlueprintTurnitySocket])
signal started_turn(socket: IndieBlueprintTurnitySocket)
signal ended_turn(socket: IndieBlueprintTurnitySocket)
signal blocked_turn(socket: IndieBlueprintTurnitySocket, turns_blocked: int)
signal skipped_turn(socket: IndieBlueprintTurnitySocket)
signal changed_turn(from: IndieBlueprintTurnitySocket, to: IndieBlueprintTurnitySocket)
signal second_passed(socket: IndieBlueprintTurnitySocket, remaining_seconds: int)

enum Modes {
	Serial ## The turns are assigned in series with a defined formation
}

var current_turnity_sockets: Array[IndieBlueprintTurnitySocket] = []
var current_turnity_socket: IndieBlueprintTurnitySocket


var turns_completed: Array[IndieBlueprintTurnitySocket] = []
var current_session_max_turns: int = 0 ## Set to zero to not have a limit


func _enter_tree() -> void:
	maximum_turns_reached.connect(on_maximum_turns_reached)


func start_new_serial_turn_session(ordered_sockets: Array[IndieBlueprintTurnitySocket], turn_duration: float = 0, max_turns: int = 0) -> Error:
	if ordered_sockets.is_empty():
		push_error("IndieBlueprintTurnityManager: A new sequencial turn session cannot be created from an empty array of turnity sockets")
		
		return ERR_PARAMETER_RANGE_ERROR
		
	if ordered_sockets.size() == 1:
		push_error("IndieBlueprintTurnityManager: A new sequencial turn session cannot be created from an individual turnity socket")
		
		return ERR_PARAMETER_RANGE_ERROR
	
	current_turnity_sockets = ordered_sockets
	current_session_max_turns = max_turns
	
	for socket: IndieBlueprintTurnitySocket in current_turnity_sockets:
		socket.turn_duration = turn_duration
		
	connect_sockets(current_turnity_sockets)
	
	current_turnity_socket = initial_turnity_socket()
	current_turnity_socket.start()
	
	started_turn_session.emit()
		
	return OK


func end_current_turn_session() -> void:
	disconnect_sockets(current_turnity_sockets)
		
	if current_turnity_socket != null and current_turnity_socket.is_active:
		current_turnity_socket.end()
	
	current_turnity_sockets.clear()
	current_turnity_socket = null
	
	ended_turn_session.emit(turns_completed)
	
	turns_completed.clear()


#region Accessors
func initial_turnity_socket() -> IndieBlueprintTurnitySocket:
	if current_turnity_sockets.size() > 1:
		return current_turnity_sockets.front()
		
	return null


func last_turnity_socket() -> IndieBlueprintTurnitySocket:
	if current_turnity_sockets.size() > 1:
		return current_turnity_sockets.back()
		
	return null
	
	
func turnity_socket_on_position(index: int) -> IndieBlueprintTurnitySocket:
	if index < current_turnity_sockets.size():
		return current_turnity_sockets[index]
	
	return null
	
	
func get_sockets_from_tree() -> Array[IndieBlueprintTurnitySocket]:
	var sockets: Array[IndieBlueprintTurnitySocket] = []
	sockets.assign(get_tree().get_nodes_in_group(IndieBlueprintTurnitySocket.GroupName))
	
	return sockets


func get_sockets_from_node(node: Node) -> Array[IndieBlueprintTurnitySocket]:
	var sockets: Array[IndieBlueprintTurnitySocket] = []
	sockets.assign(find_nodes_of_custom_class(node, IndieBlueprintTurnitySocket))
	
	return sockets


func socket_position(socket: IndieBlueprintTurnitySocket) -> int:
	return current_turnity_sockets.find(socket)


func connect_sockets(sockets: Array[IndieBlueprintTurnitySocket] = current_turnity_sockets) -> void:
	for socket: IndieBlueprintTurnitySocket in sockets:
		connect_socket(socket)


func disconnect_sockets(sockets: Array[IndieBlueprintTurnitySocket] = current_turnity_sockets) -> void:
	for socket: IndieBlueprintTurnitySocket in sockets:
		disconnect_socket(socket)


func connect_socket(socket: IndieBlueprintTurnitySocket) -> void:
	if not socket.started_turn.is_connected(on_started_socket_turn):
		socket.started_turn.connect(on_started_socket_turn.bind(socket))
			
	if not socket.ended_turn.is_connected(on_ended_socket_turn.bind(socket)):
		socket.ended_turn.connect(on_ended_socket_turn.bind(socket))

	if not socket.skipped.is_connected(on_skipped_socket_turn):
		socket.skipped.connect(on_skipped_socket_turn.bind(socket))
		
	if not socket.blocked.is_connected(on_blocked_socket.bind(socket)):
		socket.blocked.connect(on_blocked_socket.bind(socket))
		
	if not socket.second_passed.is_connected(on_socket_second_passed.bind(socket)):
		socket.second_passed.connect(on_socket_second_passed.bind(socket))


func disconnect_socket(socket: IndieBlueprintTurnitySocket) -> void:
	if socket.started_turn.is_connected(on_started_socket_turn):
		socket.started_turn.disconnect(on_started_socket_turn.bind(socket))
		
	if socket.ended_turn.is_connected(on_ended_socket_turn.bind(socket)):
		socket.ended_turn.disconnect(on_ended_socket_turn.bind(socket))

	if socket.skipped.is_connected(on_skipped_socket_turn):
		socket.skipped.disconnect(on_skipped_socket_turn.bind(socket))
		
	if socket.blocked.is_connected(on_blocked_socket.bind(socket)):
		socket.blocked.disconnect(on_blocked_socket.bind(socket))
		
	if socket.second_passed.is_connected(on_socket_second_passed.bind(socket)):
		socket.second_passed.disconnect(on_socket_second_passed.bind(socket))
#endregion

func _maximum_turns_reached() -> bool:
	return current_session_max_turns > 0 and turns_completed.size() >= current_session_max_turns

## Only works for native custom class not for GDScriptNativeClass
## Example NodePositioner.find_nodes_of_custom_class(self, IndieBlueprintTurnitySocket)
func find_nodes_of_custom_class(node: Node, class_to_find: Variant) -> Array:
	var  result := []
	
	var childrens = node.get_children(true)

	for child: Node  in childrens:
		if child.get_script() == class_to_find:
			result.append(child)
		else:
			result.append_array(find_nodes_of_custom_class(child, class_to_find))
	
	return result

#region Signal callbacks
func on_started_socket_turn(socket: IndieBlueprintTurnitySocket) -> void:
	current_turnity_socket = socket
	started_turn.emit(current_turnity_socket)


func on_ended_socket_turn(socket: IndieBlueprintTurnitySocket) -> void:
	turns_completed.append(socket)
	ended_turn.emit(socket)
	
	if _maximum_turns_reached():
		maximum_turns_reached.emit(turns_completed)
	else:
		var next_socket_index: int = current_turnity_sockets.find(socket) + 1
		var next_socket: IndieBlueprintTurnitySocket
		
		if next_socket_index < current_turnity_sockets.size():
			next_socket = turnity_socket_on_position(next_socket_index)
		else:
			next_socket = initial_turnity_socket()
		
		next_socket.start()
		
		changed_turn.emit(socket, next_socket)


func on_skipped_socket_turn(socket: IndieBlueprintTurnitySocket) -> void:
	skipped_turn.emit(socket)


func on_blocked_socket(turns_blocked: int, socket: IndieBlueprintTurnitySocket) -> void:
	blocked_turn.emit(socket, turns_blocked)


func on_socket_second_passed(remaining_seconds: int, socket: IndieBlueprintTurnitySocket) -> void:
	second_passed.emit(socket, remaining_seconds)
	
	
func on_maximum_turns_reached(_socket_turns_completed: Array[IndieBlueprintTurnitySocket]) -> void:
	end_current_turn_session()
#endregion
