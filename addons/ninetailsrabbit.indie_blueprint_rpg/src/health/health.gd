class_name IndieBlueprintHealth extends Node

signal health_changed(amount: int, type: Types)
signal invulnerability_changed(active: bool)
signal died

@export_group("Health Parameters")
## Its maximum achievable health
@export var max_health: int = 100
## Health percentage that can be surpassed when life-enhancing methods such as healing or shielding are used.
@export var health_overflow_percentage: float = 0.0
## The actual health of the node
@export var current_health: int:
	set(value):
		current_health = clamp(value, 0, max_health_overflow)

@export_group("Additional Behaviors")
## The amount of health regenerated each second
@export var health_regen: int = 0
## Every tick it applies the health regen amount value
@export var health_regen_tick_time : float = 1.0
## The invulnerability flag, when is true no damage is received but can be healed
@export var is_invulnerable: bool = false:
	set(value):
		if is_invulnerable != value:
			invulnerability_changed.emit(value)
		
		is_invulnerable = value
## How long the invulnerability will last, set this value as zero to be an indefinite period
@export var invulnerability_time: float = 1.5

enum Types {
	Damage,
	Health,
	Regen
}

## TIMERS ##
var invulnerability_timer: Timer
var health_regen_timer: Timer

var max_health_overflow: int:
	get:
		return max_health + (max_health * health_overflow_percentage / 100)


func _ready():
	enable_health_regen(health_regen)
	enable_invulnerability(is_invulnerable, invulnerability_time)
	
	health_changed.connect(on_health_changed)
	died.connect(on_died)


func damage(amount: int):
	if is_invulnerable: 
		amount = 0
	
	amount = absi(amount)
	current_health = max(0, current_health - amount)
	
	health_changed.emit(amount, Types.Damage)


func health(amount: int, type: Types = Types.Health):
	amount = absi(amount)
	current_health += amount
	
	health_changed.emit(amount, type)
	

func check_is_dead() -> bool:
	var is_dead: bool = current_health <= 0
	
	if is_dead:
		died.emit()

	return is_dead


func get_health_percent() -> Dictionary:
	var current_health_percentage = snappedf(current_health / float(max_health), 0.01)
	
	return {
		"current_health_percentage": minf(current_health_percentage, 1.0),
		"overflow_health_percentage": maxf(0.0, current_health_percentage - 1.0),
		"overflow_health": max(0, current_health - max_health)
	}
	

func enable_invulnerability(enable: bool, time: float = invulnerability_time):
	is_invulnerable = enable
	invulnerability_time = time

	_create_invulnerability_timer(invulnerability_time)

	if is_invulnerable:
		if invulnerability_time > 0:
			invulnerability_timer.start()
	else:
		invulnerability_timer.stop()


func enable_health_regen(amount: int = health_regen, time: float = health_regen_tick_time):
	health_regen = amount
	health_regen_tick_time = time
	
	_create_health_regen_timer(health_regen_tick_time)
	
	if health_regen_timer:
		if current_health >= max_health and (health_regen_timer.time_left > 0 or health_regen <= 0):
			health_regen_timer.stop()
			return
		
		if health_regen > 0:
			if time != health_regen_timer.wait_time:
				health_regen_timer.stop()
				health_regen_timer.wait_time = time
			
			if not health_regen_timer.time_left > 0 or health_regen_timer.is_stopped():
				health_regen_timer.start()


func _create_health_regen_timer(time: float = health_regen_tick_time):
	if health_regen_timer:
		if health_regen_timer.wait_time != time and time > 0:
			health_regen_timer.stop()
			health_regen_timer.wait_time = time
	else:
		health_regen_timer = _create_idle_timer(max(0.05, time), true, false)
		health_regen_timer.name = "HealthRegenTimer"

		add_child(health_regen_timer)
		health_regen_timer.timeout.connect(on_health_regen_timer_timeout)


func _create_invulnerability_timer(time: float = invulnerability_time):
	if invulnerability_timer:
		if invulnerability_timer.wait_time != time and time > 0:
			invulnerability_timer.stop()
			invulnerability_timer.wait_time = time
	else:
		invulnerability_timer = _create_idle_timer(max(0.05, time), false, true)
		invulnerability_timer.name = "InvulnerabilityTimer"

		add_child(invulnerability_timer)
		invulnerability_timer.timeout.connect(on_invulnerability_timer_timeout)


func _create_idle_timer(wait_time: float = 1.0, autostart: bool = false, one_shot: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.autostart = autostart
	timer.one_shot = one_shot
	
	return timer

## SIGNAL CALLBACKS ##
func on_health_changed(amount: int, type: Types):
	if type == Types.Damage:
		enable_health_regen()
		Callable(check_is_dead).call_deferred()


func on_died():
	health_regen_timer.stop()
	invulnerability_timer.stop()
	

func on_health_regen_timer_timeout():
	health(health_regen, Types.Regen)

		
func on_invulnerability_timer_timeout():
	enable_invulnerability(false)
