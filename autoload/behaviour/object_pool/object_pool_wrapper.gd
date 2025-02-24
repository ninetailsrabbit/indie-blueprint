class_name ObjectPoolWrapper extends RefCounted


var pool: ObjectPool
var instance: Node
var sleeping: bool = true


func _init(_pool: ObjectPool) -> void:
	pool = _pool
	instance = pool.scene.instantiate()


func kill() -> void:
	pool.kill(self)


func queue_free() -> void:
	if is_instance_valid(self) and not pool.instance.is_queued_for_deletion():
		pool.instance.queue_free()
		free()
