extends Control

#@onready var deck: Deck = $Deck
#
#@onready var deck_pile_left: DeckPile = $DeckPile
#@onready var deck_pile_center: DeckPile = $DeckPile2
#@onready var player_hand: PlayerHand = $PlayerHand


#func _ready() -> void:
	#deck.load_deck_data(DeckDatabase.available_raw_decks[DeckDatabase.HandDrawDeck])\
		#.fill().shuffle().draw_visual_pile(5)
#
	#var card_detection_area_size: Vector2 = deck.cards[0].front_sprite.size
	#
	#deck_pile_left.change_detection_area_size(card_detection_area_size)
	#deck_pile_center.change_detection_area_size(card_detection_area_size)
	#
	#player_hand.draw_from_deck(deck, player_hand.maximum_cards)
