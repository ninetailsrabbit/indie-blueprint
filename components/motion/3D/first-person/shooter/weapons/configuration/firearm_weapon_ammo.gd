class_name FireArmWeaponAmmo extends Resource

## The initial ammunition when this weapon is pickup
@export var initial_ammunition: int = 0
## Max ammunition that this weapon can carry
@export var max_ammunition: int = 0
## The total ammunition this weapon have in this moment
@export var current_ammunition: int = 0:
	set(value):
		current_ammunition = max(0, min(value, max_ammunition))
## when reach zero reloads automatically until this amount with this quantity with the remaining ammunition available
@export var magazine_size: int = 0
## The current ammunition available in the magazine to shoot
@export var current_magazine: int = 0:
	set(value):
		current_magazine =  max(0, min(value, magazine_size))
## Ammunition in the chamber, is used when cartridge ammunition runs out and cartridges are not reloaded
@export var chamber: int = 0


func has_ammunition_to_shoot() -> bool:
	return current_magazine > 0 or chamber > 0
	
	
func can_reload() -> bool:
	return current_ammunition > 0 and current_magazine < magazine_size


func magazine_empty() -> bool:
	return current_magazine == 0
	
func is_empty() -> bool:
	return current_ammunition == 0
