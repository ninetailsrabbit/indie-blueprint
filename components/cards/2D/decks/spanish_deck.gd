class_name SpanishDeck extends Deck


func number_cards() -> Array[PlayingCard]:
	return cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 8)
