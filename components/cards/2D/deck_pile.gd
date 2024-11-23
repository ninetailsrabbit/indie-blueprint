class_name DeckPile extends Node2D

signal added_card(card: PlayingCard)
signal removed_card(card: PlayingCard)
signal add_card_request_denied(card: PlayingCard)


@export var detection_area_size: Vector2 = Vector2(60, 96):
	set(value):
		if detection_area_size != value and is_inside_tree():
			detection_area_size = value
			change_detection_area_size(detection_area_size)
## Set to zero to allow an infinite amount of cards
@export var maximum_cards_in_pile: int = 0
@export var allowed_suits: Array[Deck.AllSuits] = [
	Deck.AllSuits.Cup,
	Deck.AllSuits.Gold,
	Deck.AllSuits.Club,
	Deck.AllSuits.Sword,
	Deck.AllSuits.Heart,
	Deck.AllSuits.Diamond,
	Deck.AllSuits.Spade,
]


@onready var detection_card_area: Area2D = $DetectionCardArea
@onready var collision_shape_2d: CollisionShape2D = $DetectionCardArea/CollisionShape2D
@onready var cards_zone: Node2D = $CardsZone


var current_cards: Array[PlayingCard] = []
var last_detected_card: PlayingCard


func _ready() -> void:
	detection_card_area.monitorable = false
	detection_card_area.monitoring = true
	detection_card_area.collision_layer = 0
	detection_card_area.collision_mask = GameGlobals.playing_cards_collision_layer
	detection_card_area.priority = 1
	change_detection_area_size(detection_area_size)
	
	detection_card_area.area_entered.connect(on_card_entered)
	detection_card_area.area_exited.connect(on_card_exited)


func change_detection_area_size(new_size: Vector2) -> void:
	collision_shape_2d.shape.size = new_size


func add_card(card: PlayingCard) -> void:
	if (maximum_cards_in_pile > 0 and current_cards.size() == maximum_cards_in_pile) or not card.suit in allowed_suits:
		add_card_request_denied.emit(card)
	else:
		current_cards.append(card)
		added_card.emit(card)
	
	
func remove_card(card: PlayingCard):
	if has_card(card):
		current_cards.erase(card)
		removed_card.emit(card)
		
	
func has_card(card: PlayingCard) -> bool:
	return current_cards.has(card)
	

#region Signal callbacks
func on_card_entered(other_area: Area2D) -> void:
	var card: PlayingCard = other_area.get_parent() as PlayingCard
	
	if card.is_holded:
		last_detected_card = card
		last_detected_card.released.connect(on_card_detected.bind(last_detected_card), CONNECT_ONE_SHOT)
		

func on_card_exited(_other_area: Area2D) -> void:
	if last_detected_card != null and last_detected_card.released.is_connected(on_card_detected):
		last_detected_card.released.disconnect(on_card_detected.bind(last_detected_card))
		
	last_detected_card = null
	

func on_card_detected(card: PlayingCard) -> void:
	add_card(card)
	card.reparent(cards_zone)
	card.global_position = global_position
	last_detected_card = null
#endregion
