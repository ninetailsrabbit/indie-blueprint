class_name FireArmWeaponFire extends Resource

enum BurstTypes {
	Single, # One round per trigger pull.
	Automatic, # Continuous fire as long as the trigger is held down.
	SemiAutomatic, # One round per trigger pull, but the trigger must be released and pulled again for each shot.
	BurstFire, # A fixed number of rounds fired in a single trigger pull.
	ThreeRoundBurst, # A specific type of burst-fire that fires three rounds per trigger pull.
	FiveRoundBurst, # A specific type of burst-fire that fires five rounds per trigger pull.
}

## The additional fire damage that will be added to the bullet
@export var shoot_damage: int = 5 
## When enabled, the weapon it's reloaded automatically when the magazine gets empty
@export var auto_reload_on_empty_magazine: bool = true
## The reload time defined, if the weapon has an animation, the animation time will be used instead.
@export var reload_time: float = 3.0
## The range in meters in the world this weapon can shoot and reach the target immediately
@export var fire_range: float = 250
## The time between shoots, greater values means plus intermediate pause between shots
@export var fire_rate: float = 0.2
## Not used at this moment but this value it's the time that it takes to a shoot be ready
@export var fire_impulse: float = 0.2
## The burst type mode of this weapon
@export var burst_type: BurstTypes = BurstTypes.Single
## Only applies on BurstTypes.BurstFire selected type, the number of shoots for the custom burst fire
@export var number_of_shoots: int = 1
## How many bullets this weapon per shoot
@export var bullets_per_shoot: int = 1
## The bullet spread degrees the bullet is deflected, it is used in conjunction with the accuracy value of this weapon to determine whether or not the deflection is applied.
@export_range(0, 180.0, 0.01, "degrees") var bullet_spread_degrees: float = 10.0
## The distance this bullet moves from the origin of the shoot, use in combination with the bullet_spread_degrees
@export var bullet_distance_from_origin: float = 0.35
