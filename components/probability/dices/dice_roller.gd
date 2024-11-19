@icon("res://components/probability/dices/dice_roller.svg")
class_name DiceRoller extends Node

signal die_rolled(result: int, sides: int)


enum RollResultTypes {
	Sum,
	Highest,
	Lowest,
	Average
}

var rng: RandomNumberGenerator


func _init(random: RandomNumberGenerator = null) -> void:
	if random == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	else:
		rng = random


func change_seed(new_seed: int) -> DiceRoller:
	rng.seed = new_seed
	
	return self
	
	
func roll_dices(amount: int, sides: int, roll_type: RollResultTypes = RollResultTypes.Sum) -> int:
	amount = maxi(1, amount)
	sides = maxi(3, sides)
	
	var dice_roll_results: Array[int] = []
	var result: int = 0
	
	for die in amount:
		var die_result: int = rng.randi_range(1, sides)
		dice_roll_results.append(die_result)
		die_rolled.emit(die_result, sides)
	
	match roll_type:
		RollResultTypes.Sum:
			result = ArrayHelper.sum(dice_roll_results)
		RollResultTypes.Highest:
			result = dice_roll_results.max()
		RollResultTypes.Lowest:
			result = dice_roll_results.min()
		RollResultTypes.Average:
			@warning_ignore("integer_division")
			result = ArrayHelper.sum(dice_roll_results) / amount

	return result


func roll_dices_detailed(amount: int, sides: int) -> Dictionary:
	var detail_result: Dictionary = {
		"sides": sides,
		"dices": [],
		"results": {"sum": 0, "highest": 0, "lowest": 0, "average": 0}
	}
	
	var callable: Callable = func(result: int, _sides: int): detail_result["dices"].append(result)
	
	die_rolled.connect(callable)
	roll_dices(amount, sides)
	die_rolled.disconnect(callable)
	
	## We need this manual assignation to avoid the Array type error accessing it from the dictionary
	var gathered_dices_result: Array[int] = []
	gathered_dices_result.assign(detail_result.dices)
	
	detail_result.results.sum = ArrayHelper.sum(gathered_dices_result)
	detail_result.results.highest = gathered_dices_result.max()
	detail_result.results.lowest = gathered_dices_result.min()
	detail_result.results.average = detail_result.results.sum / amount
	
	return detail_result
	
	
func roll_dices_sum(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Sum)
	

func roll_dices_highest(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Highest)


func roll_dices_lowest(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Lowest)


func roll_dices_average(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Average)
