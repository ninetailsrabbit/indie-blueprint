class_name Deck extends Node


var cards: Array[PlayingCard] = []
var jokers: Array[PlayingCard] = []
var discard_pile: Array[PlayingCard] = []

var backs: Array[CompressedTexture2D] = []



func shuffle() -> void:
	cards.shuffle()


func pick_random_card() -> PlayingCard:
	if cards.is_empty():
		return null
		
	var selected_card: PlayingCard = cards.pick_random()
	cards.erase(selected_card)
	
	return selected_card


func add_to_discard_pile(card: PlayingCard) -> void:
	if not discard_pile.has(card):
		discard_pile.append(card)


func extract_from_discard_pile(card: PlayingCard) -> PlayingCard:
	if discard_pile.has(card):
		var selected_card: PlayingCard = cards[cards.find(card)]
	
		return selected_card
		
	return null
