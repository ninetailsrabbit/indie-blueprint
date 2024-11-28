class_name PlayerHand extends Control

signal added_card(card: PlayingCard)
signal added_cards(cards: Array[PlayingCard])
signal removed_card(card: PlayingCard)
signal add_card_request_denied(card: PlayingCard)
signal add_cards_request_denied(card: Array[PlayingCard])
signal sorted_cards(previous: Array[PlayingCard], current: Array[PlayingCard])


@export var id: StringName
@export var maximum_cards: int = 4:
	set(value):
		maximum_cards = maxi(1, value)
@export var distance_between_cards: float = 3.5
@export var fanning: bool = true


var current_cards: Array[PlayingCard] = []


func _enter_tree() -> void:
	name  = "PlayerHand"
	mouse_filter = MOUSE_FILTER_PASS


func draw_from_deck(deck: Deck, amount: int):
	if deck.is_empty():
		return
		
	var selected_cards = deck.pick_random_cards(amount)
	
	await draw_animation_from_deck(deck, selected_cards)
	
	unlock_cards()


func draw_animation_from_deck(deck: Deck, cards: Array[PlayingCard], duration: float = 0.3) -> void:
	for card: PlayingCard in filter_cards_by_maximum_hand_size(cards):
		add_card(card)
		card.lock()
		card.global_position = deck.global_position
		
		var tween: Tween = create_tween()
		tween.tween_property(card, "global_position", global_position, duration).from(deck.global_position)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		await tween.finished
		
		adjust_hand_position()


func adjust_hand_position(except: Array[PlayingCard] = []) -> void:
	var target_cards: Array[PlayingCard] = current_cards.filter(func(card): return not card in except)
	
	for card: PlayingCard in target_cards:
		var index: int = target_cards.find(card)
		var offset = (target_cards.size() / 2.0 - index) * (card.size.x + distance_between_cards)
		var target_position = position.x - offset
		
		
		var tween = create_tween()
		tween.tween_property(card, "position:x", target_position, 0.06)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		await tween.finished
		card.original_position = card.global_position


func add_card(card: PlayingCard) -> void:
	if current_cards.size() == maximum_cards:
		add_card_request_denied.emit(card)
	else:
		if not card.is_inside_tree():
			add_child(card)
		
		card.holded.connect(on_card_holded.bind(card))
		card.released.connect(on_card_released.bind(card))
		
		current_cards.append(card)
		added_card.emit(card)
	

func add_cards(cards: Array[PlayingCard] = []) -> void:
	if current_cards.size() == maximum_cards:
		add_cards_request_denied.emit(cards)
	else:
		var selected_cards = filter_cards_by_maximum_hand_size(cards)
		
		for card: PlayingCard in selected_cards:
			add_card(card)
		
		added_cards.emit(selected_cards)


func remove_card(card: PlayingCard):
	if has_card(card):
		if card.holded.is_connected(on_card_holded.bind(card)):
			card.holded.disconnect(on_card_holded.bind(card))
			
		if card.released.is_connected(on_card_released.bind(card)):
			card.released.disconnect(on_card_released.bind(card))
		
		current_cards.erase(card)
		removed_card.emit(card)
		adjust_hand_position([card])
		
	
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


func filter_cards_by_maximum_hand_size(cards: Array[PlayingCard]) -> Array[PlayingCard]:
	return cards.slice(0, maximum_cards - current_cards.size())


func lock_cards() -> void:
	for card: PlayingCard in current_cards:
		card.lock()


func unlock_cards() -> void:
	for card: PlayingCard in current_cards:
		card.unlock()


#region Signal callbacks
func on_card_holded(card: PlayingCard):
	adjust_hand_position([card])
	

func on_card_released(card: PlayingCard):
	await GameGlobals.wait(0.1)
	
	if has_card(card) and card.get_parent() is PlayerHand:
		adjust_hand_position()
#endregion
