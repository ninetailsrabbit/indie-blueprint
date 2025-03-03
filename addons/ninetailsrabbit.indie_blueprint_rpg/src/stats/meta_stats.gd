class_name RpgCharacterMetaStats extends Resource

enum ClassRange {
	C,
	B,
	A,
	S,
	S_Plus
}

enum ClassType {
	Fire,
	Water,
	Ice,
	Earth,
	Wind,
	Electric,
	Physical,
	Neutral,
	Machine,
	Shadow,
	Light
}

@export var level: int = 1
@export var class_range: ClassRange = ClassRange.C
@export var class_types: Array[ClassType] = [ClassType.Neutral]

@export var hp: int = 100: 
	set(value): 
		hp = clampi(value, 0, max_hp)
@export var max_hp: int = 100
@export var pm: int = 50:
	set(value):
		pm = clampi(value, 0, max_pm)
@export var max_pm: int = 50
@export var raw_physical_attack: int = 50
@export var raw_physical_defense: int = 50
@export var raw_magical_attack: int = 50
@export var raw_magical_defense: int = 50
@export var speed: float = 100.0
@export_category("Classic Stats")
@export var strength: int = 10
@export var constitution: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10
@export var wisdom: int = 10
@export var agility: int = 10
@export var evasion: int = 10
@export var accuracy: int = 10
@export var endurance: int = 10
@export var resistance: int = 10
@export var charisma: int = 10
@export var luck: int = 10
@export_category("Chances")
@export_range(0, 100.0, 0.01) var block_chance: float = 0.1
@export_range(0.0, 100.0, 0.01) var min_block_multiplier_reduction: float = 0.3
@export_range(0.0, 100.0, 0.01) var max_block_multiplier_reduction: float = 0.5
@export_range(0.0, 100.0, 0.01) var critical_chance: float = 0.1
@export_range(0.0, 100.0, 0.01) var min_critical_damage_multiplier: float = 1.5
@export_range(0.0, 100.0, 0.01) var max_critical_damage_multiplier: float = 2.0
@export var resistances: ElementalResistances
@export var negative_status_effects_resistances: NegativeStatusEffectsResistances


#region Range shortcuts
func is_c_range() -> bool:
	return class_range == ClassRange.C
	
func is_b_range() -> bool:
	return class_range == ClassRange.B
	
func is_a_range() -> bool:
	return class_range == ClassRange.A
	
func is_s_range() -> bool:
	return class_range == ClassRange.S

func is_s_plus_range() -> bool:
	return class_range == ClassRange.S_Plus
	
#endregion

#region ClassType shortcuts
func is_fire() -> bool:
	return ClassType.Fire in class_types

func is_water() -> bool:
	return ClassType.Water in class_types

func is_ice() -> bool:
	return ClassType.Ice in class_types

func is_earth() -> bool:
	return ClassType.Earth in class_types

func is_wind() -> bool:
	return ClassType.Wind in class_types

func is_electric() -> bool:
	return ClassType.Electric in class_types

func is_physical() -> bool:
	return ClassType.Physical in class_types

func is_neutral() -> bool:
	return ClassType.Neutral in class_types

func is_machine() -> bool:
	return ClassType.Machine in class_types

func is_shadow() -> bool:
	return ClassType.Shadow in class_types

func is_light() -> bool:
	return ClassType.Light in class_types

#endregion
