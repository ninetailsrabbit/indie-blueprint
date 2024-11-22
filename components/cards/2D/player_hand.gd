class_name PlayerHand extends Node2D

signal added_card(card: PlayingCard)
signal removed_card(card: PlayingCard)
signal add_card_request_denied(card: PlayingCard)
signal sorted_cards(previous: Array[PlayingCard], current: Array[PlayingCard])

@export var maximum_cards: int = 4

var current_cards: Array[PlayingCard] = []


func add_card(card: PlayingCard) -> void:
	if current_cards.size() == maximum_cards:
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
	

func is_empty() -> bool:
	return current_cards.is_empty()


func sort_cards_by_value_asc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCard] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCard, b: PlayingCard): return a.value < b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)
		
		
func sort_cards_by_value_desc() -> void:
	if current_cards.size() > 1:
		var previous_sortered_cards: Array[PlayingCard] = current_cards.duplicate()
		
		current_cards.sort_custom(func(a: PlayingCard, b: PlayingCard): return a.value > b.value)
		sorted_cards.emit(previous_sortered_cards, current_cards)
