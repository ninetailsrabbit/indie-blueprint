class_name WeaponDatabase

#region Weapon IDs
## EXAMPLE
#const IdentifierPistol9MM: StringName = &"9mm"
#endregion


#region Weapons
## EXAMPLE
#const ColtPythonRevolverScene: PackedScene = preload("res://scenes/weapons/models/gameready_colt_python_revolver/colt_python_revolver.tscn")
#endregion


static var available_weapons: Dictionary[StringName, PackedScene] = {
	## EXAMPLE
	#IdentifierColtPythonRevolver: ColtPythonRevolverScene,
}


static func get_weapon(id: StringName) -> FireArmWeapon:
	assert(exists(id), "WeaponDatabase: The weapon with id %s does not exists, weapon cannot be retrieved from the database" % id)
	
	return available_weapons.get(id).instantiate() as FireArmWeapon


static func exists(id: StringName) -> bool:
	return available_weapons.has(id)
