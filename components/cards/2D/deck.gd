class_name Deck extends Node

signal picked_card(card: PlayingCard)
signal discarded_card(card: PlayingCard)
signal emptied_deck
signal filled
signal shuffled

var deck_type: DeckManager.DeckTypes
#region Card templates
var cards_by_suit: Dictionary = {}
var cards: Array[PlayingCard] = []
var jokers: Array[PlayingCard] = []
#endregion
var backs: Array[CompressedTexture2D] = []


var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCard] = []
var discard_pile: Array[PlayingCard] = []



func fill(amount_of_jokers: int = 0) -> Deck:
	current_cards = cards.duplicate()
	current_cards_by_suit = cards_by_suit.duplicate(true)
	
	if amount_of_jokers > 0 and jokers.size() > 0:
		var selected_joker: PlayingCard = jokers.pick_random()
		current_cards.append_array(ArrayHelper.repeat(selected_joker, amount_of_jokers))
	
	filled.emit()
	
	return self


func shuffle() -> Deck:
	current_cards.shuffle()
	shuffled.emit()
	
	return self
	
	
func pick_card(card: PlayingCard) -> PlayingCard:
	remove_card(card)
	
	picked_card.emit()
	
	return card

#region Random picks
func pick_random_number_card() -> PlayingCard:
	return pick_card(number_cards().pick_random())


func pick_random_card() -> PlayingCard:
	if current_cards.is_empty():
		return null
	
		
	return pick_card(current_cards.pick_random())
	

## The function parameter is not typed as the suits are separated into different enums
func pick_random_card_from_suit(suit) -> PlayingCard:
	if current_cards_by_suit.has(suit) and current_cards_by_suit[suit].size() > 0:
		return pick_card(current_cards_by_suit[suit].pick_random())
	
	return null


func pick_random_ace() -> PlayingCard:
	var aces: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_ace())
	
	if aces.is_empty():
		return null
		
	return pick_card(aces.pick_random())
#endregion


func number_cards() -> Array[PlayingCard]:
	return extract_number_cards(current_cards)
	

func number_cards_from_suit(suit) -> Array[PlayingCard]:
	return extract_number_cards(cards_from_suit(suit))


func extract_number_cards(cards: Array[PlayingCard]) -> Array[PlayingCard]:
	match deck_type:
		DeckManager.DeckTypes.Spanish:
			return cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 8)
		DeckManager.DeckTypes.French:
			return cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 11)
	 
	return []


func cards_from_suit(suit) -> Array[PlayingCard]:
	if current_cards_by_suit.has(suit):
		return current_cards_by_suit[suit]
	
	return []


func remove_card(card: PlayingCard):
	current_cards.erase(card)
	current_cards_by_suit.erase(current_cards_by_suit.find_key(card))
	
	add_to_discard_pile(card)
	

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
