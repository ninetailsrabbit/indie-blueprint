class_name SpanishPlayingCard extends PlayingCard


@export var suit: Deck.SpanishSuits


func is_number() -> bool:
	return value > 1 and value < 8


func is_jack() -> bool:
	return value == 10
	
	
func is_knight() -> bool:
	return value == 11
	
	
func is_king() -> bool:
	return value == 12
