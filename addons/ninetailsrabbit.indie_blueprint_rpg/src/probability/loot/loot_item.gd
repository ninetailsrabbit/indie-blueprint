class_name IndieBlueprintLootItem extends Resource


## Unique identifier for this item
@export var id: String = ""
## An optional file path that represents this item
@export_file var file
## An optional scene that represents this item
@export var scene: PackedScene
## The name of the item
@export var name : String
## A shortcut to display the name in short form for limited user interfaces in screen
@export var abbreviation : String
## A description more detailed about this item
@export_multiline var description : String
## Indicates whether this item should drop every time or not.
@export var should_drop_always: bool = false
## When enabled the item is eligible on loot generations
@export var is_enabled: bool = true
## The item is removed from the loot table when looted
@export var is_unique: bool = false
## The weight parameters for this item
@export var weight: LootItemWeight
## The grade of rarity for this item
@export var rarity: LootItemRarity
## The chance percentage for this item
@export var chance: LootItemChance


func can_use_weight() -> bool:
	return is_instance_valid(weight) and weight.value > 0


func can_use_rarity() -> bool:
	return is_instance_valid(rarity)


func can_use_chance() -> bool:
	return is_instance_valid(chance) and chance.value


func enable() -> void:
	is_enabled = true


func disable() -> void:
	is_enabled = false


static func create_from(data: Dictionary = {}) -> IndieBlueprintLootItem:
	var item = IndieBlueprintLootItem.new()
	var valid_properties = item.get_property_list().map(func(property: Dictionary): return property.name)
	
	for property: String in data.keys():
		var property_name: String = property.to_snake_case()
		if valid_properties.has(property_name):
			item[property_name] = data[property]
			
	return item
