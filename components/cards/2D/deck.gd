@icon("res://components/cards/2D/icons/deck.svg")
class_name Deck extends Control

signal loaded_new_deck
signal added_card(card: PlayingCard)
signal added_cards(card: Array[PlayingCard])
signal picked_card(card: PlayingCard)
signal removed_card(card: PlayingCard)
signal added_to_discard_pile(card: PlayingCard)
signal recovered_card_from_discard_pile(card: PlayingCard)
signal emptied_deck
signal filled
signal shuffled

@export var playing_cards_size: Vector2 = Vector2.ZERO

enum DeckTypes {
	French,
	Spanish
}

enum CommonSuits {
	Joker = 5,
	Back = 6
}


var deck_type: DeckTypes
#region Card templates
var cards_by_suit: Dictionary = {}
var cards: Array[PlayingCard] = []
var jokers: Array[PlayingCard] = []
#endregion
var backs: Array[CompressedTexture2D] = []


var current_back_texture: CompressedTexture2D
var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCard] = []
var discard_pile: Array[PlayingCard] = []

var jokers_count_for_empty_deck: bool = false

var visual_pile_node: Node2D
var start_visual_pile_with_amount: int = 5
var visual_pile_counter: int:
	set(value):
		@warning_ignore("integer_division")
		visual_pile_counter = clampi(value, 0, ceili(cards.size() / start_visual_pile_with_amount))

#region Preparation 
func _enter_tree() -> void:
	removed_card.connect(on_removed_card)


func _ready() -> void:
	if current_back_texture == null and backs.size() > 0:
		current_back_texture = backs.pick_random()


func load_deck_data(raw_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene = DeckDatabase.PlayingCardScene) -> Deck:
	deck_type = raw_data.type
	backs.append_array(raw_data.deck[PlayingCard.Suits.Back])
	
	_add_jokers_to_deck(raw_data, playing_card_scene)
	_add_cards_to_deck(raw_data, playing_card_scene)
	
	if current_back_texture == null and backs.size() > 0:
		current_back_texture = backs.pick_random()
		
	loaded_new_deck.emit()
	
	return self
	

func draw_visual_pile(amount: int = 5, distance: float = 1.5) -> void:
	start_visual_pile_with_amount = amount
	
	@warning_ignore("integer_division")
	visual_pile_counter = ceili(cards.size() / start_visual_pile_with_amount)
	
	var reference_card: PlayingCard = cards[0]
	
	for i in amount:
		var visual_sprite = TextureRect.new()
		visual_sprite.size = reference_card.front_texture.get_size() if reference_card.texture_size.is_zero_approx() else reference_card.texture_size
		visual_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		visual_sprite.texture = current_back_texture
		visual_sprite.position = Vector2(i * distance, -i * distance)
		add_child(visual_sprite)
		
		if i == 0:
			visual_sprite.position.y += 1
			visual_sprite.show_behind_parent = true
			visual_sprite.self_modulate = Color("1616166f")
	

func fill() -> Deck:
	current_cards = cards.duplicate()
	current_cards_by_suit = cards_by_suit.duplicate(true)
	## The jokers can be only added by the function 'add_jokers'
	current_cards_by_suit[Deck.CommonSuits.Joker].clear()
	
	filled.emit()
	
	return self


func shuffle() -> Deck:
	current_cards.shuffle()
	shuffled.emit()
	
	return self
#endregion
	
#region Random pickers
func pick_random_card() -> PlayingCard:
	if current_cards.is_empty():
		return null
	
	return pick_card(current_cards.pick_random())
	

func pick_random_cards(amount: int) -> Array[PlayingCard]:
	if current_cards.is_empty():
		return []
	
	var selected_cards: Array[PlayingCard] = []
	amount = clamp(amount, 1, current_cards.size())
	
	for i in amount:
		selected_cards.append(pick_card(current_cards.pick_random()))
	
	return selected_cards


func pick_random_number_card() -> PlayingCard:
	return pick_card(number_cards().pick_random())


## The function parameter "suit" is not typed as the suits are separated into different enums
func pick_random_card_from_suit(suit) -> PlayingCard:
	if current_cards_by_suit.has(suit) and current_cards_by_suit[suit].size() > 0:
		return pick_card(current_cards_by_suit[suit].pick_random())
	
	return null


