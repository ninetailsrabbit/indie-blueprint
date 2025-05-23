extends Node

@export var recipes: Array[CraftableItemRecipe] = []

## Once the recipe is found, the item ids are indexed to use as a lookup in this dictionary
## improving the performance. This is because we have a linear search on the recipes array O(n)
var recipes_index: Dictionary[String, CraftableItemRecipe]

	
func add_recipes(recipes: Array[CraftableItemRecipe]) -> void:
	for recipe: CraftableItemRecipe in recipes:
		add_recipe(recipe)
	


func add_recipe(new_recipe: CraftableItemRecipe) -> void:
	if not recipes.has(new_recipe):
		recipes.append(new_recipe)


func remove_recipes(recipes: Array[CraftableItemRecipe]) -> void:
	for recipe: CraftableItemRecipe in recipes:
		remove_recipe(recipe)
	
	
	
func remove_recipe(recipe: CraftableItemRecipe) -> void:
	recipes.erase(recipe)


## Where [CraftableItem.id, amount]
func find_recipe_from_selection(items: Dictionary[CraftableItem, int]) -> CraftableItemRecipe:
	var selected_items: Dictionary[StringName, int] = {}
	selected_items.assign(IndieBlueprintRpgUtils.transform_dictionary_key(items, "id"))
	
	var index: String = lookup_index_from_selection(selected_items)
	
	if recipes_index.has(index):
		return recipes_index[index]
		
	var current_recipes: Array[CraftableItemRecipe] = recipes.duplicate()
	_sort_recipes_by_desc_priority(current_recipes)
	
	var found_recipe: CraftableItemRecipe
	
	for recipe: CraftableItemRecipe in recipes:
		if recipe.meet_requirements(selected_items):
			found_recipe = recipe
			recipes_index[index] = found_recipe
			break

	return found_recipe
	
	
func lookup_index_from_selection(selected_items: Dictionary[StringName, int]) -> String:
	var selected_items_sorted_ids: Array[String] = []
	selected_items_sorted_ids.assign(selected_items.keys()\
		.map(func(id: StringName): return "%s%d" % [id, selected_items[id]]))
		
	selected_items_sorted_ids.sort()
	
	return  "_".join(selected_items_sorted_ids)


func _sort_recipes_by_desc_priority(selected_recipes: Array[CraftableItemRecipe]) -> void:
	selected_recipes.sort_custom(
		func(recipe_a: CraftableItemRecipe, recipe_b: CraftableItemRecipe): recipe_a.priority > recipe_b.priority)
