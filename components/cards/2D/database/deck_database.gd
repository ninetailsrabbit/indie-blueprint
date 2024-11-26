class_name DeckDatabase

const SpanishPlayingCardScene: PackedScene = preload("res://components/cards/2D/playing_cards/spanish_playing_card.tscn")
const FrenchPlayingCardScene: PackedScene = preload("res://components/cards/2D/playing_cards/french_playing_card.tscn")

const PixelSpanishDeck: StringName = &"pixel_spanish_deck"
const KinFrenchPlayingCardsDeck: StringName = &"kin_french_deck"

const FrenchSuits: Array[Deck.FrenchSuits] = [Deck.FrenchSuits.Club, Deck.FrenchSuits.Heart, Deck.FrenchSuits.Diamond, Deck.FrenchSuits.Spade]
const SpanishSuits: Array[Deck.SpanishSuits] = [Deck.SpanishSuits.Club, Deck.SpanishSuits.Cup, Deck.SpanishSuits.Gold, Deck.SpanishSuits.Sword]
	

static func get_deck(id: StringName) -> Deck:
	return available_decks.get(id, null)
			

#region Loaders
static func _load_spanish_deck(deck_data: Dictionary) -> Deck:
	var deck: Deck = Deck.new() 
	deck.deck_type = Deck.DeckTypes.Spanish
	deck.backs.append_array(deck_data[Deck.CommonSuits.Back])
	
	_add_jokers_to_deck(deck, deck_data, SpanishPlayingCardScene)
	_add_cards_to_deck(deck, deck_data, SpanishPlayingCardScene)
	
	return deck


static func _load_french_deck(deck_data: Dictionary) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_type = Deck.DeckTypes.French
	deck.backs.append_array(deck_data[Deck.CommonSuits.Back])
	
	_add_jokers_to_deck(deck, deck_data, FrenchPlayingCardScene)
	_add_cards_to_deck(deck, deck_data, FrenchPlayingCardScene)
	
	return deck
	
#endregion

#region Private
static func _add_jokers_to_deck(selected_deck: Deck, deck_data: Dictionary, playing_card_scene: PackedScene) -> void:
	for card_texture: CompressedTexture2D in deck_data[Deck.CommonSuits.Joker]:
		var joker_card: PlayingCard = playing_card_scene.instantiate()
		joker_card.id = "joker_%d" % selected_deck.jokers.size() 
		joker_card.display_name = "Joker"
		joker_card.front_texture = card_texture
		joker_card.value = 0
		joker_card.table_value = 0
		selected_deck.jokers.append(joker_card)
		
		if selected_deck.cards_by_suit.has(Deck.CommonSuits.Joker):
			selected_deck.cards_by_suit[Deck.CommonSuits.Joker].append(joker_card)
		else:
			selected_deck.cards_by_suit[Deck.CommonSuits.Joker] = [joker_card]


static func _add_cards_to_deck(selected_deck: Deck, deck_data: Dictionary, playing_card_scene: PackedScene) -> void:
	var suits = []
	
	if selected_deck.is_spanish_deck():
		suits = SpanishSuits
	elif selected_deck.is_french_deck():
		suits = FrenchSuits
	else:
		push_error("DeckDatabase: The selected deck type %s has no support on this database " % selected_deck.deck_type)
		
		return
		
	for suit in suits:
		var card_value: int = 1
		
		for card_texture: CompressedTexture2D in deck_data[suit]:
			var playing_card: PlayingCard = playing_card_scene.instantiate()
			playing_card.id = card_texture.resource_path.get_file().get_basename().strip_edges().to_camel_case()
			playing_card.display_name = playing_card.id.to_pascal_case()
			playing_card.front_texture = card_texture
			playing_card.value = card_value
			playing_card.table_value = card_value
			playing_card.suit = suit
			selected_deck.cards.append(playing_card)
			
			if selected_deck.cards_by_suit.has(suit):
				selected_deck.cards_by_suit[suit].append(playing_card)
			else:
				selected_deck.cards_by_suit[suit] = [playing_card]
				
			if selected_deck.is_spanish_deck():
				## In the spanish deck after the 7 the next one is the jack so we change the card value that allows to be 10 in the next iteration
				if card_value == 7:
					card_value = 10
				else:
					card_value += 1
			else:
				card_value += 1
#endregion
	
#region Preloaded decks
static var kin_french_deck: Dictionary = {
	Deck.CommonSuits.Joker: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_2.png")
	],
	Deck.CommonSuits.Back: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_5.png")
	],
	Deck.FrenchSuits.Diamond: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_5.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_6.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_7.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_8.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_9.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_10.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_11.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_12.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_13.png")
	],
	Deck.FrenchSuits.Heart: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/hearts_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_5.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_6.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_7.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_8.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_9.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_10.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_11.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_12.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_13.png")
	],
	Deck.FrenchSuits.Club: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_5.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_6.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_7.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_8.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_9.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_10.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_11.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_12.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_13.png")
	],
	Deck.FrenchSuits.Spade: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_5.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_6.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_7.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_8.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_9.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_10.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_11.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_12.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_13.png")
	],
}

static var pixel_spanish_deck: Dictionary = {
	Deck.CommonSuits.Joker: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_5.png")
	],
	Deck.CommonSuits.Back: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/backs/back.png")
	],
	Deck.SpanishSuits.Sword: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada5.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada6.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada7.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada8.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada9.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada10.png")
	],
	Deck.SpanishSuits.Club: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto5.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto6.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto7.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto8.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto9.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto10.png")
	],
	Deck.SpanishSuits.Gold: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro5.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro6.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro7.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro8.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro9.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro10.png")
	],
	Deck.SpanishSuits.Cup: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa5.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa6.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa7.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa8.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa9.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa10.png")
	]
}
#endregion

static var available_decks: Dictionary = {
	PixelSpanishDeck: _load_spanish_deck(pixel_spanish_deck),
	KinFrenchPlayingCardsDeck: _load_french_deck(kin_french_deck)
}

static var spanish_decks: Dictionary = {
	PixelSpanishDeck: available_decks[PixelSpanishDeck]
}

static var french_decks: Dictionary = {
	KinFrenchPlayingCardsDeck: available_decks[KinFrenchPlayingCardsDeck]
}
