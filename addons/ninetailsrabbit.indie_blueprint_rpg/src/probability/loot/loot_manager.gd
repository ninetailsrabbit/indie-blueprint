extends Node

## A set of global loot tables that need to be globally accessible in order to be re-used
var loot_tables: Dictionary = {}


func add_loot_table(id: String, loot_table: IndieBlueprintLootTable) -> void:
	loot_tables[id] = loot_table


func get_tables(ids: Array[String]) -> Array[IndieBlueprintLootTable]:
	var result: Array[IndieBlueprintLootTable] = []
	
	for id: String in ids.filter(func(target_id: String): return loot_tables.has(target_id)):
		result.append(get_table(id))
	
	return result


func get_table(id: String) -> IndieBlueprintLootTable:
	return loot_tables.get(id, null)
