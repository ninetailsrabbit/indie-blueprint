class_name Deck extends Node2D

signal added_card(card: PlayingCard)
signal added_cards(card: Array[PlayingCard])
signal picked_card(card: PlayingCard)
signal removed_card(card: PlayingCard)
signal added_to_discard_pile(card: PlayingCard)
signal recovered_card_from_discard_pile(card: PlayingCard)
signal emptied_deck
signal filled
signal shuffled

enum DeckTypes {
	French,
	Spanish
}

enum CommonSuits {
	Joker = 5,
	Back = 6
}

enum AllSuits {
	Cup = 7,
	Gold = 8,
	Sword = 9,
	Club = 10,
	Heart = 11,
	Diamond = 12,
	Spade = 13,
}

enum SpanishSuits {
	Cup,
	Gold,
	Sword,
	Club
}

enum FrenchSuits {
	Heart,
	Diamond,
	Spade,
	Club
}

var deck_type: DeckTypes
#region Card templates
var cards_by_suit: Dictionary = {}
var cards: Array[PlayingCard] = []
var jokers: Array[PlayingCard] = []
#endregion
var backs: Array[CompressedTexture2D] = []


var current_back_texture: CompressedTexture2D
var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCard] = []
var discard_pile: Array[PlayingCard] = []

var jokers_count_for_empty_deck: bool = false

var visual_pile_node: Node2D
var start_visual_pile_with_amount: int
var visual_pile_counter: int

#region Preparation 
func _enter_tree() -> void:
	removed_card.connect(on_removed_card)


func _ready() -> void:
	if current_back_texture == null:
		current_back_texture = backs.pick_random()
	

func draw_visual_pile(amount: int = 5, distance: float = 1.5) -> void:
	start_visual_pile_with_amount = amount
	
	visual_pile_counter = ceili(cards.size() / start_visual_pile_with_amount)
	
	if visual_pile_node == null:
		visual_pile_node = Node2D.new()
		add_child(visual_pile_node)
		
	for i in amount:
		var sprite = Sprite2D.new()
		sprite.texture = current_back_texture
		sprite.position = Vector2(i * distance, -i * distance)
		visual_pile_node.add_child(sprite)
		
		if i == 0:
			sprite.position.y += 1
			sprite.show_behind_parent = true
			sprite.self_modulate = Color("1616166f")
	

func fill() -> Deck:
	current_cards = cards.duplicate()
	current_cards_by_suit = cards_by_suit.duplicate(true)
	## The jokers can be only added by the function 'add_jokers'
	current_cards_by_suit[Deck.CommonSuits.Joker].clear()
	
	filled.emit()
	
	return self


func shuffle() -> Deck:
	current_cards.shuffle()
	shuffled.emit()
	
	return self
#endregion
	
#region Random pickers
func pick_random_card() -> PlayingCard:
	if current_cards.is_empty():
		return null
	
	return pick_card(current_cards.pick_random())
	

func pick_random_cards(amount: int) -> Array[PlayingCard]:
	if current_cards.is_empty():
		return []
	
	var selected_cards: Array[PlayingCard] = []
	amount = clamp(amount, 1, current_cards.size())
	
	for i in amount:
		selected_cards.append(pick_card(current_cards.pick_random()))
	
	return selected_cards


func pick_random_number_card() -> PlayingCard:
	return pick_card(number_cards().pick_random())


## The function parameter "suit" is not typed as the suits are separated into different enums
func pick_random_card_from_suit(suit) -> PlayingCard:
	if current_cards_by_suit.has(suit) and current_cards_by_suit[suit].size() > 0:
		return pick_card(current_cards_by_suit[suit].pick_random())
	
	return null


func pick_random_card_of_value(value: int) -> PlayingCard:
	var selected_cards: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.value == value)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_card_of_suit_and_value(suit, value: int) -> PlayingCard:
	var selected_cards: Array[PlayingCard] = cards_from_suit(suit).filter(func(card: PlayingCard): return card.value == value)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_ace() -> PlayingCard:
	var aces: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_ace())
	
	if aces.is_empty():
		return null
		
	return pick_card(aces.pick_random())


func pick_random_jack() -> PlayingCard:
	var jacks: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_jack())
	
	if jacks.is_empty():
		return null
		
	return pick_card(jacks.pick_random())


func pick_random_queen() -> PlayingCard:
	var queens: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_queen())
	
	if queens.is_empty():
		return null
		
	return pick_card(queens.pick_random())


func pick_random_knight() -> PlayingCard:
	var knights: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_knight())
	
	if knights.is_empty():
		return null
		
	return pick_card(knights.pick_random())


func pick_random_king() -> PlayingCard:
	var kings: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_king())
	
	if kings.is_empty():
		return null
		
	return pick_card(kings.pick_random())


