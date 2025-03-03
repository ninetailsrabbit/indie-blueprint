extends Node

signal added_pool(pool: IndieBlueprintObjectPool)
signal updated_pool(previous_pool: IndieBlueprintObjectPool, current: IndieBlueprintObjectPool)
signal removed_pool(pool: IndieBlueprintObjectPool)

## [StringName, IndieBlueprintObjectPool]
var available_pools: Dictionary = {}


func add_pool(id: StringName, pool: IndieBlueprintObjectPool, overwrite: bool = false) -> void:
	if not overwrite and available_pools.has(id):
		return
		
	added_pool.emit(available_pools.get_or_add(id, pool))
	

func update_pool(id: StringName, new_pool: IndieBlueprintObjectPool):
	var current_pool := get_pool(id)
	
	if current_pool != null and current_pool != new_pool:
		updated_pool.emit(current_pool, new_pool)
		
	add_pool(id, new_pool, true)


func get_pool(id: StringName) -> IndieBlueprintObjectPool:
	return available_pools.get(id)
	

func remove_pool(id: StringName) -> void:
	if available_pools.has(id):
		removed_pool.emit(available_pools[id])
		
	available_pools.erase(id)
