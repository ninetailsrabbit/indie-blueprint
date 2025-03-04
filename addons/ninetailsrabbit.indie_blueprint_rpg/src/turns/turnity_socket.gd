class_name IndieBlueprintTurnitySocket extends Node

signal started_turn
signal ended_turn
signal skipped
signal blocked(turns_blocked: int)
signal unblocked
signal second_passed(remaining_seconds: int)

const GroupName: StringName = &"turnity-socket"

## The node associated with the socket to be accessible at the start or end of a turn. By default assign the parent
@export var actor: Node
## The unique identifier to access this socket
@export var id: StringName
## The turn duration for this socket, set it to zero to make it indefinite
@export var turn_duration: float = 0:
	set(value):
		if turn_duration != value:
			turn_duration = value
			
			change_turn_duration(turn_duration)
			
## The maximum turns this socket can be blocked, when a socket it's blocked the turn it's skipped automatically
@export var max_turns_can_be_blocked: int = 3
## The turn enters normally but when it is blocked the turns_blocked is reduced by one and the turn is automatically skipped
@export var skip_auto_when_blocked: bool = true

var turn_timer: Timer
var turns_blocked: int = 0:
	set(value):
		var previous_value: int = turns_blocked
		
		turns_blocked = clampi(value, 0, max_turns_can_be_blocked)
		
		if previous_value != turns_blocked and turns_blocked == 0:
			unblock()
		
var is_active: bool = false:
	set(value):
		if value != is_active:
			if value:
				started_turn.emit()
			else:
				ended_turn.emit()
				
			is_active = value


var is_blocked: bool = false:
	set(value):
		if value != is_blocked:
			if value:
				blocked.emit(turns_blocked)
			else:
				unblocked.emit()
				
		is_blocked = value


var current_seconds_passed: int = 0:
	set(value):
		if value != current_seconds_passed:
			current_seconds_passed = clampi(value, 0, turn_duration)
			
			if turn_duration > 0:
				if current_seconds_passed >= turn_duration:
					end()
				else:
					second_passed.emit(turn_duration - current_seconds_passed)

func _enter_tree() -> void:
	add_to_group(GroupName)
	_create_turn_timer()
	
	skipped.connect(on_skipped)
	blocked.connect(on_blocked)


func _ready() -> void:
	if actor == null:
		actor = get_parent()


func start() -> void:
	is_active = true
	
	if turn_duration > 0:
		turn_timer.start()
		
	if is_blocked and turns_blocked > 0:
		turns_blocked -= 1
		skip()


func end() -> void:
	stop_turn_timer()
	current_seconds_passed = 0
	is_active = false
	

func skip() -> void:
	if is_active:
		skipped.emit()


func block(turns_amount: int) -> void:
	turns_blocked += absi(turns_amount)
	is_blocked = true
	
	if skip_auto_when_blocked:
		skip()


func unblock() -> void:
	is_blocked = false
	turns_blocked = 0
	
	
func change_turn_duration(new_duration: float) -> IndieBlueprintTurnitySocket:
	if is_instance_valid(turn_timer) and turn_timer.is_inside_tree():
		turn_timer.stop()
		turn_duration = new_duration
		
		if is_active:
			turn_timer.start()

	return self
	

func reset_turn_timer():
	if is_instance_valid(turn_timer) and turn_timer.time_left > 0:
		turn_timer.start()


func stop_turn_timer():
	if is_instance_valid(turn_timer) and turn_timer.time_left > 0:
		turn_timer.stop()

	
#region Private
func _create_turn_timer():
	if turn_timer == null:
		turn_timer = _create_idle_timer()
		turn_timer.name = "TurnitySocketTimer"

		add_child(turn_timer)
		turn_timer.timeout.connect(on_turn_timer_timeout)


func _create_idle_timer(wait_time: float = 1.0, autostart: bool = false, one_shot: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.autostart = autostart
	timer.one_shot = one_shot
	
	return timer
#endregion

#region Signall callbacks
func on_turn_timer_timeout():
	current_seconds_passed += 1


func on_skipped() -> void:
	stop_turn_timer()
	end()


func on_blocked(_turns_blocked: int) -> void:
	stop_turn_timer()
	end()
#endregion
