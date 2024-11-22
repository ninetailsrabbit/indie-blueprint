extends Node

@onready var ace_card: Marker2D = $AceCard
@onready var number_card: Marker2D = $NumberCard
@onready var jack_card: Marker2D = $JackCard
@onready var queen_card: Marker2D = $QueenCard
@onready var king_card: Marker2D = $KingCard
@onready var joker_card: Marker2D = $JokerCard
@onready var back: Marker2D = $Back

@onready var option_button: OptionButton = $OptionButton

var spanish_deck: Deck
var french_deck: Deck


func _ready() -> void:
	option_button.item_selected.connect(on_deck_selected)
	
	option_button.add_item(DeckDatabase.PixelSpanishDeck)
	option_button.add_item(DeckDatabase.KinFrenchPlayingCardsDeck)
	option_button.select(0)
	
	
	spanish_deck = DeckDatabase.get_deck(DeckDatabase.PixelSpanishDeck)
	french_deck = DeckDatabase.get_deck(DeckDatabase.KinFrenchPlayingCardsDeck)
	
	spanish_deck.fill().add_jokers(2)
	french_deck.fill().add_jokers(1)
	
	change_deck(spanish_deck)
	

func change_deck(new_deck: Deck) -> void:
	number_card.add_child(new_deck.pick_random_number_card())
	ace_card.add_child(new_deck.pick_random_ace())
	
	jack_card.add_child(new_deck.pick_random_jack())
	queen_card.add_child(new_deck.pick_random_queen() if new_deck.is_french_deck() else new_deck.pick_random_knight())
	king_card.add_child(new_deck.pick_random_king())
	
	if new_deck.has_jokers():
		joker_card.add_child(new_deck.pick_random_joker())
	
	var back_sprite: Sprite2D = Sprite2D.new()
	back_sprite.texture = new_deck.backs.pick_random()
	back_sprite.scale = new_deck.current_cards.pick_random().sprite.scale
	back.add_child(back_sprite)


func on_deck_selected(idx: int) -> void:
	match idx:
		0:
			change_deck(spanish_deck)
		1:
			change_deck(french_deck)
