@icon("res://components/cards/2D/icons/player_hand.svg")
class_name PlayerHandSprite extends Node2D

signal added_card(card: PlayingCardSprite)
signal added_cards(cards: Array[PlayingCardSprite])
signal removed_card(card: PlayingCardSprite)
signal add_card_request_denied(card: PlayingCardSprite)
signal add_cards_request_denied(card: Array[PlayingCardSprite])
signal sorted_cards(previous: Array[PlayingCardSprite], current: Array[PlayingCardSprite])


@export var id: StringName
@export var maximum_cards: int = 4:
	set(value):
		maximum_cards = maxi(1, value)
@export var distance_between_cards: float = 2.0
@export var time_to_adjust: float = 0.06
@export var display_layout_mode: Layouts = Layouts.Horizontal


enum Layouts {
	Horizontal,
	Fan
}


var current_cards: Array[PlayingCardSprite] = []


func _enter_tree() -> void:
	added_card.connect(on_added_card)
	removed_card.connect(on_removed_card)


func adjust_hand_position(except: Array[PlayingCardSprite] = []) -> void:
	var target_cards: Array[PlayingCardSprite] = current_cards.filter(
		func(card: PlayingCardSprite): 
			return not card in except and not card.is_being_dragged()
			)
	
	if display_layout_mode == Layouts.Horizontal:
		for card: PlayingCardSprite in target_cards:
			var index: int = target_cards.find(card)
			var new_position: Vector2 = Vector2(index * ((card.front_sprite.texture.get_size() * card.scale).x + distance_between_cards), 0)
			
			if card.drag_drop_region.tween_position_is_running():
				card.position = new_position
				card.drag_drop_region.original_position = card.global_position
			else:
				var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(card, "position", new_position, time_to_adjust)
				tween.finished.connect(func(): 
					card.drag_drop_region.original_position = card.global_position, 
					CONNECT_ONE_SHOT
				)
			
		

func add_card(card: PlayingCardSprite) -> void:
	if current_cards.size() == maximum_cards or current_cards.has(card):
		add_card_request_denied.emit(card)
	else:
		if not card.is_inside_tree():
			add_child(card)
		
		card.drag_drop_region.dragged.connect(on_card_dragged.bind(card))
		card.drag_drop_region.released.connect(on_card_released.bind(card))
		
		current_cards.append(card)
		added_card.emit(card)
		adjust_hand_position()
	

func add_cards(cards: Array[PlayingCardSprite] = []) -> void:
	if current_cards.size() == maximum_cards:
		add_cards_request_denied.emit(cards)
	else:
		var selected_cards = filter_cards_by_maximum_hand_size(cards)
		
		for card: PlayingCardSprite in selected_cards:
			add_card(card)
		
		added_cards.emit(selected_cards)


func remove_card(card: PlayingCardSprite):
	if has_card(card):
		if card.drag_drop_region.dragged.is_connected(on_card_dragged.bind(card)):
			card.drag_drop_region.dragged.disconnect(on_card_dragged.bind(card))
			
		if card.drag_drop_region.released.is_connected(on_card_released.bind(card)):
			card.drag_drop_region.released.disconnect(on_card_released.bind(card))
		
		current_cards.erase(card)
		removed_card.emit(card)
		adjust_hand_position([card])
		
	
func has_card(card: PlayingCardSprite) -> bool:
	return current_cards.has(card)
	

func is_empty() -> bool:
	return current_cards.is_empty()


func sort_cards_by_value_asc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCardSprite] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCardSprite, b: PlayingCardSprite): return a.value < b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)
		
		
func sort_cards_by_value_desc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCardSprite] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCardSprite, b: PlayingCardSprite): return a.value > b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)


func filter_cards_by_maximum_hand_size(cards: Array[PlayingCardSprite]) -> Array[PlayingCardSprite]:
	return cards.slice(0, maximum_cards - current_cards.size())


func lock_cards() -> void:
	for card: PlayingCardSprite in current_cards:
		card.lock()


func unlock_cards() -> void:
	for card: PlayingCardSprite in current_cards:
		card.unlock()


#region Signal callbacks
func on_card_dragged(card: PlayingCardSprite):
	if has_card(card):
		adjust_hand_position()
	

func on_card_released(card: PlayingCardSprite):
	await GameGlobals.wait(0.1)
	
	if has_card(card) and card.get_parent() is PlayerHandSprite:
		adjust_hand_position()
		
		
func on_added_card(_card: PlayingCardSprite) -> void:
	adjust_hand_position()
	

func on_removed_card(card: PlayingCardSprite) -> void:
	adjust_hand_position([card])
#endregion
