@icon("res://components/motion/3D/first_person/weapons/icons/weapon_motion.svg")
class_name WeaponMotion extends Node3D


func enable() -> void:
	set_physics_process(true)
	
	
func disable() -> void:
	set_physics_process(false)


func is_enabled() -> bool:
	return is_physics_processing()


func is_disabled() -> bool:
	return not is_physics_processing()
