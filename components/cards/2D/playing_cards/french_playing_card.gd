class_name FrenchPlayingCard extends PlayingCard


@export var suit: Deck.FrenchSuits



func is_jack() -> bool:
	return value == 10
	
	
func is_queen() -> bool:
	return value == 11
	
	
func is_king() -> bool:
	return value == 12
