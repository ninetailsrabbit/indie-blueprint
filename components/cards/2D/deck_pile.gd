@icon("res://components/cards/2D/icons/deck_pile.svg")
class_name DeckPile extends Control

const GroupName: StringName = &"deck-piles"

signal added_card(card: PlayingCard)
signal removed_card(card: PlayingCard)
signal removed_cards(cards: Array[PlayingCard])
signal add_card_request_denied(card: PlayingCard)
signal emptied(cards: Array[PlayingCard])
signal filled

@export var detection_area_size: Vector2 = Vector2(60, 96):
	set(value):
		if detection_area_size != value and is_inside_tree():
			detection_area_size = value
			change_detection_area_size(detection_area_size)
## Set to zero to allow an infinite amount of cards
@export var maximum_cards_in_pile: int = 0
@export var allowed_spanish_suits: Array[PlayingCard.Suits] = [
	PlayingCard.Suits.Cup,
	PlayingCard.Suits.Gold,
	PlayingCard.Suits.Club,
	PlayingCard.Suits.Sword,
]
@export var allowed_french_suits: Array[PlayingCard.Suits] = [
	PlayingCard.Suits.Diamond,
	PlayingCard.Suits.Heart,
	PlayingCard.Suits.Club,
	PlayingCard.Suits.Spade,
]


@onready var detection_card_area: Area2D = $DetectionCardArea
@onready var collision_shape_2d: CollisionShape2D = $DetectionCardArea/CollisionShape2D


var current_cards: Array[PlayingCard] = []
var last_detected_card: PlayingCard


func _enter_tree() -> void:
	add_to_group(GroupName)
	

func _ready() -> void:
	detection_card_area.monitorable = false
	detection_card_area.monitoring = true
	detection_card_area.collision_layer = 0
	detection_card_area.collision_mask = GameGlobals.playing_cards_collision_layer
	detection_card_area.priority = 2
	change_detection_area_size(detection_area_size)
	
	detection_card_area.area_entered.connect(on_card_entered)
	detection_card_area.area_exited.connect(on_card_exited)


func change_detection_area_size(new_size: Vector2 = detection_area_size) -> void:
	detection_card_area.position = new_size / 2.0
	collision_shape_2d.shape.size = new_size


func add_card(card: PlayingCard) -> void:
	if _card_can_be_added_to_pile(card):
		card.lock()
		current_cards.append(card)
		card.reparent(self)
		card.disable_detection_areas()
		card.position = detection_card_area.position
		card.hide()
		
		if not detection_area_size.is_equal_approx(card.front_sprite.size):
			change_detection_area_size(card.front_sprite.size)
		
		last_detected_card = null
		
		added_card.emit(card)
		
		if current_cards.size() == maximum_cards_in_pile:
			filled.emit()
	else:
		add_card_request_denied.emit(card)


func clear() -> void:
	if not is_empty():
		emptied.emit(current_cards)
		remove_cards(current_cards)
		
	
func remove_cards(cards: Array[PlayingCard] = current_cards):
	for card: PlayingCard in cards:
		remove_card(card)

	removed_cards.emit(cards)


func remove_card(card: PlayingCard):
	if has_card(card):
		current_cards.erase(card)
		removed_card.emit(card)


func has_card(card: PlayingCard) -> bool:
	return current_cards.has(card)


func is_empty() -> bool:
	return current_cards.is_empty()


func total_card_value() -> float:
	return current_cards.reduce(func(accum: float, card: PlayingCard): return card.value + accum, 0.0)


func total_card_table_value() -> float:
	return current_cards.reduce(func(accum: float, card: PlayingCard): return card.table_value + accum, 0.0)


func _card_can_be_added_to_pile(card: PlayingCard) -> bool:
	if card.bypass_deck_pile_conditions:
		return true
		
	var is_allowed_spanish_card: bool = card.is_spanish() and card.suit in allowed_spanish_suits
	var is_allowed_french_card: bool = card.is_french() and card.suit in allowed_french_suits
	
	return (maximum_cards_in_pile == 0 or (maximum_cards_in_pile > 0 and current_cards.size() < maximum_cards_in_pile)) \
		and (is_allowed_spanish_card or is_allowed_french_card)
	
	
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
	var parent =  card.get_parent()
	
	if parent.has_method("remove_card"):
		parent.remove_card(card)
		
	add_card(card)
#endregion
