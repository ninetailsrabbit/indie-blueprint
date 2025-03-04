class_name IndieBlueprintLootTableData extends Resource

enum ProbabilityMode {
	Weight, ## The type of probability technique to apply on a loot, weight is the common case and generate random decimals while each time sum the weight of the next item
	RollTier, ##  The roll tier uses a max roll number and define a number range for each tier.
	PercentageProbability, ## A standard chance based on percentages,
	WeightRollTierCombined, ## The item needs to overcome a weight and roll tier to be looted
	WeightPercentageCombined, ## The item needs to overcome a weight and percentage roll to be looted
	RollTierPercentageCombined, ## The item needs to overcome a roll tier and percentage roll to be looted
	WeightPercentageRollTierCombined ## The items needs to overcome all the probability modes to be looted
}

## The available items that will be used on a roll for this loot table
@export var available_items: Array[IndieBlueprintLootItem] = []
## The probability mode that set the rules to generate items from this table
@export var probability_mode: ProbabilityMode = ProbabilityMode.Weight
## The type of roll, when this is enabled the roll result will be executed per items instead of one per generation time
@export var roll_per_item: bool = false
## When this is enabled items can be repeated for multiple rolls on this generation
@export var allow_duplicates: bool = false
## Max items that this loot table can generate. Set to 0 to disable it and does not apply a limit in the loot generation
@export var items_limit_per_loot: int = 3
## When this is enabled, the always drop items count on the loot limit for this table.
@export var always_drop_items_count_on_limit: bool = false
## Each time a random number between min_roll_tier and max roll will be generated, based on this result if the number
## fits on one of the rarity roll ranges, items of this rarity will be picked randomly
@export var min_roll_tier: float = 0.0:
	set(value):
		min_roll_tier = absf(value)
## Each time a random number between min_roll_tier and max roll will be generated, based on this result if the number
## fits on one of the rarity roll ranges, items of this rarity will be picked randomly
@export var max_roll_tier: float = 100.0:
	set(value):
		if limit_max_roll_tier_from_available_items:
			var max_available_roll = max_current_rarity_roll()
			
			if max_available_roll:
				max_roll_tier = clampf(absf(value), 0.0, max_available_roll)
		else:
			max_roll_tier = absf(value)
## The max roll value will be clamped to the maximum that can be found in the items available for this loot table. 
## So if you set this value to 100 and in the items the maximun found it's 80, this last will be used instead of 100
@export var limit_max_roll_tier_from_available_items: bool = false:
	set(value):
		if value != limit_max_roll_tier_from_available_items:
			limit_max_roll_tier_from_available_items = value
			
			if value:
				max_roll_tier = max_current_rarity_roll()

## Set to zero to not use it. This has priority over seed_string. Define a seed for this loot table. Doing so will give you deterministic results across runs
@export var seed_value: int = 0
## Set it to empty to not use it. Define a seed string that will be hashed to use for deterministic results
@export var seed_string: String = ""

func _init(items: Array[Variant] = []) -> void:
	if not items.is_empty():
		if typeof(items.front()) == TYPE_DICTIONARY:
			_create_from_dictionary(items)
		elif items.front() is IndieBlueprintLootItem:
			available_items.append_array(items)


func items_with_weight_available(items: Array[IndieBlueprintLootItem] = available_items) -> Array[IndieBlueprintLootItem]:
	return items.filter(func(item: IndieBlueprintLootItem): return item.is_enabled and item.can_use_weight())


func items_with_rarity_available(items: Array[IndieBlueprintLootItem] = available_items) -> Array[IndieBlueprintLootItem]:
	return items.filter(func(item: IndieBlueprintLootItem): return item.is_enabled and item.can_use_rarity())


func items_with_valid_chance(items: Array[IndieBlueprintLootItem] = available_items) -> Array[IndieBlueprintLootItem]:
	return items.filter(func(item: IndieBlueprintLootItem): return item.is_enabled and item.can_use_chance())


func max_current_rarity_roll() -> float:
	var max_available_roll = items_with_rarity_available(available_items)\
		.map(func(item: IndieBlueprintLootItem): return item.rarity.max_roll).max()
	
	if max_available_roll:
		return max_available_roll
		
	return max_roll_tier


func _create_from_dictionary(items: Array[Dictionary] = []) -> void:
	for item: Dictionary in items:
		available_items.append(IndieBlueprintLootItem.create_from(item))
