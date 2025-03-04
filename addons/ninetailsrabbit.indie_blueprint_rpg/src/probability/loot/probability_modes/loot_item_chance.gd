class_name LootItemChance extends Resource

## Set to zero to disable it. Chance in percentage to appear in a loot from 0 to 1.0, where 0.05 means 5% and 1.0 means 100%
@export_range(0.0, 1.0, 0.001) var value: float = 0.0
## A deviation to alter the results of this item by making it easier (-) or more difficult (+).
@export_range(-1.0, 1.0, 0.001) var deviation: float = 0.0


func _init(chance: float, _deviation: float = 0.0) -> void:
	value = chance
	deviation = _deviation


func roll(rng: RandomNumberGenerator, less_than: bool = true) -> bool:
	var item_probability_chance_result: float = rng.randf()
	
	return roll_overcome(item_probability_chance_result, less_than)


func roll_overcome(result: float, less_than: bool = true) -> bool:
	return result < value if less_than else result > value
