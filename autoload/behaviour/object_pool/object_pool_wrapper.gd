class_name ObjectPoolWrapper extends RefCounted


var pool: ObjectPool
var scene: PackedScene
var instance: Node
var sleeping: bool = true


func _init(_pool: ObjectPool, _scene: PackedScene) -> void:
	pool = _pool
	scene = _scene
	instance = scene.instantiate()


func kill() -> void:
	pool.kill(self)