func pick_random_card_of_value(value: int) -> PlayingCard:
	var selected_cards: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.value == value)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_card_of_suit_and_value(suit, value: int) -> PlayingCard:
	var selected_cards: Array[PlayingCard] = cards_from_suit(suit).filter(func(card: PlayingCard): return card.value == value)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_ace() -> PlayingCard:
	var aces: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_ace())
	
	if aces.is_empty():
		return null
		
	return pick_card(aces.pick_random())


func pick_random_jack() -> PlayingCard:
	var jacks: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_jack())
	
	if jacks.is_empty():
		return null
		
	return pick_card(jacks.pick_random())


func pick_random_queen() -> PlayingCard:
	var queens: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_queen())
	
	if queens.is_empty():
		return null
		
	return pick_card(queens.pick_random())


func pick_random_knight() -> PlayingCard:
	var knights: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_knight())
	
	if knights.is_empty():
		return null
		
	return pick_card(knights.pick_random())


func pick_random_king() -> PlayingCard:
	var kings: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_king())
	
	if kings.is_empty():
		return null
		
	return pick_card(kings.pick_random())


func pick_random_joker() -> PlayingCard:
	var selected_jokers: Array[PlayingCard] = current_cards.filter(func(card: PlayingCard): return card.is_joker())
	
	if selected_jokers.is_empty():
		return null
		
	return pick_card(selected_jokers.pick_random())

#endregion

#region Pickers
func pick_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	for card in selected_cards:
		pick_card(card)
		
	return selected_cards
	
	
func pick_card(card: PlayingCard) -> PlayingCard:
	remove_card(card)
	picked_card.emit(card)
	
	return card


func number_cards() -> Array[PlayingCard]:
	return extract_number_cards(current_cards)
	

func number_cards_from_suit(suit) -> Array[PlayingCard]:
	return extract_number_cards(cards_from_suit(suit))


func figure_cards() -> Array[PlayingCard]:
	return extract_figure_cards(current_cards)
	

func figure_cards_from_suit(suit) -> Array[PlayingCard]:
	return extract_figure_cards(cards_from_suit(suit))


func extract_number_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	match deck_type:
		DeckTypes.Spanish:
			return selected_cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 8)
		DeckTypes.French:
			return selected_cards.filter(func(card: PlayingCard): return card.value > 1 and card.value < 11)
	 
	return []


func extract_figure_cards(selected_cards: Array[PlayingCard]) -> Array[PlayingCard]:
	match deck_type:
		DeckTypes.Spanish:
			return selected_cards.filter(func(card: PlayingCard): return card.is_jack() or card.is_knight() or card.is_king())
		DeckTypes.French:
			return selected_cards.filter(func(card: PlayingCard): return card.is_jack() or card.is_queen() or card.is_king())
	 
	return []


func cards_from_suit(suit) -> Array[PlayingCard]:
	if current_cards_by_suit.has(suit):
		return current_cards_by_suit[suit]
	
	return []

#endregion

func add_cards(new_cards: Array[PlayingCard], allow_duplicates: bool = false) -> void:
	for card: PlayingCard in new_cards:
		add_card(card, allow_duplicates)
	
	added_cards.emit(new_cards)


func add_card(card: PlayingCard, allow_duplicates: bool = false) -> void:
	if allow_duplicates:
		current_cards.append(card)
		current_cards_by_suit[card.suit].append(card)
	else:
		if not current_cards.has(card):
			current_cards.append(card)
			
		if not current_cards_by_suit[card.suit].has(card):
			current_cards_by_suit[card.suit].append(card)
	
	added_card.emit(card)
	
	
func remove_card(card: PlayingCard):
	current_cards.erase(card)
	
	if current_cards_by_suit.has(card.suit):
		current_cards_by_suit[card.suit].erase(card)
		removed_card.emit(card)
	
	if is_empty():
		emptied_deck.emit()
	
	add_to_discard_pile(card)
	

func add_jokers(amount: int, selected_card: PlayingCard = null) -> Deck:
	if amount > 0 and jokers.size() > 0:
		var new_jokers: Array[PlayingCard] = []
		var joker: PlayingCard = selected_card if selected_card != null and selected_card.is_joker() else jokers.pick_random()
		
		new_jokers.assign(ArrayHelper.repeat(joker, amount))
		
		add_cards(new_jokers)
		
	return self
	

