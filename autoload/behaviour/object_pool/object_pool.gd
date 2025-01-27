@icon("res://components/behaviour/object_pool/object_pool.svg")
class_name ObjectPool extends Node

const GroupName: StringName = &"object_pools"

signal kill_requested(spawned_object: Variant)
signal kill_all_requested()

@export var id: StringName = &""
@export var scene: PackedScene
@export var create_objects_on_ready: bool = true
@export var max_objects_in_pool: int = 100:
	set(value):
		if value != max_objects_in_pool:
			max_objects_in_pool = maxi(1, absi(value))
@export var process_mode_on_spawn: ProcessMode = Node.PROCESS_MODE_INHERIT

var pool: Array[ObjectPoolWrapper] = []
var spawned: Array[ObjectPoolWrapper] = []


func _init(
	_id: StringName = &"",
	_scene: PackedScene = scene,
	 amount: int = max_objects_in_pool,
	 create_on_ready: bool = create_objects_on_ready,
	_process_mode_on_spawn: ProcessMode = process_mode_on_spawn
) -> void:
	id = _id
	scene = _scene
	max_objects_in_pool = amount
	create_objects_on_ready = create_on_ready
	process_mode_on_spawn = _process_mode_on_spawn


func _enter_tree() -> void:
	add_to_group(GroupName)


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
		add_to_pool(ObjectPoolWrapper.new(self, scene))


func add_to_pool(new_object: ObjectPoolWrapper) -> void:
	if pool.has(new_object):
		return
		
	new_object.instance.process_mode = Node.PROCESS_MODE_DISABLED
	new_object.instance.hide()
	new_object.sleeping = true
	pool.append(new_object)
	
	if not new_object.instance.tree_exiting.is_connected(on_object_exiting_tree.bind(new_object.instance)):
		new_object.instance.tree_exiting.connect(on_object_exiting_tree.bind(new_object.instance))


func spawn() -> ObjectPoolWrapper:
	if pool.size() > 0:
		var pool_object: ObjectPoolWrapper = pool.pop_front()
		pool_object.instance.process_mode = process_mode_on_spawn
		pool_object.instance.show()
		pool_object.sleeping = false
		spawned.append(pool_object)
		
		return pool_object
		
	return null
	

func spawn_multiple(amount: int) -> Array[ObjectPoolWrapper]:
	var spawned_objects: Array[ObjectPoolWrapper] = []
	
	if pool.size() > 0:
		amount = mini(amount, pool.size())
		
		for i in amount:
			var spawned_object: ObjectPoolWrapper = spawn()
			
			if spawned_object == null:
				break
			
			spawned_objects.append(spawned_object)
	
	return spawned_objects


func spawn_all() -> Array[Variant]:
	return spawn_multiple(pool.size())


func kill(spawned_object: ObjectPoolWrapper) -> void:
	spawned.erase(spawned_object)
	
	add_to_pool(spawned_object)


func kill_all() -> void:
	## The loop needs to be in this way as erasing while iterating
	## gives undesired behaviour and elements are left behind.
	for i: int in spawned.size():
		var object: ObjectPoolWrapper = spawned.pop_front()
		kill(object)


func free_pool() -> void:
	for object: ObjectPoolWrapper in pool:
		object.queue_free()


func on_kill_requested(spawned_object: ObjectPoolWrapper) -> void:
	kill(spawned_object)


func on_kill_all_requested() -> void:
	kill_all()


func on_object_exiting_tree(removed_object: ObjectPoolWrapper) -> void:
	pool.erase(removed_object)
	spawned.erase(removed_object)
