@icon("res://components/behaviour/object_pool/object_pool.svg")
class_name ObjectPool extends Node

signal kill_requested(spawned_object: Variant)
signal kill_all_requested()

@export var scene: PackedScene
@export var create_objects_on_ready: bool = true
@export var max_objects_in_pool: int = 100:
	set(value):
		if value != max_objects_in_pool:
			max_objects_in_pool = maxi(1, absi(value))
@export var process_mode_on_spawn: ProcessMode = Node.PROCESS_MODE_INHERIT

var pool: Array[Variant] = []
var spawned: Array[Variant] = []


func _init(
	_scene: PackedScene,
	 amount: int,
	 create_on_ready: bool = true,
	_process_mode_on_spawn: ProcessMode = Node.PROCESS_MODE_INHERIT
) -> void:
	scene = _scene
	max_objects_in_pool = amount
	create_objects_on_ready = create_on_ready
	process_mode_on_spawn = _process_mode_on_spawn


func _ready() -> void:
	if create_objects_on_ready:
		create_pool(max_objects_in_pool)
	
	kill_requested.connect(on_kill_requested)
	kill_all_requested.connect(on_kill_all_requested)


func create_pool(amount: int) -> void:
	if scene == null:
		push_error("ObjectPool: The scene to spawn is not defined for this object pool")
		return
		
	amount = mini(amount, max_objects_in_pool - pool.size())
	
	for i in amount:
		add_to_pool(scene.instantiate())


func add_to_pool(new_object: Variant) -> void:
	if pool.has(new_object):
		return
		
	new_object.process_mode = Node.PROCESS_MODE_DISABLED
	new_object.hide()
	pool.append(new_object)


func spawn() -> Variant:
	if pool.size() > 0:
		var pool_object: Variant = pool.pop_back()
		pool_object.process_mode = process_mode_on_spawn
		pool_object.show()
		spawned.append(pool_object)
		
		return pool_object
		
	return null
	

func spawn_multiple(amount: int) -> Array[Variant]:
	var spawned_objects: Array[Variant] = []
	
	if pool.size() > 0:
		amount = mini(amount, pool.size())
		
		for i in amount:
			var spawned_object: Variant = spawn()
			
			if spawned_object == null:
				break
			
			spawned_objects.append(spawned_object)
			
	return spawned_objects


func spawn_all() -> Array[Variant]:
	return spawn_multiple(pool.size())


func kill(spawned_object) -> void:
	if spawned.has(spawned_object):
		spawned.erase(spawned_object)
		add_to_pool(spawned_object)


func kill_all() -> void:
	for object: Variant in spawned:
		kill(object)


func on_kill_requested(spawned_object: Variant) -> void:
	kill(spawned_object)


func on_kill_all_requested() -> void:
	kill_all()
