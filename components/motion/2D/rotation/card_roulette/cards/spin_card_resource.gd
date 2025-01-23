class_name SpinCardResource extends Resource


enum ElementalTypes {
	Fire,
	Electric,
	Water,
	Ice,
	Earth,
	Grass,
	Wind,
	Divine,
	Shadow,
	Neutral,
	Machine
}

enum CardRange {
	C,
	B,
	A,
	S,
	S_Plus
}

## Leave it to zero to run indefinitely on every tick of the roulette wheel
@export var amount_of_ticks: int = 0
@export var elemental_type: ElementalTypes = ElementalTypes.Neutral
@export var range: CardRange = CardRange.C
@export var base_damage: float = 0
@export var base_elemental_damage: float = 0
## A list of node groups where this spin card affects when the effect starts
@export var target_groups: Array[StringName] = []

#region Card range
func is_range_c() -> bool:
	return range == CardRange.C
	
func is_range_b() -> bool:
	return range == CardRange.B
	
func is_range_a() -> bool:
	return range == CardRange.A

func is_range_s() -> bool:
	return range == CardRange.S
	
func is_range_s_plus() -> bool:
	return range == CardRange.S_Plus
#endregion

#region Elemental type
func is_fire_element() -> bool:
	return elemental_type == ElementalTypes.Fire
	
func is_electric_element() -> bool:
	return elemental_type == ElementalTypes.Electric
	
func is_water_element() -> bool:
	return elemental_type == ElementalTypes.Water
	
func is_ice_element() -> bool:
	return elemental_type == ElementalTypes.Ice
	
func is_earth_element() -> bool:
	return elemental_type == ElementalTypes.Earth
	
func is_wind_element() -> bool:
	return elemental_type == ElementalTypes.Wind
	
func is_grass_element() -> bool:
	return elemental_type == ElementalTypes.Grass

func is_divine_element() -> bool:
	return elemental_type == ElementalTypes.Divine

func is_shadow_element() -> bool:
	return elemental_type == ElementalTypes.Shadow
#endregion	
