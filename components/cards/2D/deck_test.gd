extends Node

@onready var ace_card: Marker2D = $AceCard
@onready var number_card: Marker2D = $NumberCard
@onready var jack_card: Marker2D = $JackCard
@onready var queen_card: Marker2D = $QueenCard
@onready var king_card: Marker2D = $KingCard
@onready var joker_card: Marker2D = $JokerCard
@onready var back: Marker2D = $Back

@onready var option_button: OptionButton = $OptionButton


func _ready() -> void:
	option_button.item_selected.connect(on_deck_selected)
	
	option_button.add_item(DeckDatabase.PixelSpanishDeck)
	option_button.add_item(DeckDatabase.KinFrenchPlayingCards)
	option_button.select(0)
	
	var spanish_deck: Deck = DeckDatabase.create_spanish_deck(DeckDatabase.PixelSpanishDeck)
	var french_deck: Deck = DeckDatabase.create_french_deck(DeckDatabase.KinFrenchPlayingCards)
	
	spanish_deck.fill()
	french_deck.fill()
	
	number_card.add_child(spanish_deck.pick_random_number_card())
	jack_card.add_child(spanish_deck.pick_random_ace())


func on_deck_selected(idx: int) -> void:
	match idx:
		1:
			pass
		2:
			pass
