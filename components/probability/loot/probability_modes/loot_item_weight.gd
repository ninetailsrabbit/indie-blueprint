class_name LootItemWeight extends Resource

## The weight value for this items to appear in a loot, the more the weight, more the chance to be looted
@export var value: float = 1.0

var accum_weight: float = 0.0


func _init(weight: float) -> void:
	value = weight
	

func reset_accum_weight() -> void:
	accum_weight = 0.0


func roll(rng: RandomNumberGenerator, total_weight: float) -> bool:
	var weight_roll_result: float = snappedf(rng.randf_range(0, total_weight), 0.01)
	
	return roll_overcome(weight_roll_result)


func roll_overcome(result: float) -> bool:
	return result < accum_weight
