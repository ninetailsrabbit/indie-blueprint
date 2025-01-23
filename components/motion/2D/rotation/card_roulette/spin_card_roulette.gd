class_name SpinCardRoulette extends Node2D

signal card_detected(spin_card: SpinCard)

## The orbit radius for the cards in pixels
@export var auto_start: bool = true
@export var orbit_radius: float = 30.0
@export var angular_velocity: float = 0.5
@export var maximum_cards: int = 4

@onready var orbit_point: Marker2D = $OrbitPoint
@onready var spin_card_detector: Area2D = $OrbitPoint/SpinCardDetector
@onready var spin_card_detector_collision: CollisionShape2D = $OrbitPoint/SpinCardDetector/CollisionShape2D

var current_spin_cards: Array[SpinCard] = []


func _ready() -> void:
	_prepare_spin_card_detector()
	_prepare_spin_cards()
	
	if auto_start:
		start()


func start() -> void:
	for spin_card: SpinCard in current_spin_cards:
		spin_card.orbit_component.active = true
	

func stop() -> void:
	for spin_card: SpinCard in current_spin_cards:
		spin_card.orbit_component.active = false


func _prepare_spin_card_detector() -> void:
	spin_card_detector.monitoring = true
	spin_card_detector.monitorable = false
	spin_card_detector.collision_layer = 0
	spin_card_detector.collision_mask = GameGlobals.playing_cards_collision_layer
	spin_card_detector.priority = 2
	spin_card_detector.position.y -= orbit_radius + spin_card_detector_collision.shape.size.y
	
	spin_card_detector.area_entered.connect(on_spin_card_detected)
	

## 1. Get the current roulette cards
## 2. Calculate the individual angle for each card in the orbit based on the total cards size
## 3. Apply the values on the spin card OrbitComponent2D
func _prepare_spin_cards() -> void:
	current_spin_cards.assign(NodeTraversal.find_nodes_of_custom_class(self, SpinCard))

	var angle: float = rad_to_deg(TAU) / clampi(current_spin_cards.size(), 1, maximum_cards)
	
	for index: int in current_spin_cards.size():
		var spin_card: SpinCard = current_spin_cards[index]
		
		if index >= maximum_cards:
			current_spin_cards.erase(spin_card)
			spin_card.queue_free()
		else:
			spin_card.orbit_component.initial_angle = index * angle
			spin_card.orbit_component.active = auto_start
			spin_card.orbit_component.radius = orbit_radius
			spin_card.orbit_component.angular_velocity = angular_velocity


func on_spin_card_detected(other_area: Area2D) -> void:
	var card: SpinCard = other_area.get_parent()
	
	if card == null or card.disabled:
		return
	
	card.current_ticks += 1
	card_detected.emit(card)
