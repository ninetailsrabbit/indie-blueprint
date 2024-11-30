extends Control

@onready var deck: DeckControl = $Deck


func _ready() -> void:
	deck.load_deck_by_record_id(DeckDatabase.KinFrenchPlayingCardsDeck)
	
	
