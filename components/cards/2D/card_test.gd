extends Control

@onready var deck: Deck = $Deck
@onready var playing_cards_hand: PlayingCardsHand = $PlayingCardsHand
@onready var deck_pile: DeckPile = $DeckPile


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck.load_deck_by_record_id(DeckDatabase.KinFrenchPlayingCardsDeck).fill().shuffle().draw_visual_pile()
	
	playing_cards_hand.add_cards(deck.pick_random_cards(playing_cards_hand.maximum_cards + 2))
