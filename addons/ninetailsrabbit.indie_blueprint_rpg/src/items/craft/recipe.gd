class_name CraftableItemRecipe extends Resource

@export var id: StringName
@export var priority: int = 1
@export var item_requirements: Array[CraftableItemRequirement] = []
@export var final_item: CraftableItem


## Where [CraftableItem.id, amount]
func meet_requirements(items: Dictionary[StringName, int]) -> bool:
	for requirement: CraftableItemRequirement in item_requirements:
		if not items.has(requirement.item.id):
			return false
		
		if items[requirement.item.id] < requirement.amount:
			return false
	
	return true
