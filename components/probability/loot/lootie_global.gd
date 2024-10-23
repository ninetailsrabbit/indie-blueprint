extends Node

## A set of global loot tables that need to be globally accessible in order to be re-used
var loot_tables: Dictionary = {}


func add_loot_table(id: String, loot_table: LootieTable) -> void:
	loot_tables[id] = loot_table


func get_tables(ids: Array[String]) -> Array[LootieTable]:
	var result: Array[LootieTable] = []
	
	for id: String in ids.filter(func(target_id: String): return loot_tables.has(target_id)):
		result.append(get_table(id))
	
	return result


func get_table(id: String) -> LootieTable:
	return loot_tables.get(id, null)
