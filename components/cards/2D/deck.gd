class_name Deck extends Node

signal added_card(card: PlayingCard)
signal added_cards(card: Array[PlayingCard])
signal picked_card(card: PlayingCard)
signal discarded_card(card: PlayingCard)
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


var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCard] = []
var discard_pile: Array[PlayingCard] = []


#region Preparation 
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
func pick_cards(cards: Array[PlayingCard]) -> Array[PlayingCard]:
	for card in cards:
		pick_card(card)
		
	return cards
	
	
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
	
	add_to_discard_pile(card)


func add_jokers(amount: int) -> Deck:
	if amount > 0 and jokers.size() > 0:
		var new_jokers: Array[PlayingCard] = []
		new_jokers.assign(ArrayHelper.repeat(jokers.pick_random(), amount))
		
		add_cards(new_jokers)
		
	return self
	

#region Discard pile
func add_to_discard_pile(card: PlayingCard) -> void:
	if not discard_pile.has(card):
		discard_pile.append(card)
		discarded_card.emit(card)


func extract_from_discard_pile(card: PlayingCard) -> PlayingCard:
	if discard_pile.has(card):
		var selected_card: PlayingCard = discard_pile[discard_pile.find(card)]
	
		return selected_card
	
	return null

#endregion

#region Information
func size() -> int:
	return current_cards.size()
	

func is_spanish_deck() -> bool:
	return deck_type == DeckTypes.Spanish
	
	
func is_french_deck() -> bool:
	return deck_type == DeckTypes.French
	
#endregion
