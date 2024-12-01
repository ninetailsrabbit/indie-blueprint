extends Control

@onready var deck: DeckControl = $Deck
@onready var player_hand_control: PlayerHandControl = $PlayerHandControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck.load_deck_by_record_id(DeckDatabase.KinFrenchPlayingCardsDeck).fill().shuffle().draw_visual_pile()
	
	player_hand_control.add_cards(deck.pick_random_cards(player_hand_control.maximum_cards + 2))
