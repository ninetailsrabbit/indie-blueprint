class_name DeckDatabase

#const PlayingCardScene: PackedScene = preload("res://components/cards/2D/playing_card.tscn")
#
#const PixelSpanishDeck: StringName = &"pixel_spanish_deck"
#const KinFrenchPlayingCardsDeck: StringName = &"kin_french_deck"
#const ModernPixelDeck: StringName = &"modern_pixel_deck"
#const InscryptionInspiredDeck: StringName = &"inscryption_inspired_deck"
#const MinimalistPixelDeck: StringName = &"minimalist_pixel_deck"
#const LazySpacePixelArtDeck: StringName = &"lazy_space_pixel_art_deck"
#const HandDrawDeck: StringName = &"hand_draw_deck"
#
#class DeckRawData:
	#var type: Deck.DeckTypes
	#var deck: Dictionary
#
#
	#func _init(_type: Deck.DeckTypes, _deck: Dictionary) -> void:
		#type = _type
		#deck = _deck
#
#
#
#static func get_deck(id: StringName) -> Deck:
	#return available_decks.get(id, null)
		#
		#
#static func get_raw_deck(id: StringName) -> DeckRawData:
	#return available_raw_decks.get(id, null)
			#
#
##region Loaders
#static func create_deck(deck_data: DeckRawData) -> Deck:
	#var deck: Deck = Deck.new()
	#deck.load_deck_data(deck_data, PlayingCardScene)
#
	#return deck
##endregion
#
##
	#
##region Preloaded decks
#static var kin_french_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/jokers/Joker_2.png")
	#],
	#PlayingCard.Suits.Back: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_2.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_3.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_4.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/backs/Back_5.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_2.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_3.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_4.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_5.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_6.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_7.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_8.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_9.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_10.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_11.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_12.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/diamonds/Diamonds_13.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/hearts_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_2.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_3.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_4.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_5.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_6.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_7.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_8.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_9.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_10.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_11.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_12.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/hearts/Hearts_13.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_2.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_3.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_4.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_5.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_6.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_7.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_8.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_9.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_10.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_11.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_12.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/clubs/Clubs_13.png")
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_1.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_2.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_3.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_4.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_5.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_6.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_7.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_8.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_9.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_10.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_11.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_12.png"),
		#preload("res://components/cards/2D/database/french_decks/KIN's_Playing_Cards/spades/Spades_13.png")
	#],
#}
#
#static var pixel_spanish_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_1.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_2.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_3.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_4.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/jokers/joker_5.png")
	#],
	#PlayingCard.Suits.Back: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/backs/back.png")
	#],
	#PlayingCard.Suits.Sword: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada1.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada2.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada3.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada4.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada5.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada6.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada7.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada8.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada9.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/swords/espada10.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto1.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto2.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto3.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto4.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto5.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto6.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto7.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto8.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto9.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/clubs/basto10.png")
	#],
	#PlayingCard.Suits.Gold: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro1.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro2.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro3.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro4.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro5.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro6.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro7.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro8.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro9.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/golds/oro10.png")
	#],
	#PlayingCard.Suits.Cup: [
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa1.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa2.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa3.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa4.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa5.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa6.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa7.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa8.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa9.png"),
		#preload("res://components/cards/2D/database/spanish_decks/pixel_deck/hearts/copa10.png")
	#]
#}
#
#static var modern_pixel_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/jokers/j.png")
	#],
	#PlayingCard.Suits.Back: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/backs/back.png")
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s1.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s2.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s3.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s4.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s5.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s6.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s7.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s8.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s9.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s10.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s11.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s12.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/spades/s13.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c1.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c2.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c3.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c4.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c5.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c6.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c7.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c8.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c9.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c10.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c11.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c12.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/clubs/c13.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d1.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d2.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d3.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d4.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d5.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d6.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d7.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d8.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d9.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d10.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d11.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d12.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/diamonds/d13.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h1.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h2.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h3.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h4.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h5.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h6.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h7.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h8.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h9.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h10.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h11.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h12.png"),
		#preload("res://components/cards/2D/database/french_decks/Modern_Pixel/hearts/h13.png")
	#]
