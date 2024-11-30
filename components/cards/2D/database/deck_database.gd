class_name DeckDatabase


const PixelSpanishDeck: StringName = &"pixel_spanish_deck"
const KinFrenchPlayingCardsDeck: StringName = &"kin_french_playing_cards_deck"

enum DeckType {
	Spanish,
	French
}

class DeckRecord:
	var type: DeckType
	
	var backs: Array[CompressedTexture2D] = []
	var jokers: Array[PlayingCard] = []
	var clubs: Array[PlayingCard] = []
	var hearts: Array[PlayingCard] = []
	var diamonds: Array[PlayingCard] = []
	var spades: Array[PlayingCard] = []
	var golds: Array[PlayingCard] = []
	var cups: Array[PlayingCard] = []
	var swords: Array[PlayingCard] = []
	
	
	func _init(deck_data: Dictionary) -> void:
		type = deck_data.type
		
		backs.append_array(deck_data.deck[PlayingCard.Suits.Back])
		jokers.append_array(deck_data.deck[PlayingCard.Suits.Joker])
		clubs.append_array(deck_data.deck[PlayingCard.Suits.Club])
		
		if is_french():
			hearts.append_array(deck_data.deck[PlayingCard.Suits.Heart])
			diamonds.append_array(deck_data.deck[PlayingCard.Suits.Diamond])
			spades.append_array(deck_data.deck[PlayingCard.Suits.Spade])
		elif is_spanish():
			golds.append_array(deck_data.deck[PlayingCard.Suits.Gold])
			cups.append_array(deck_data.deck[PlayingCard.Suits.Cup])
			swords.append_array(deck_data.deck[PlayingCard.Suits.Sword])
			
			
	func is_spanish() -> bool:
		return type == DeckType.Spanish
		
	func is_french() -> bool:
		return type == DeckType.French


static func get_deck(id: StringName) -> DeckRecord:
	var deck: Dictionary = available_decks.get(id, null)
	var deck_record: DeckRecord = DeckRecord.new(deck)
	
	return deck_record
		

static var kin_french_playing_cards: Dictionary = {
	PlayingCard.Suits.Joker: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_1.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_2.tres")
	],
	PlayingCard.Suits.Back: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_1.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_2.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_3.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_4.png"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_5.png")
	],
	PlayingCard.Suits.Spade: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_1.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_2.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_3.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_4.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_5.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_6.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_7.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_8.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_9.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_10.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_11.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_12.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_13.tres")
	],
	PlayingCard.Suits.Club: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_1.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_2.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_3.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_4.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_5.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_6.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_7.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_8.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_9.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_10.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_11.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_12.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_13.tres")
	],
	PlayingCard.Suits.Diamond: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_1.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_2.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_3.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_4.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_5.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_6.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_7.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_8.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_9.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_10.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_11.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_12.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_13.tres")
	],
	PlayingCard.Suits.Heart: [
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/hearts_1.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_2.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_3.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_4.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_5.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_6.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_7.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_8.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_9.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_10.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_11.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_12.tres"),
		preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_13.tres")
	]
}

static var pixel_spanish_deck: Dictionary = {
	PlayingCard.Suits.Joker: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_1.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_2.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_3.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_4.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_5.tres")
	],
	PlayingCard.Suits.Back: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/backs/back.png")
	],
	PlayingCard.Suits.Sword: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada1.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada2.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada3.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada4.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada5.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada6.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada7.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada10.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada11.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada12.tres")
	],
	PlayingCard.Suits.Club: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto1.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto2.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto3.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto4.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto5.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto6.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto7.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto10.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto11.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto12.tres")
	],
	PlayingCard.Suits.Gold: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro1.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro2.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro3.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro4.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro5.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro6.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro7.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro10.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro11.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro12.tres")
	],
	PlayingCard.Suits.Cup: [
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa1.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa2.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa3.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa4.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa5.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa6.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa7.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa10.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa11.tres"),
		preload("res://components/cards/2D/database/spanish_decks/pixel_deck/cups/copa12.tres")
	]
}


static var available_decks: Dictionary = {
	PixelSpanishDeck: {"type": DeckType.Spanish, "deck": pixel_spanish_deck},
	KinFrenchPlayingCardsDeck: {"type": DeckType.French, "deck": kin_french_playing_cards}
}

#region New deck template
### Only use this to preload new decks
static var spanish_deck_template: Dictionary = {
	PlayingCard.Suits.Joker: [
	],
	PlayingCard.Suits.Back: [
	],
	PlayingCard.Suits.Sword: [
	],
	PlayingCard.Suits.Club: [
	],
	PlayingCard.Suits.Gold: [
	],
	PlayingCard.Suits.Cup: [
	]
}

static var french_deck_template: Dictionary = {
	PlayingCard.Suits.Joker: [
	],
	PlayingCard.Suits.Back: [
	],
	PlayingCard.Suits.Spade: [
	],
	PlayingCard.Suits.Club: [
	],
	PlayingCard.Suits.Diamond: [
	],
	PlayingCard.Suits.Heart: [
	]
}

##endregion
