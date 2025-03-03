class_name IndieBlueprintLootTable extends Node

@export var loot_table_data: IndieBlueprintLootTableData

var unique_items_dropped: Array[IndieBlueprintLootItem] = []
var mirrored_items: Array[IndieBlueprintLootItem] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	mirrored_items.clear()
	mirrored_items = loot_table_data.available_items.duplicate()
	
	_prepare_random_number_generator()


func generate(times: int = 1) -> Array[IndieBlueprintLootItem]:
	mirrored_items = loot_table_data.available_items.duplicate() if mirrored_items.is_empty() else mirrored_items
	
	var items_looted: Array[IndieBlueprintLootItem] = []
	var max_picks: int = loot_table_data.items_limit_per_loot
	var size_that_does_not_count_on_loot_limit: int = 0

	times = max(1, abs(times))
	
	if not mirrored_items.is_empty():
		## Filter only items that are enabled for loot
		mirrored_items = mirrored_items.filter(func(item: IndieBlueprintLootItem): return item.is_enabled)
		## Append always the items that always should drop from this loot table
		items_looted.append_array(mirrored_items.filter(func(item: IndieBlueprintLootItem): return item.should_drop_always))
		
		if max_picks > 0 and loot_table_data.always_drop_items_count_on_limit and items_looted.size() >= max_picks:
			remove_unique_items(items_looted)
			return items_looted.slice(0, max_picks)
			
		size_that_does_not_count_on_loot_limit += items_looted.size()
		
		for i in times:
			items_looted.append_array(_generate_loot_by_mode())
			
			remove_unique_items(items_looted)
				
			if not loot_table_data.allow_duplicates:
				items_looted.assign(remove_duplicates(items_looted))
		
	mirrored_items.clear()
	
	return pick_random_values(items_looted, max_picks + size_that_does_not_count_on_loot_limit) if max_picks > 0 else items_looted

## Remove the items that are unique and can be only dropped once from this loot table
func remove_unique_items(items: Array[IndieBlueprintLootItem]) -> void:
	for item: IndieBlueprintLootItem in items.filter(func(item: IndieBlueprintLootItem): return item.is_unique and not item in unique_items_dropped):
		mirrored_items.erase(item)
		loot_table_data.available_items.erase(item)
		unique_items_dropped.append(item)


func roll_items_by_weight() -> Array[IndieBlueprintLootItem]:
	var items_rolled: Array[IndieBlueprintLootItem] = []
	var total_weight: float = 0.0
	
	total_weight = _prepare_weight_on_items(mirrored_items)
	var valid_items: Array[IndieBlueprintLootItem] = loot_table_data.items_with_weight_available(mirrored_items)
	valid_items.shuffle()
	
	if loot_table_data.roll_per_item:
		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.weight.roll(rng, total_weight)))
	else:
		var roll_result: float = snappedf(rng.randf_range(0, total_weight), 0.01)
		
		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.weight.roll_overcome(roll_result)))

	return items_rolled
		
		
func roll_items_by_tier(selected_min_roll_tier: float = loot_table_data.min_roll_tier, selected_max_roll_tier: float = loot_table_data.max_roll_tier) -> Array[IndieBlueprintLootItem]:
	var items_rolled: Array[IndieBlueprintLootItem] = []

	var valid_items: Array[IndieBlueprintLootItem] = loot_table_data.items_with_rarity_available(mirrored_items)
	valid_items.shuffle()
	
	selected_max_roll_tier = clampf(selected_max_roll_tier, 0, loot_table_data.max_current_rarity_roll()) if loot_table_data.limit_max_roll_tier_from_available_items else selected_max_roll_tier

	if loot_table_data.roll_per_item:
		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.rarity.roll(rng, selected_min_roll_tier, selected_max_roll_tier)))
	
	else:
		var roll_result: float = rng.randf_range(selected_min_roll_tier, selected_max_roll_tier)

		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.rarity.roll_overcome(roll_result)))
	
	return items_rolled
		


func roll_items_by_percentage() -> Array[IndieBlueprintLootItem]:
	var items_rolled: Array[IndieBlueprintLootItem] = []

	var valid_items: Array[IndieBlueprintLootItem] = loot_table_data.items_with_valid_chance(mirrored_items)
	valid_items.shuffle()
	
	if loot_table_data.roll_per_item:
		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.chance.roll(rng)))
	
	else:
		var roll_result: float = rng.randf()
		
		items_rolled.append_array(valid_items.filter(func(item: IndieBlueprintLootItem): return item.chance.roll_overcome(roll_result)))
	
	return items_rolled


func change_probability_type(new_type: IndieBlueprintLootTableData.ProbabilityMode) -> void:
	loot_table_data.probability_type = new_type


func add_items(items: Array[IndieBlueprintLootItem] = []) -> void:
	loot_table_data.available_items.append_array(items)
	mirrored_items = loot_table_data.available_items.duplicate()


func add_item(item: IndieBlueprintLootItem) -> void:
	loot_table_data.available_items.append(item)
	loot_table_data.available_items = loot_table_data.available_items
	mirrored_items = loot_table_data.available_items.duplicate()
	

