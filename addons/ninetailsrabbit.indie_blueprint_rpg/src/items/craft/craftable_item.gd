class_name CraftableItem extends Resource

enum MaterialType {
	Food,             ## Edible items, ingredients for consumption
	Stone,            ## Rocks, undifferentiated minerals, raw geological formations
	Metal,            ## Ores, ingots, or refined forms of common metals
	Wood,             ## Logs, planks, sticks, or other unworked timber
	Fabric,           ## Cloth, thread, woven materials, or fibers
	Leather,          ## Tanned hide, processed animal skin
	Gem,              ## Precious stones, cut crystals, or valuable minerals
	Liquid,           ## Water, oils, potions, or unclassified fluid substances
	Powder,           ## Dusts, crushed materials, or fine particulate substances
	Bone,             ## Skeletons, fragments of bone, or skeletal remains
	Scale,            ## From reptiles, fish, or other scaled creatures
	Hide,             ## Raw animal skin, unprocessed
	Glass,            ## Manufactured glass, shards, or vitreous materials
	Ore,              ## Raw, unprocessed metal ore (e.g., Iron Ore, Copper Ore)
	Crystal,          ## More defined than 'Gem', often for magical or energy purposes
	Plant,            ## Herbs, flowers, leaves, unrefined plant matter
	Fungus,           ## Mushrooms, molds, various fungi
	Slime,            ## Oozes, viscous bodily fluids
	Chitin,           ## Exoskeletons of insects, arachnids, or crustaceans
	Pearl,            ## From mollusks, unique aquatic gems
	Feather,          ## From birds or feathered creatures
	Ingot,            ## Refined metal bars (e.g., Iron Ingot, Steel Ingot)
	Potion,           ## Crafted magical or alchemical liquids (could be a sub-type of Liquid)
	Scroll,           ## Paper-based items with magical properties
	Component,        ## Generic crafting part, mechanism, or complex assembly (e.g., gears, springs)
	Alloy,            ## Blended metals (e.g., Bronze, Steel - more specific than 'Metal')
	Spirit,           ## Ethereal essences, captured souls, magical energy
	Chemical,         ## Acids, bases, unique manufactured compounds
	Resin,            ## Sticky plant exudates, sap
	DragonScale,      ## Specific, powerful scales
	MonsterPart,      ## Eyes, teeth, claws, hearts from various monsters
	ElementalEssence, ## Condensed elemental energy (e.g., Fire Essence, Water Essence)
	Vial,             ## Empty or full small containers, often for liquids
	RuneStone,        ## Stones imbued with magical symbols
	Obsidian,         ## Volcanic glass, often strong or magical
	MythicFabric,     ## Enchanted cloth, rare woven materials
	ArcaneDust        ## Dust with magical properties, often used for enchantments
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var material_type: MaterialType
@export var stackable: bool = true
@export var max_amount: int = 10:
	set(value):
		if value != max_amount:
			max_amount = value if stackable else 1
			

func is_food() -> bool:
	return material_type == MaterialType.Food

func is_stone() -> bool:
	return material_type == MaterialType.Stone

func is_metal() -> bool:
	return material_type == MaterialType.Metal
	
func is_wood() -> bool:
	return material_type == MaterialType.Wood

func is_fabric() -> bool:
	return material_type == MaterialType.Fabric
	
func is_leather() -> bool:
	return material_type == MaterialType.Leather
	
func is_gem() -> bool:
	return material_type == MaterialType.Gem

func is_liquid() -> bool:
	return material_type == MaterialType.Liquid
	
func is_powder() -> bool:
	return material_type == MaterialType.Powder

func is_bone() -> bool:
	return material_type == MaterialType.Bone

func is_scale() -> bool:
	return material_type == MaterialType.Scale

func is_hide() -> bool:
	return material_type == MaterialType.Hide

func is_glass() -> bool:
	return material_type == MaterialType.Glass

func is_ore() -> bool:
	return material_type == MaterialType.Ore

func is_crystal() -> bool:
	return material_type == MaterialType.Crystal

func is_plant() -> bool:
	return material_type == MaterialType.Plant

func is_fungus() -> bool:
	return material_type == MaterialType.Fungus

func is_slime() -> bool:
	return material_type == MaterialType.Slime

func is_chitin() -> bool:
	return material_type == MaterialType.Chitin

func is_pearl() -> bool:
	return material_type == MaterialType.Pearl

func is_feather() -> bool:
	return material_type == MaterialType.Feather

func is_ingot() -> bool:
	return material_type == MaterialType.Ingot

func is_potion() -> bool:
	return material_type == MaterialType.Potion

func is_scroll() -> bool:
	return material_type == MaterialType.Scroll

func is_component() -> bool:
	return material_type == MaterialType.Component

func is_alloy() -> bool:
	return material_type == MaterialType.Alloy

func is_spirit() -> bool:
	return material_type == MaterialType.Spirit

func is_chemical() -> bool:
	return material_type == MaterialType.Chemical

func is_resin() -> bool:
	return material_type == MaterialType.Resin

func is_dragon_scale() -> bool:
	return material_type == MaterialType.DragonScale

func is_monster_part() -> bool:
	return material_type == MaterialType.MonsterPart

func is_elemental_essence() -> bool:
	return material_type == MaterialType.ElementalEssence

func is_vial() -> bool:
	return material_type == MaterialType.Vial

func is_rune_stone() -> bool:
	return material_type == MaterialType.RuneStone

func is_obsidian() -> bool:
	return material_type == MaterialType.Obsidian

func is_mythic_fabric() -> bool:
	return material_type == MaterialType.MythicFabric

func is_arcane_dust() -> bool:
	return material_type == MaterialType.ArcaneDust
