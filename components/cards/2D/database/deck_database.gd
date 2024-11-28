class_name DeckDatabase

const PlayingCardScene: PackedScene = preload("res://components/cards/2D/playing_card.tscn")

const PixelSpanishDeck: StringName = &"pixel_spanish_deck"
const KinFrenchPlayingCardsDeck: StringName = &"kin_french_deck"

class DeckRawData:
	var type: Deck.DeckTypes
	var deck: Dictionary


	func _init(_type: Deck.DeckTypes, _deck: Dictionary) -> void:
		type = _type
		deck = _deck



static func get_deck(id: StringName) -> Deck:
	return available_decks.get(id, null)
		
		
static func get_raw_deck(id: StringName) -> DeckRawData:
	return available_raw_decks.get(id, null)
			

#region Loaders
static func create_deck(deck_data: DeckRawData) -> Deck:
	var deck: Deck = Deck.new()
	deck.load_deck_data(deck_data, PlayingCardScene)

	return deck
#endregion

#
	
#region Preloaded decks
static var kin_french_deck: Dictionary = {
	PlayingCard.Suits.Joker: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_2.png")
	],
	PlayingCard.Suits.Back: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_5.png")
	],
	PlayingCard.Suits.Diamond: [
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
	PlayingCard.Suits.Heart: [
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
	PlayingCard.Suits.Club: [
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
	PlayingCard.Suits.Spade: [
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
	PlayingCard.Suits.Joker: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_1.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_2.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_3.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_4.png"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_5.png")
	],
	PlayingCard.Suits.Back: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/backs/back.png")
	],
	PlayingCard.Suits.Sword: [
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
	PlayingCard.Suits.Club: [
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
	PlayingCard.Suits.Gold: [
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
	PlayingCard.Suits.Cup: [
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
static var available_raw_decks: Dictionary = {
	PixelSpanishDeck: DeckRawData.new(Deck.DeckTypes.Spanish, pixel_spanish_deck),
	KinFrenchPlayingCardsDeck: DeckRawData.new(Deck.DeckTypes.French, kin_french_deck)
}

static var available_decks: Dictionary = {
	PixelSpanishDeck: create_deck(available_raw_decks[PixelSpanishDeck]),
	KinFrenchPlayingCardsDeck: create_deck(available_raw_decks[KinFrenchPlayingCardsDeck])
}

static var spanish_decks: Dictionary = {
	PixelSpanishDeck: available_decks[PixelSpanishDeck]
}

static var french_decks: Dictionary = {
	KinFrenchPlayingCardsDeck: available_decks[KinFrenchPlayingCardsDeck]
}
