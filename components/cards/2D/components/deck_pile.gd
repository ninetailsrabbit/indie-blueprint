@icon("res://components/cards/2D/icons/deck_pile.svg")
class_name DeckPile extends Control

const GroupName: StringName = &"deck-piles"

signal added_card(card: PlayingCardUI)
signal removed_card(card: PlayingCardUI)
signal removed_cards(cards: Array[PlayingCardUI])
signal add_card_request_denied(card: PlayingCardUI)
signal emptied(cards: Array[PlayingCardUI])
signal filled

@export var detection_area_size: Vector2 = Vector2(60, 96):
	set(value):
		if detection_area_size != value and is_inside_tree():
			detection_area_size = value
			change_detection_area_size(detection_area_size)
## Set to zero to allow an infinite amount of cards
@export var maximum_cards_in_pile: int = 0
@export var draw_visual_pile_each_n_cards: int = 1
@export var visual_pile_position_offset: Vector2 = Vector2(1, 1)
## When this is enabled, the rotation that have the card when entered the pile it's saved when dropped
@export var reset_card_rotation_when_dropped: bool = true
@export var min_rotation_on_card_dropped: float = -5.0
@export var max_rotation_on_card_dropped: float = 5.0
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
@onready var detection_card_area_collision: CollisionShape2D = $DetectionCardArea/CollisionShape2D


var current_cards: Array[PlayingCardUI] = []
var last_detected_card: PlayingCardUI


func _enter_tree() -> void:
	add_to_group(GroupName)
	

func _ready() -> void:
	min_rotation_on_card_dropped = deg_to_rad(min_rotation_on_card_dropped)
	max_rotation_on_card_dropped = deg_to_rad(max_rotation_on_card_dropped)
	
	detection_card_area.monitorable = false
	detection_card_area.monitoring = true
	detection_card_area.collision_layer = 0
	detection_card_area.collision_mask = GameGlobals.playing_cards_collision_layer
	detection_card_area.priority = 2
	change_detection_area_size(detection_area_size)
	
	detection_card_area.area_entered.connect(on_card_entered)
	detection_card_area.area_exited.connect(on_card_exited)


func change_detection_area_size(new_size: Vector2 = detection_area_size) -> void:
	detection_card_area_collision.shape.size = new_size


func add_card(card: PlayingCardUI) -> void:
	if _card_can_be_added_to_pile(card):
		card.lock()
		current_cards.append(card)
		card.reparent(self)
		@warning_ignore("integer_division")
		card.position = detection_card_area.position + visual_pile_position_offset * ceili(current_cards.size() / draw_visual_pile_each_n_cards)
		
		if reset_card_rotation_when_dropped:
			var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(card, "rotation", 0.0, 0.06)
		else:
			var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(card, "rotation", randf_range(min_rotation_on_card_dropped, max_rotation_on_card_dropped), 0.06)
		
		
		if not detection_area_size.is_equal_approx(card.front_sprite.size):
			change_detection_area_size(card.front_sprite.size)
		
		last_detected_card = null
		
		added_card.emit(card)
		
		if current_cards.size() == maximum_cards_in_pile:
			filled.emit()
	else:
		add_card_request_denied.emit(card)

	
func remove_cards(cards: Array[PlayingCardUI] = current_cards) -> void:
	for card: PlayingCardUI in cards:
		remove_card(card)

	removed_cards.emit(cards)


func remove_card(card: PlayingCardUI) -> void:
	if has_card(card):
		current_cards.erase(card)
		removed_card.emit(card)
		

func remove_card_at_position(idx: int) -> void:
	var card: PlayingCardUI = card_at_position(idx)
	
	if card != null:
		remove_card(card)
	

func clear() -> void:
	if is_empty():
		return
		
	emptied.emit(current_cards)
	remove_cards(current_cards)


func bottom_card() -> PlayingCardUI:
	if is_empty():
		return null
	 
	return current_cards.front()


func last_card() -> PlayingCardUI:
	if is_empty():
		return null
	 
	return current_cards.back()


func card_at_position(idx: int) -> PlayingCardUI:
	var index: int = current_cards.find(idx)
	
	if index != -1:
		return current_cards[index]
		
	return null


func has_card(card: PlayingCardUI) -> bool:
	return current_cards.has(card)


func is_empty() -> bool:
	return current_cards.is_empty()


func total_card_value() -> float:
	return current_cards.reduce(func(accum: float, playing_card: PlayingCardUI): return playing_card.card.value + accum, 0.0)


func total_card_table_value() -> float:
	return current_cards.reduce(func(accum: float, playing_card: PlayingCardUI): return playing_card.card.table_value + accum, 0.0)


func _card_can_be_added_to_pile(playing_card: PlayingCardUI) -> bool:
	var is_allowed_spanish_card: bool = playing_card.card.is_spanish() and playing_card.card.suit in allowed_spanish_suits
	var is_allowed_french_card: bool = playing_card.card.is_french() and playing_card.card.suit in allowed_french_suits
	
	return (maximum_cards_in_pile == 0 or (maximum_cards_in_pile > 0 and current_cards.size() < maximum_cards_in_pile)) \
		and (is_allowed_spanish_card or is_allowed_french_card)
	
	
#region Signal callbacks
func on_card_entered(other_area: Area2D) -> void:
	var card: PlayingCardUI = other_area.get_parent() as PlayingCardUI
	
	if card.is_being_dragged():
		last_detected_card = card
		last_detected_card.draggable_2d.released.connect(on_card_detected.bind(last_detected_card), CONNECT_ONE_SHOT)
		

func on_card_exited(_other_area: Area2D) -> void:
	if last_detected_card != null and last_detected_card.draggable_2d.released.is_connected(on_card_detected):
		last_detected_card.draggable_2d.released.disconnect(on_card_detected.bind(last_detected_card))
		
	last_detected_card = null
	

func on_card_detected(card: PlayingCardUI) -> void:
	var parent =  card.get_parent()
	
	if parent.has_method("remove_card"):
		parent.remove_card(card)
		
	add_card(card)
#endregion
