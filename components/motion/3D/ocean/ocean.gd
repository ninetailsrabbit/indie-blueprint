class_name Ocean extends MeshInstance3D

signal water_level_changed(new_water_level: float)

const GroupName: StringName = &"ocean"

## The water level with respect to the y-axis
@export var water_level: float = 0.0:
	set(value):
		if value != water_level:
			water_level = value
			water_level_changed.emit(water_level)
## When the boat beyond this distance from the center of the ocean, the ocean is repositioned to create the sensation of infinity.
@export var region_distance: float = 500.0
@export var region_distance_checker_interval_time: float = 5.0:
	set(value):
		if value != region_distance_checker_interval_time:
			region_distance_checker_interval_time = maxf(1.0, value)
			
			if is_inside_tree() and is_instance_valid(region_distance_timer):
				region_distance_timer.stop()
				region_distance_timer.wait_time = region_distance_checker_interval_time
				region_distance_timer.start()
		
@export var boat: Boat3D

@onready var underwater: MeshInstance3D = $Underwater

## If the player moves far away from the center of the mesh origin, 
## this mesh changes its global position to that of the player to maintain a sense of infinite ocean.
var boat_distance_from_ocean_center: float = 0.0
## A more performant way instead of calculating the distance each frame in the _process function
var region_distance_timer: Timer

func _enter_tree() -> void:
	add_to_group(GroupName)
	_create_region_distance_timer()


func _ready() -> void:
	if boat == null:
		boat = get_tree().get_first_node_in_group(Boat3D.GroupName)
		
	global_position.y = water_level


func _create_region_distance_timer():
	if region_distance_timer == null:
		region_distance_timer = TimeHelper.create_physics_timer(region_distance_checker_interval_time, true, false)
		region_distance_timer.name = "RegionDistanceTimer"
		
		add_child(region_distance_timer)
		region_distance_timer.timeout.connect(on_region_distance_timer_timeout)


func on_region_distance_timer_timeout() -> void:
	boat_distance_from_ocean_center = NodePositioner.local_distance_to_v3(boat.boat_3d, self)
	
	if boat_distance_from_ocean_center >= region_distance:
		boat_distance_from_ocean_center = 0.0
		global_position = Vector3(boat.boat_3d.global_position.x, water_level, boat.boat_3d.global_position.z)