#}
#
#static var inscryption_inspired_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/jokers/joker_black.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/jokers/joker_red.png")
	#],
	#PlayingCard.Suits.Back: [
 		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/backs/back.png")
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/1_ace_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/2_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/3_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/4_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/5_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/6_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/7_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/8_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/9_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/10_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/11_jack_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/12_queen_of_spades.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/spades/13_king_of_spades.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/1_ace_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/2_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/3_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/4_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/5_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/6_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/7_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/8_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/9_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/10_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/11_jack_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/12_queen_of_clubs.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/clubs/13_king_of_clubs.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/1_ace_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/2_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/3_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/4_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/5_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/6_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/7_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/8_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/9_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/10_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/11_jack_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/12_queen_of_diamonds.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/diamonds/13_king_of_diamonds.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/1_ace_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/2_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/3_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/4_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/5_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/6_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/7_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/8_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/9_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/10_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/11_jack_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/12_queen_of_hearts.png"),
		#preload("res://components/cards/2D/database/french_decks/InscryptionInspiredDeck/hearts/13_king_of_hearts.png")
	#]
#}
#
#
#static var minimalist_pixel_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/jokers/joker_white.png")
	#],
	#PlayingCard.Suits.Back: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_black_basic.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_black_basic_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_blue_basic.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_blue_basic_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_red_basic.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/backs/back_red_basic_white.png")
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/1_ace_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/2_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/3_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/4_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/5_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/6_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/7_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/8_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/9_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/10_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/11_jack_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/12_queen_spades_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/spades/13_king_spades_white.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/1_ace_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/2_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/3_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/4_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/5_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/6_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/7_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/8_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/9_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/10_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/11_jack_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/12_queen_clubs_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/clubs/13_king_clubs_white.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/1_ace_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/2_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/3_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/4_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/5_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/6_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/7_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/8_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/9_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/10_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/11_jack_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/12_queen_diamonds_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/diamonds/13_king_diamonds_white.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/1_ace_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/2_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/3_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/4_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/5_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/6_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/7_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/8_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/9_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/10_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/11_jack_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/12_queen_hearts_white.png"),
		#preload("res://components/cards/2D/database/french_decks/Minimalist_Pixel_Cards/hearts/13_king_hearts_white.png")
	#]
#}
#
#
#static var lazyspace_pixel_art_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
	#],
	#PlayingCard.Suits.Back: [
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_27.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_28.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_29.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_30.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_31.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_32.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_33.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_34.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_35.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_36.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_37.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_38.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/spades/card_39.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_40.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_41.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_42.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_43.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_44.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_45.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_46.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_47.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_48.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_49.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_50.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_51.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/clubs/card_52.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_14.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_15.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_16.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_17.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_18.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_19.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_20.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_21.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_22.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_23.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_24.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_25.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/diamonds/card_26.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_01.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_02.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_03.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_04.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_05.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_06.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_07.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_08.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_09.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_10.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_11.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_12.png"),
		#preload("res://components/cards/2D/database/french_decks/LazySpace_Pixel_Cards/hearts/card_13.png")
	#]
