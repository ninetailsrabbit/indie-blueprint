@icon("res://components/motion/3D/first_person/weapons/icons/weapon_holder.svg")
## This class is responsible to prepare the selected weapons and equip & unequip
## using the hands provided as exported parameter
class_name FireArmWeaponManager extends Node


#signal dropped_weapon(weapon: FireArmWeaponMesh)
#signal changed_weapon(from: WeaponDatabase.WeaponRecord, to: WeaponDatabase.WeaponRecord)
signal stored_weapon(weapon: FireArmWeapon, hand: FirstPersonWeaponHand)
signal drawed_weapon(weapon: FireArmWeapon, hand: FirstPersonWeaponHand)

@export var actor: IndieBlueprintFirstPersonController
@export var primary_weapon_action: StringName = InputControls.PrimaryWeapon
@export var secondary_weapon_action: StringName = InputControls.SecondaryWeapon
@export var melee_action: StringName = InputControls.MeleeWeapon
@export var camera_controller: IndieBlueprintFirstPersonCameraController
## This is a node that holds a Camera3D and where the weapon recoil will be applied to simulate the kick on each shoot that affects accuracy. 
@export var camera_recoil_node: Node3D
## The node that represents a right hand to hold a weapon
@export var right_hand: FirstPersonWeaponHand 
## The node that represents a left hand to hold a weapon
@export var left_hand: FirstPersonWeaponHand 
## Enables support for left-handed users and the main weapon is equipped in the left_hand first when enabled
@export var inverted_hands: bool = false:
	set(value):
		if value != inverted_hands:
			inverted_hands = value
			
			if inverted_hands:
				right_hand.change_weapons_to_hand(left_hand)
			else:
				left_hand.change_weapons_to_hand(right_hand)

## TODO - THIS SELECTION COMES FROM A PREVIOUS UI SELECTION IN-GAME 
var current_equipment: Dictionary[String, Dictionary] = {
	#"primary_weapon": {"id": WeaponDatabase.IdentifierColtPythonRevolver, "weapon": null},
	#"secondary_weapon": {"id": WeaponDatabase.IdentifierAr181AssaultRiffle,  "weapon": null},
	"melee_weapon": {"id": &"",  "weapon": null}
}

## TODO - LETS DECIDE IN THE FUTURE IF THE PLAYER HAS A NO-WEAPON STATE
## TO APPLY MOVEMENT BUFFS OR NEEDS TO HAVE A WEAPON EQUIPPED ALL THE TIME
## THIS COULD CHANGE THIS WAY OF HANDLING THE INPUT
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(primary_weapon_action):
		if inverted_hands:
			toggle_left_hand_weapon("primary_weapon")
		else:
			toggle_right_hand_weapon("primary_weapon")
			
	if Input.is_action_just_pressed(secondary_weapon_action):
		if inverted_hands:
			toggle_left_hand_weapon("secondary_weapon")
		else:
			toggle_right_hand_weapon("secondary_weapon")

	if Input.is_action_just_pressed(melee_action):
		if inverted_hands:
			toggle_left_hand_weapon("melee_weapon")
		else:
			toggle_right_hand_weapon("melee_weapon")


func _ready() -> void:
	actor.get_node("MotionStateMachine").state_changed.connect(on_actor_state_changed)
	right_hand.drawed_weapon.connect(on_hand_drawed_weapon.bind(right_hand))
	right_hand.stored_weapon.connect(on_hand_stored_weapon.bind(right_hand))
	left_hand.drawed_weapon.connect(on_hand_drawed_weapon.bind(left_hand))
	left_hand.stored_weapon.connect(on_hand_stored_weapon.bind(left_hand))
	
	_prepare_weapons()
	

func toggle_right_hand_weapon(type: String) -> void:
	if right_hand.is_busy:
		return
	
		
	if right_hand.weapon_equipped and right_hand.weapon_equipped.id == current_equipment[type].id:
		right_hand.unequip()
	else:
		if current_equipment[type].weapon:
			if not right_hand.is_empty():
				await right_hand.unequip()
				
			right_hand.equip(current_equipment[type].weapon)
		

func toggle_left_hand_weapon(type: String) -> void:
	if left_hand.is_busy:
		return
		
	if left_hand.weapon_equipped and left_hand.weapon_equipped.id == current_equipment[type].id:
		left_hand.unequip()
	else:
		if current_equipment[type].weapon:
			if not right_hand.is_empty():
				await right_hand.unequip()
				
			left_hand.equip(current_equipment[type].weapon)
	

func _prepare_weapons() -> void:
	for key in current_equipment:
		var weapon_id: StringName = current_equipment[key].id
	
		if WeaponDatabase.exists(weapon_id):
			current_equipment[key].weapon =  WeaponDatabase.get_weapon(weapon_id)


#region Signal callbacks
func on_hand_drawed_weapon(weapon: FireArmWeapon, hand: FirstPersonWeaponHand) -> void:
	drawed_weapon.emit(weapon, hand)


func on_hand_stored_weapon(weapon: FireArmWeapon, hand: FirstPersonWeaponHand) -> void:
	stored_weapon.emit(weapon, hand)
	

func on_actor_state_changed(_from: IndieBlueprintMachineState, to: IndieBlueprintMachineState) -> void:
	match to.name:
		"FirstPersonRunState":
			var is_aiming: bool = actor.is_aiming()
			
			if right_hand.weapon_equipped:
				right_hand.weapon_equipped.lock_shoot = true
				right_hand.weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Holded
				
				if is_aiming:
					var tween: Tween = create_tween().set_parallel()
					tween.tween_property(actor.camera_controller.camera, "fov", actor.original_camera_fov, 0.2)
					tween.tween_property(right_hand.weapon_equipped, "position", right_hand.weapon_equipped.hand_position, 0.2)
		
			if left_hand.weapon_equipped:
				left_hand.weapon_equipped.lock_shoot = true
				left_hand.weapon_equipped.current_aim_state = FireArmWeapon.AimStates.Holded
				
				if is_aiming:
					var tween: Tween = create_tween().set_parallel()
					tween.tween_property(actor.camera_controller.camera, "fov", actor.original_camera_fov, 0.2)
					tween.tween_property(left_hand.weapon_equipped, "position", left_hand.weapon_equipped.hand_position, 0.2)
		_:
			if right_hand.weapon_equipped:
				right_hand.weapon_equipped.lock_shoot = false
				
			if left_hand.weapon_equipped:
				left_hand.weapon_equipped.lock_shoot = false
		
#endregion