func remove_items(items: Array[IndieBlueprintLootItem] = []) -> void:
	loot_table_data.available_items = loot_table_data.available_items.filter(func(item: IndieBlueprintLootItem): return not item in items)
	mirrored_items = loot_table_data.available_items.duplicate()
	

func remove_item(item: IndieBlueprintLootItem) -> void:
	loot_table_data.available_items.erase(item)
	mirrored_items = loot_table_data.available_items.duplicate()
	
	
func remove_items_by_id(item_ids: Array[StringName] = []) -> void:
	loot_table_data.available_items = loot_table_data.available_items.filter(func(item: IndieBlueprintLootItem): return not item.id in item_ids)
	mirrored_items = loot_table_data.available_items.duplicate()


func remove_item_by_id(item_id: StringName) -> void:
	loot_table_data.available_items  = loot_table_data.available_items.filter(func(item: IndieBlueprintLootItem): return not item.id == item_id)
	mirrored_items = loot_table_data.available_items.duplicate()


func _generate_loot_by_mode(mode: IndieBlueprintLootTableData.ProbabilityMode = loot_table_data.probability_mode) -> Array[IndieBlueprintLootItem]:
	var items_looted: Array[IndieBlueprintLootItem] = []
	
	match loot_table_data.probability_mode:
			loot_table_data.ProbabilityMode.Weight:
				items_looted.append_array(roll_items_by_weight())
				
			loot_table_data.ProbabilityMode.RollTier:
				items_looted.append_array(roll_items_by_tier())
				
			loot_table_data.ProbabilityMode.PercentageProbability:
				items_looted.append_array(roll_items_by_percentage())
				
			loot_table_data.ProbabilityMode.WeightRollTierCombined:
				var weight_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_weight()
				var tier_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_tier()
				
				items_looted.append_array(intersected_elements(weight_items_looted, tier_items_looted))
			
			loot_table_data.ProbabilityMode.WeightPercentageCombined:
				var weight_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_weight()
				var percentage_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_percentage()
			
				items_looted.append_array(intersected_elements(weight_items_looted, percentage_items_looted))
			
			loot_table_data.ProbabilityMode.RollTierPercentageCombined:
				var tier_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_tier()
				var percentage_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_percentage()
			
				items_looted.append_array(intersected_elements(tier_items_looted, percentage_items_looted))
			
			loot_table_data.ProbabilityMode.WeightPercentageRollTierCombined:
				var weight_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_weight()
				var tier_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_tier()
				var percentage_items_looted: Array[IndieBlueprintLootItem] = roll_items_by_percentage()
				
				var weight_tier_intersects: bool = intersects(weight_items_looted, tier_items_looted)
				var weight_percentage_intersects: bool = intersects(weight_items_looted, percentage_items_looted)
				
				if weight_tier_intersects and weight_percentage_intersects:
					items_looted.append_array(intersected_elements(weight_items_looted, tier_items_looted))
				
	return items_looted
	
	
func _prepare_weight_on_items(target_items: Array[IndieBlueprintLootItem] = mirrored_items) -> float:
	var total_weight: float = 0.0
	
	for item: IndieBlueprintLootItem in target_items:
		item.weight.reset_accum_weight()
		total_weight += item.weight.value
		item.weight.accum_weight = total_weight
	
	return total_weight

		
func _prepare_random_number_generator() -> void:
	if loot_table_data.seed_value > 0:
		rng.seed = loot_table_data.seed_value
	elif not loot_table_data.seed_string.is_empty():
		rng.seed = loot_table_data.seed_string.hash()
		


#region Utils
## To detect if a contains elements of b
func intersects(a: Array[Variant], b: Array[Variant]) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true
			
	return false
	
	
## To detect if a contains elements of b
func intersected_elements(a: Array[Variant], b: Array[Variant]) -> Array[Variant]:
	if intersects(a, b):
		return a.filter(func(element): return element in b)
		
	return []


func remove_duplicates(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array := []
	
	for element in array:
		if not cleaned_array.has(element):
			cleaned_array.append(element)
		
	return cleaned_array
	
	
## Flatten any array with n dimensions recursively
func flatten(array: Array[Variant]):
	var result := []
	
	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			result.append_array(flatten(array[i]))
		else:
			result.append(array[i])

	return result


func pick_random_values(array: Array[Variant], items_to_pick: int = 1, duplicates: bool = true) -> Array[Variant]:
	var result := []
	var target = flatten(array.duplicate())
	target.shuffle()
	
	items_to_pick = min(target.size(), items_to_pick)
	
	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)
		
	return result
		

func value_is_between(number: int, min_value: int, max_value: int, inclusive: = true) -> bool:
	if inclusive:
		return number >= min(min_value, max_value) and number <= max(min_value, max_value)
	else :
		return number > min(min_value, max_value) and number < max(min_value, max_value)


func decimal_value_is_between(number: float, min_value: float, max_value: float, inclusive: = true, precision: float = 0.00001) -> bool:
	if inclusive:
		min_value -= precision
		max_value += precision

	return number >= min(min_value, max_value) and number <= max(min_value, max_value)


func chance(rng: RandomNumberGenerator, probability_chance: float = 0.5, less_than: bool = true) -> bool:
	probability_chance = clamp(probability_chance, 0.0, 1.0)
	
	return rng.randf() < probability_chance if less_than else rng.randf() > probability_chance

#endregion