#}
##endregion
#
#static var hand_draw_deck: Dictionary = {
	#PlayingCard.Suits.Joker: [
	#],
	#PlayingCard.Suits.Back: [
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/backs/back_blue.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/backs/back_red.png")
	#],
	#PlayingCard.Suits.Spade: [
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/1s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/2s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/3s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/4s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/5s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/6s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/7s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/8s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/9s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/10s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/11s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/12s.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/spades/13s.png")
	#],
	#PlayingCard.Suits.Club: [
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/1c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/2c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/3c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/4c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/5c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/6c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/7c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/8c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/9c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/10c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/11c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/12c.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/clubs/13c.png")
	#],
	#PlayingCard.Suits.Diamond: [
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/1d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/2d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/3d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/4d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/5d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/6d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/7d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/8d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/9d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/10d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/11d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/12d.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/diamonds/13d.png")
	#],
	#PlayingCard.Suits.Heart: [
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/1h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/2h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/3h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/4h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/5h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/6h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/7h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/8h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/9h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/10h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/11h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/12h.png"),
		#preload("res://components/cards/2D/database/french_decks/HandDrawCards/hearts/13h.png")
	#]
#}
#
#static var available_raw_decks: Dictionary = {
	#PixelSpanishDeck: DeckRawData.new(Deck.DeckTypes.Spanish, pixel_spanish_deck),
	#KinFrenchPlayingCardsDeck: DeckRawData.new(Deck.DeckTypes.French, kin_french_deck),
	#ModernPixelDeck: DeckRawData.new(Deck.DeckTypes.French, modern_pixel_deck),
	#InscryptionInspiredDeck: DeckRawData.new(Deck.DeckTypes.French, inscryption_inspired_deck),
	#MinimalistPixelDeck: DeckRawData.new(Deck.DeckTypes.French, minimalist_pixel_deck),
	#LazySpacePixelArtDeck: DeckRawData.new(Deck.DeckTypes.French, lazyspace_pixel_art_deck),
	#HandDrawDeck: DeckRawData.new(Deck.DeckTypes.French, hand_draw_deck),
#}
#
#static var available_decks: Dictionary = {
	#PixelSpanishDeck: create_deck(available_raw_decks[PixelSpanishDeck]),
	#KinFrenchPlayingCardsDeck: create_deck(available_raw_decks[KinFrenchPlayingCardsDeck]),
	#ModernPixelDeck: create_deck(available_raw_decks[ModernPixelDeck]),
	#InscryptionInspiredDeck: create_deck(available_raw_decks[InscryptionInspiredDeck]),
	#MinimalistPixelDeck: create_deck(available_raw_decks[MinimalistPixelDeck]),
	#LazySpacePixelArtDeck: create_deck(available_raw_decks[LazySpacePixelArtDeck]),
	#HandDrawDeck: create_deck(available_raw_decks[HandDrawDeck])
	#
#}
#
#static var spanish_decks: Dictionary = {
	#PixelSpanishDeck: available_decks[PixelSpanishDeck]
#}
#
#static var french_decks: Dictionary = {
	#KinFrenchPlayingCardsDeck: available_decks[KinFrenchPlayingCardsDeck],
	#ModernPixelDeck: available_decks[ModernPixelDeck],
	#InscryptionInspiredDeck: available_decks[InscryptionInspiredDeck],
	#MinimalistPixelDeck: available_decks[MinimalistPixelDeck],
	#LazySpacePixelArtDeck: available_decks[LazySpacePixelArtDeck],
	#HandDrawDeck: available_decks[HandDrawDeck]
#}
#
#
##region New deck template
### Only use this to preload new decks
#static var spanish_deck_template: Dictionary = {
	#PlayingCard.Suits.Joker: [
	#],
	#PlayingCard.Suits.Back: [
	#],
	#PlayingCard.Suits.Sword: [
	#],
	#PlayingCard.Suits.Club: [
	#],
	#PlayingCard.Suits.Gold: [
	#],
	#PlayingCard.Suits.Cup: [
	#]
#}
#
#static var french_deck_template: Dictionary = {
	#PlayingCard.Suits.Joker: [
	#],
	#PlayingCard.Suits.Back: [
	#],
	#PlayingCard.Suits.Spade: [
	#],
	#PlayingCard.Suits.Club: [
	#],
	#PlayingCard.Suits.Diamond: [
	#],
	#PlayingCard.Suits.Heart: [
	#]
#}
#
##endregion