#region Discard pile
func add_to_discard_pile(card: PlayingCard) -> void:
	if not discard_pile.has(card):
		discard_pile.append(card)
		added_to_discard_pile.emit(card)


func extract_from_discard_pile(card: PlayingCard) -> PlayingCard:
	if discard_pile.has(card):
		var selected_card: PlayingCard = discard_pile[discard_pile.find(card)]
		discard_pile.erase(card)
		
		return selected_card
	
	return null


func recover_from_discard_pile(card: PlayingCard) -> PlayingCard:
	var card_to_recover: PlayingCard = extract_from_discard_pile(card)
	
	if card_to_recover != null:
		add_card(card_to_recover)
		recovered_card_from_discard_pile.emit(card)
	return null
#endregion

#region Information
func has_aces() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_ace())
	
	
func has_jokers() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_joker())
	

func has_only_jokers() -> bool:
	return current_cards.all(func(card: PlayingCard): return card.is_joker())
	
	
func has_jacks() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_jack())
	
	
func has_queens() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_queen())
	

func has_knights() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_knight())
	

func has_kings() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_king())
	
	
func has_number_cards() -> bool:
	return current_cards.any(func(card: PlayingCard): return card.is_number())
	

func is_empty() -> bool:
	return (has_only_jokers() and not jokers_count_for_empty_deck) or current_cards.is_empty()


func size() -> int:
	return current_cards.size()
	

func is_spanish_deck() -> bool:
	return deck_type == DeckTypes.Spanish
	
	
func is_french_deck() -> bool:
	return deck_type == DeckTypes.French
#endregion

#region Private
func _add_jokers_to_deck(deck_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene) -> void:
	for card_texture: CompressedTexture2D in deck_data.deck[PlayingCard.Suits.Joker]:
		var joker_card: PlayingCard = playing_card_scene.instantiate()
		joker_card.id = "joker_%d" % jokers.size() 
		joker_card.display_name = "Joker"
		joker_card.front_texture = card_texture
		joker_card.value = 0
		joker_card.table_value = 0
		
		if not playing_cards_size.is_zero_approx():
			joker_card.texture_size = playing_cards_size
		
		jokers.append(joker_card)
		
		if cards_by_suit.has(PlayingCard.Suits.Joker):
			cards_by_suit[PlayingCard.Suits.Joker].append(joker_card)
		else:
			cards_by_suit[PlayingCard.Suits.Joker] = [joker_card]


func _add_cards_to_deck(deck_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene) -> void:
	var suits = []
	
	if is_spanish_deck():
		suits = PlayingCard.SpanishSuits
	elif is_french_deck():
		suits = PlayingCard.FrenchSuits
	else:
		return
		
	for suit in suits:
		var card_value: int = 1
		
		for card_texture: CompressedTexture2D in deck_data.deck[suit]:
			var playing_card: PlayingCard = playing_card_scene.instantiate()
			playing_card.id = card_texture.resource_path.get_file().get_basename().strip_edges().to_camel_case()
			playing_card.display_name = playing_card.id.to_pascal_case()
			playing_card.front_texture = card_texture
			playing_card.value = card_value
			playing_card.table_value = card_value
			playing_card.suit = suit
			
			if not playing_cards_size.is_zero_approx():
				playing_card.texture_size = playing_cards_size
				
			cards.append(playing_card)
			
			if cards_by_suit.has(suit):
				cards_by_suit[suit].append(playing_card)
			else:
				cards_by_suit[suit] = [playing_card]
				
			if is_spanish_deck():
				## In the spanish deck after the 7 the next one is the jack so we change the card value that allows to be 10 in the next iteration
				if card_value == 7:
					card_value = 10
				else:
					card_value += 1
			else:
				card_value += 1
#endregion

#region Signal callbacks
func on_added_card(_card: PlayingCard) -> void:
	visual_pile_counter += 1
	

func on_removed_card(_card: PlayingCard) -> void:
	visual_pile_counter -= 1
	
	if visual_pile_counter == 0 and get_child_count() > 0:
		NodeTraversal.get_last_child(self).queue_free()
		@warning_ignore("integer_division")
		visual_pile_counter = ceili(cards.size() / start_visual_pile_with_amount)

#endregion