func pick_random_joker() -> PlayingCard:
	var selected_jokers: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_joker())
	
	if selected_jokers.is_empty():
		return null
		
	return pick_card(selected_jokers.pick_random())

#endregion

#region Pickers
func pick_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	for card in selected_cards:
		pick_card(card)
		
	return selected_cards
	
	
func pick_card(card: PlayingCard) -> PlayingCard:
	remove_card(card)
	picked_card.emit(card)
	
	return card


func number_cards() -> Array[PlayingCard]:
	return extract_number_cards(current_cards)
	

func number_cards_from_suit(suit) -> Array[PlayingCard]:
	return extract_number_cards(cards_from_suit(suit))


func figure_cards() -> Array[PlayingCard]:
	return extract_figure_cards(current_cards)
	

func figure_cards_from_suit(suit) -> Array[PlayingCard]:
	return extract_figure_cards(cards_from_suit(suit))


func extract_number_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	match deck_type:
		DeckTypes.Spanish:
			return selected_cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 8)
		DeckTypes.French:
			return selected_cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 11)
	 
	return []


func extract_figure_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	match deck_type:
		DeckTypes.Spanish:
			return selected_cards.filter(func(card: PlayingCard): return card.is_jack() or card.is_knight() or card.is_king())
		DeckTypes.French:
			return selected_cards.filter(func(card: PlayingCard): return card.is_jack() or card.is_queen() or card.is_king())
	 
	return []


func cards_from_suit(suit) -> Array[PlayingCard]:
	if current_cards_by_suit.has(suit):
		return current_cards_by_suit[suit]
	
	return []

#endregion

func add_cards(new_cards: Array[PlayingCard], allow_duplicates: bool = false) -> void:
	for card: PlayingCard in new_cards:
		add_card(card, allow_duplicates)
	
	added_cards.emit(new_cards)


func add_card(card: PlayingCard, allow_duplicates: bool = false) -> void:
	if allow_duplicates:
		current_cards.append(card)
		current_cards_by_suit[card.suit].append(card)
	else:
		if not current_cards.has(card):
			current_cards.append(card)
			
		if not current_cards_by_suit[card.suit].has(card):
			current_cards_by_suit[card.suit].append(card)
	
	added_card.emit(card)
	
	
func remove_card(card: PlayingCard):
	current_cards.erase(card)
	
	if current_cards_by_suit.has(card.suit):
		current_cards_by_suit[card.suit].erase(card)
		removed_card.emit(card)
	
	if is_empty():
		emptied_deck.emit()
	
	add_to_discard_pile(card)
	

func add_jokers(amount: int, selected_card: PlayingCard = null) -> Deck:
	if amount > 0 and jokers.size() > 0:
		var new_jokers: Array[PlayingCard] = []
		var joker: PlayingCard = selected_card if selected_card != null and selected_card.is_joker() else jokers.pick_random()
		
		new_jokers.assign(ArrayHelper.repeat(joker, amount))
		
		add_cards(new_jokers)
		
	return self
	

#region Discard pile
func add_to_discard_pile(card: PlayingCard) -> void:
	if not discard_pile.has(card):
		discard_pile.append(card)
		added_to_discard_pile.emit(card)


func extract_from_discard_pile(card: PlayingCard) -> PlayingCard:
	if discard_pile.has(card):
		var selected_card: PlayingCard = discard_pile[discard_pile.find(card)]
		discard_pile.erase(card)
		
		return selected_card
	
	return null


func recover_from_discard_pile(card: PlayingCard) -> PlayingCard:
	var card_to_recover: PlayingCard = extract_from_discard_pile(card)
	
	if card_to_recover != null:
		add_card(card_to_recover)
		recovered_card_from_discard_pile.emit(card)
	return null
#endregion

#region Information
func has_aces() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_ace())
	
	
func has_jokers() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_joker())
	

func has_only_jokers() -> bool:
	return current_cards.all(func(card: PlayingCard): return card.is_joker())
	
	
func has_jacks() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_jack())
	
	
func has_queens() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_queen())
	

func has_knights() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_knight())
	

func has_kings() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_king())
	
	
func has_number_cards() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_number())
	

func is_empty() -> bool:
	return (has_only_jokers() and not jokers_count_for_empty_deck) or current_cards.is_empty()


func size() -> int:
	return current_cards.size()
	

func is_spanish_deck() -> bool:
	return deck_type == DeckTypes.Spanish
	
	
func is_french_deck() -> bool:
	return deck_type == DeckTypes.French
#endregion


#region Signal callbacks
func on_removed_card(_card: PlayingCard) -> void:
	visual_pile_counter -= 1
	
	if visual_pile_counter == 0 and visual_pile_node.get_child_count() > 0:
		NodeTraversal.get_last_child(visual_pile_node).queue_free()
		visual_pile_counter = ceili(cards.size() / start_visual_pile_with_amount)

#endregion
