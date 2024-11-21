class_name DeckDatabase

const PixelSpanishDeck: StringName = &"pixel_spanish_deck"
const KinFrenchPlayingCards: StringName = &"kin_french_deck"


static func create_deck(id: StringName, type: DeckManager.DeckTypes) -> Deck:
	match type:
		DeckManager.DeckTypes.Spanish:
			return create_spanish_deck(id)
		DeckManager.DeckTypes.French:
			return create_french_deck(id)
	
	return null


static func create_spanish_deck(id: StringName) -> SpanishDeck:
	if spanish_decks.has(id):
		var selected_deck: Dictionary = spanish_decks[id]
		var deck: Deck = SpanishDeck.new()
		deck.backs.append_array(selected_deck[DeckManager.CommonSuits.Back])
		
		for card_texture: CompressedTexture2D in selected_deck[DeckManager.CommonSuits.Joker]:
			var joker_card: PlayingCard = SpanishPlayingCard.new()
			joker_card.id = "joker_%d" % deck.jokers.size() 
			joker_card.display_name = "Joker"
			joker_card.front_texture = card_texture
			joker_card.value = 0
			joker_card.table_value = 0
			deck.jokers.append(joker_card)
		
		for suit in [DeckManager.SpanishSuits.Club, DeckManager.SpanishSuits.Cup, DeckManager.SpanishSuits.Gold, DeckManager.SpanishSuits.Sword]:
			var card_value: int = 1
		
			for card_texture: CompressedTexture2D in selected_deck[suit]:
				var playing_card: PlayingCard = SpanishPlayingCard.new()
				playing_card.id = card_texture.resource_path.get_file().get_basename().strip_edges().to_camel_case()
				playing_card.front_texture = card_texture
				playing_card.value = card_value
				playing_card.table_value = card_value
				deck.cards.append(playing_card)
				
				card_value += 1
			
		return deck
			
	push_error("DeckManager: The deck with id %s does not exists in this database" % id)
	
	return null


static func create_french_deck(id: StringName) -> FrenchDeck:
	if french_decks.has(id):
		var selected_deck: Dictionary = french_decks[id]
		var deck: Deck = FrenchDeck.new()
		deck.backs.append_array(selected_deck[DeckManager.CommonSuits.Back])
		
		for card_texture: CompressedTexture2D in selected_deck[DeckManager.CommonSuits.Joker]:
			var joker_card: PlayingCard = SpanishPlayingCard.new()
			joker_card.id = "joker_%d" % deck.jokers.size() 
			joker_card.display_name = "Joker"
			joker_card.front_texture = card_texture
			joker_card.value = 0
			joker_card.table_value = 0
			deck.jokers.append(joker_card)
		
		for suit in [DeckManager.FrenchSuits.Club, DeckManager.FrenchSuits.Heart, DeckManager.FrenchSuits.Diamond, DeckManager.FrenchSuits.Spade]:
			var card_value: int = 1
		
			for card_texture: CompressedTexture2D in selected_deck[suit]:
				var playing_card: PlayingCard = SpanishPlayingCard.new()
				playing_card.id = card_texture.resource_path.get_file().get_basename().strip_edges().to_camel_case()
				playing_card.front_texture = card_texture
				playing_card.value = card_value
				playing_card.table_value = card_value
				deck.cards.append(playing_card)
				
				card_value += 1
			
		return deck
			
	push_error("DeckManager: The deck with id %s does not exists in this database" % id)
	
	return null


static var kin_french_deck: Dictionary = {
	DeckManager.CommonSuits.Joker: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_2.png")
	],
	DeckManager.CommonSuits.Back: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_5.png")
	],
	DeckManager.FrenchSuits.Diamond: [
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
	DeckManager.FrenchSuits.Heart: [
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
	DeckManager.FrenchSuits.Club: [
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
	DeckManager.FrenchSuits.Spade: [
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
	DeckManager.CommonSuits.Joker: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_5.png")
	],
	DeckManager.CommonSuits.Back: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/backs/back.png")
	],
	DeckManager.SpanishSuits.Sword: [
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
	DeckManager.SpanishSuits.Club: [
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
	DeckManager.SpanishSuits.Gold: [
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
	DeckManager.SpanishSuits.Cup: [
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


static var spanish_decks: Dictionary = {
	PixelSpanishDeck: pixel_spanish_deck
}


static var french_decks: Dictionary = {
	KinFrenchPlayingCards: kin_french_deck
}
