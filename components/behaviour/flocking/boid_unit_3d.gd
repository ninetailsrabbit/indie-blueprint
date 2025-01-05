@icon("res://components/behaviour/flocking/boid_unit.svg")
class_name BoidUnit3D extends Node3D

@export var target_unit: Node3D
@export var neighbour_detection_area: Area3D
@export var alignment_weight: float = 0.5
@export var cohesion_weight: float = 0.2
@export var separation_weight: float = 0.2
@export var neighbour_radius: float = 3.0
@export var min_speed: float = 1.0
@export var max_speed: float = 1.0
@export var max_acceleration: float = 0.2
@export var rotation_speed: float = 2.0
@export var velocity_modifier: Vector3 = Vector3(1, 0, 1)


var boid: Boid3D
var alignment: Vector3 = Vector3.ZERO
var cohesion: Vector3 = Vector3.ZERO
var separation: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO

var count: int = 0
var neighbour_units: Array[BoidUnit3D] = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	if target_unit == null:
		target_unit = get_parent()
	
	rng.randomize()
	_prepare_neighbour_detection_area()
	

func _physics_process(delta: float) -> void:
	if target_unit and boid:
		alignment = Vector3.ZERO
		cohesion = Vector3.ZERO
		separation = Vector3.ZERO
		count = 0
		
		for unit: Variant in neighbour_units:
			var distance: float = NodePositioner.global_distance_to_v3(target_unit, unit)
			
			if unit != target_unit and distance < neighbour_radius:
				alignment += unit.velocity
				cohesion += unit.global_position
				separation += (global_position - unit.global_position) / distance
				count += 1
				
		if count > 0:
			calculate_alignment()
			calculate_cohesion()
			calculate_separation()
			
	velocity += alignment * alignment_weight + cohesion * cohesion_weight + separation * separation_weight
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * rng.randf_range(min_speed, max_speed)
	elif is_zero_approx(velocity.length()):
		velocity = Vector3(rng.randf(), rng.randf(), rng.randf()).normalized() * max_speed

	var direction: Vector3 = velocity.normalized()
	var current_rotation: Vector3 = target_unit.rotation
	
	if not direction.is_zero_approx():
		var target_basis = Basis.looking_at(-direction, Vector3.UP)
		var current_basis: Basis = target_unit.transform.basis
		var t: float = rotation_speed * delta
		var new_basis: Basis = current_basis.orthonormalized().slerp(target_basis, t)
		target_unit.transform.basis = new_basis
	
	velocity *= velocity_modifier
	
	if target_unit is CharacterBody3D:
		target_unit.velocity = velocity
		target_unit.move_and_slide()
	else:
		target_unit.global_position += velocity * delta


func calculate_alignment() -> void:
	alignment /= count
	alignment = alignment.normalized() * max_speed - velocity
	
	if alignment.length() > max_acceleration:
		alignment = alignment.normalized() * max_acceleration


func calculate_cohesion() -> void:
	cohesion = (cohesion / count) - target_unit.global_position
	cohesion = cohesion.normalized() * max_speed - velocity
	
	if cohesion.length() > max_acceleration:
		cohesion = cohesion.normalized() * max_acceleration
	
	
func calculate_separation() -> void:
	separation /= count
	separation = separation.normalized() * max_speed - velocity
	
	if separation.length() > max_acceleration:
		separation = separation.normalized() * max_acceleration


func _prepare_neighbour_detection_area() -> void:
	if neighbour_detection_area == null:
		neighbour_detection_area = NodeTraversal.first_node_of_type(self, Area3D.new())
	
	var collision_shape = NodeTraversal.first_node_of_type(neighbour_detection_area, CollisionShape3D.new())
	
	if collision_shape == null:
		collision_shape = CollisionShape3D.new()
		neighbour_detection_area.add_child(collision_shape)
	
	if collision_shape.shape == null or not collision_shape.shape is SphereShape3D:
		collision_shape.shape = SphereShape3D.new()
		
	collision_shape.shape.radius = neighbour_radius
	
	neighbour_detection_area.area_entered.connect(on_neighbour_area_entered)
	neighbour_detection_area.area_exited.connect(on_neighbour_area_exited)
	
	
func on_neighbour_area_entered(neighbour_area: Area3D) -> void:
	var boid_unit := neighbour_area.get_parent()
	
	if boid_unit != null and boid_unit is BoidUnit3D:
		if not neighbour_units.has(boid_unit):
			neighbour_units.append(boid_unit)


func on_neighbour_area_exited(neighbour_area: Area3D) -> void:
	var boid_unit := neighbour_area.get_parent()
	
	if boid_unit != null and boid_unit is BoidUnit3D:
		neighbour_units.erase(boid_unit)
