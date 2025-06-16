class_name IndieBlueprintDiceRoller extends Node

signal die_rolled(result: int, sides: int)
signal die_rolled_detailed(roll_detailed: DiceRollDetailed)

class DiceRollDetailed extends RefCounted:
	var sides: int
	var number_of_dices: int
	var dices: Array[int] = []
	var sum: int = 0
	var multiply: int = 0
	var exponential: int = 0
	var highest: int = 0
	var lowest: int = 0
	var average: int = 0
	
	func _init(
		_sides: int,
		_number_of_dices: int,
		_dices: Array[int],
		_sum: int,
		_multiply: int,
		_exponential: int,
		_highest: int,
		_lowest: int, 
		_average: int
	) -> void:
		
		sides = _sides
		number_of_dices = _number_of_dices
		dices = _dices
		sum = _sum
		multiply = _multiply
		exponential = _exponential
		highest = _highest
		lowest = _lowest
		average = _average
		

enum RollResultTypes {
	Sum,
	Multiply,
	Exponential,
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


func change_seed(new_seed: int) -> IndieBlueprintDiceRoller:
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
			result = sum_die_values(dice_roll_results)
		RollResultTypes.Multiply:
			result = multiply_die_values(dice_roll_results)
		RollResultTypes.Exponential:
			result = exponential_die_values(dice_roll_results)
		RollResultTypes.Highest:
			result = dice_roll_results.max()
		RollResultTypes.Lowest:
			result = dice_roll_results.min()
		RollResultTypes.Average:
			@warning_ignore("integer_division")
			result = sum_die_values(dice_roll_results) / amount

	return result


func roll_dices_detailed(amount: int, sides: int) -> DiceRollDetailed:
	var detail_result: Dictionary = {
		"sides": sides,
		"dices": [],
		"results": {
			"sum": 0,
			"multiply": 0,
			"exponential": 0,
			"highest": 0,
			"lowest": 0,
			"average": 0
		}
	}
	
	var callable: Callable = func(result: int, _sides: int): detail_result["dices"].append(result)
	
	die_rolled.connect(callable)
	roll_dices(amount, sides)
	die_rolled.disconnect(callable)
	
	## We need this manual assignation to avoid the Array type error accessing it from the dictionary
	var gathered_dices_result: Array[int] = []
	gathered_dices_result.assign(detail_result.dices)
	
	detail_result.results.sum = sum_die_values(gathered_dices_result)
	detail_result.results.multiply = multiply_die_values(gathered_dices_result)
	detail_result.results.exponential = exponential_die_values(gathered_dices_result)
	detail_result.results.highest = gathered_dices_result.max()
	detail_result.results.lowest = gathered_dices_result.min()
	detail_result.results.average = detail_result.results.sum / amount
	
	var die_result: DiceRollDetailed = DiceRollDetailed.new(
		sides,
		amount,
		gathered_dices_result,
		detail_result.results.sum,
		detail_result.results.multiply,
		detail_result.results.exponential,
		detail_result.results.highest,
		detail_result.results.lowest,
		detail_result.results.average,
	)
	
	die_rolled_detailed.emit(die_result)
	
	return die_result
	
	
func roll_dices_sum(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Sum)
	

func roll_dices_highest(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Highest)


func roll_dices_lowest(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Lowest)


func roll_dices_average(amount: int, sides: int) -> int:
	return roll_dices(amount, sides, RollResultTypes.Average)
	
	
func sum_die_values(values: Array[int]) -> int:
	return values.reduce(func(accum: int, value: int): return accum + value, 0)


func multiply_die_values(values: Array[int]) -> int:
	return values.reduce(func(accum: int, value: int): return accum * value, 0)


func exponential_die_values(values: Array[int]) -> int:
	return values.reduce(func(accum: int, value: int): return pow(accum, value), 0)
