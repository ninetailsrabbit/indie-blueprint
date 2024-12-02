@icon("res://components/cards/2D/icons/deck.svg")
class_name Deck extends Control


signal loaded_new_deck
signal added_card(card: PlayingCardUI)
signal added_cards(card: Array[PlayingCardUI])
signal picked_card(card: PlayingCardUI)
signal removed_card(card: PlayingCardUI)
signal added_to_discard_pile(card: PlayingCardUI)
signal recovered_card_from_discard_pile(card: PlayingCardUI)
signal emptied_deck
signal cleared_deck
signal filled
signal shuffled


@export var playing_card_scene: PackedScene = preload("res://components/cards/2D/components/playing_card_ui.tscn")
@export var playing_cards_size: Vector2 = Vector2.ZERO
@export var visual_pile_position_offset: Vector2 = Vector2(1.5, 1.5)


#region Card templates
var cards_by_suit: Dictionary = {
	PlayingCard.Suits.Joker: [],
	PlayingCard.Suits.Heart: [],
	PlayingCard.Suits.Diamond: [],
	PlayingCard.Suits.Spade: [],
	PlayingCard.Suits.Club: [],
	PlayingCard.Suits.Gold: [],
	PlayingCard.Suits.Cup: [],
	PlayingCard.Suits.Sword: [],
}
var cards: Array[PlayingCardUI] = []
var jokers: Array[PlayingCardUI] = []
var backs: Array[CompressedTexture2D] = []
#endregion


var current_back_texture: CompressedTexture2D
var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCardUI] = []
var discard_pile: Array[PlayingCardUI] = []

var jokers_count_for_empty_deck: bool = false

var default_visual_pile_cards_amount: int = 5
var visual_pile_cards_amount: int = default_visual_pile_cards_amount
var visual_pile_counter: int:
	set(value):
		@warning_ignore("integer_division")
		visual_pile_counter = clampi(value, 0, _calculate_visual_pile_counter())

#region Preparation 
func _enter_tree() -> void:
	removed_card.connect(on_removed_card)


func _ready() -> void:
	if current_back_texture == null and backs.size() > 0:
		current_back_texture = backs.pick_random()


#region Deck record loader
func load_deck_by_record_id(id: StringName) -> Deck:
	return load_deck_record(DeckDatabase.get_deck(id))
	
	
func load_deck_record(deck_record: DeckDatabase.DeckRecord) -> Deck:
	clear_deck()
	
	backs.append_array(deck_record.backs)
	
	current_back_texture = deck_record.backs[0]
	
	for joker: PlayingCard in deck_record.jokers:
		load_card_into_deck(joker)
	
	for club: PlayingCard in deck_record.clubs:
		load_card_into_deck(club)
		
	if deck_record.is_spanish():
		for gold: PlayingCard in deck_record.golds:
			load_card_into_deck(gold)
			
		for cup: PlayingCard in deck_record.cups:
			load_card_into_deck(cup)
			
		for sword: PlayingCard in deck_record.swords:
			load_card_into_deck(sword)
			
	elif deck_record.is_french():
		for heart: PlayingCard in deck_record.hearts:
			load_card_into_deck(heart)
			
		for diamond: PlayingCard in deck_record.diamonds:
			load_card_into_deck(diamond)
			
		for spade: PlayingCard in deck_record.spades:
			load_card_into_deck(spade)
			
	loaded_new_deck.emit()
	
	return self
	

func load_card_into_deck(card: PlayingCard) -> void:
	var playing_card: PlayingCardUI = playing_card_scene.instantiate()
	playing_card.card = card
	
	cards.append(playing_card)
	cards_by_suit[card.suit].append(playing_card)
	
#endregion

func draw_visual_pile(amount: int = default_visual_pile_cards_amount, position_offset: Vector2 = visual_pile_position_offset) -> Deck:
	@warning_ignore("integer_division")
	visual_pile_counter = _calculate_visual_pile_counter()
	visual_pile_cards_amount = amount
	
	var reference_card: PlayingCardUI = cards[0]
	
	for i in amount:
		var visual_sprite = TextureRect.new()
		visual_sprite.name = "DeckVisualCard"
		
		if not reference_card.card.texture_size.is_zero_approx() \
			and reference_card.card.texture_size != reference_card.card.back_texture.get_size():
			visual_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			visual_sprite.custom_minimum_size = reference_card.card.texture_size
			visual_sprite.size = reference_card.card.texture_size
			
		visual_sprite.texture = current_back_texture
		visual_sprite.position = position_offset * i
		add_child(visual_sprite)
	
	return self


func fill() -> Deck:
	current_cards = cards.duplicate()
	current_cards_by_suit = cards_by_suit.duplicate(true)
	## The jokers can be only added by the function 'add_jokers'
	current_cards_by_suit[PlayingCard.Suits.Joker].clear()
	
	filled.emit()
	
	return self


func shuffle() -> Deck:
	current_cards.shuffle()
	shuffled.emit()
	
	return self
#endregion
	
#region Random pickers
func pick_random_card() -> PlayingCardUI:
	if current_cards.is_empty():
		return null
	
	return pick_card(current_cards.pick_random())
	

func pick_random_cards(amount: int) -> Array[PlayingCardUI]:
	if current_cards.is_empty():
		return []
	
	var selected_cards: Array[PlayingCardUI] = []
	amount = clamp(amount, 1, current_cards.size())
	
	for i in amount:
		selected_cards.append(pick_card(current_cards.pick_random()))
	
	return selected_cards


func pick_random_number_card() -> PlayingCardUI:
	return pick_card(number_cards().pick_random())


## The function parameter "suit" is not typed as the suits are separated into different enums
func pick_random_card_from_suit(suit: PlayingCard.Suits) -> PlayingCardUI:
	if current_cards_by_suit.has(suit) and current_cards_by_suit[suit].size() > 0:
		return pick_card(current_cards_by_suit[suit].pick_random())
	
	return null


func pick_random_card_of_value(value: int) -> PlayingCardUI:
	var selected_cards: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.value == value
		)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_card_of_suit_and_value(suit: PlayingCard.Suits, value: int) -> PlayingCardUI:
	var selected_cards: Array[PlayingCardUI] = cards_from_suit(suit).filter(
		func(playing_card: PlayingCardUI): return playing_card.card.value == value
		)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_ace() -> PlayingCardUI:
	var aces: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_ace()
		)
	
	if aces.is_empty():
		return null
		
	return pick_card(aces.pick_random())


func pick_random_figure() -> PlayingCardUI:
	var figures: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_figure()
		)
	
	if figures.is_empty():
		return null
		
	return pick_card(figures.pick_random())


func pick_random_jack() -> PlayingCardUI:
	var jacks: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_jack()
		)
	
	if jacks.is_empty():
		return null
		
	return pick_card(jacks.pick_random())


func pick_random_queen() -> PlayingCardUI:
	var queens: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_queen()
		)
	
	if queens.is_empty():
		return null
		
	return pick_card(queens.pick_random())


func pick_random_knight() -> PlayingCardUI:
	var knights: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_knight()
		)
	
	if knights.is_empty():
		return null
		
	return pick_card(knights.pick_random())


func pick_random_king() -> PlayingCardUI:
	var kings: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_king()
		)
	
	if kings.is_empty():
		return null
		
	return pick_card(kings.pick_random())


func pick_random_joker() -> PlayingCardUI:
	var selected_jokers: Array[PlayingCardUI] = current_cards.filter(
		func(playing_card: PlayingCardUI): return playing_card.card.is_joker()
		)
	
	if selected_jokers.is_empty():
		return null
		
	return pick_card(selected_jokers.pick_random())

#endregion

#region Pickers
func pick_cards(selected_cards: Array[PlayingCardUI]) -> Array[PlayingCardUI]:
	for card in selected_cards:
		pick_card(card)
		
	return selected_cards
	
	
func pick_card(card: PlayingCardUI) -> PlayingCardUI:
	remove_card(card)
	picked_card.emit(card)
	
	return card


func number_cards() -> Array[PlayingCardUI]:
	return extract_number_cards(current_cards)
	

func number_cards_from_suit(suit: PlayingCard.Suits) -> Array[PlayingCardUI]:
	return extract_number_cards(cards_from_suit(suit))


func figure_cards() -> Array[PlayingCardUI]:
	return extract_figure_cards(current_cards)
	

func figure_cards_from_suit(suit: PlayingCard.Suits) -> Array[PlayingCardUI]:
	return extract_figure_cards(cards_from_suit(suit))


func extract_number_cards(selected_cards: Array[PlayingCardUI]) -> Array[PlayingCardUI]:
	return selected_cards.filter(func(playing_card: PlayingCardUI): return playing_card.card.is_number())


func extract_figure_cards(selected_cards: Array[PlayingCardUI]) -> Array[PlayingCardUI]:
	return selected_cards.filter(func(playing_card: PlayingCardUI): return playing_card.card.is_figure())
	

func cards_from_suit(suit: PlayingCard.Suits) -> Array[PlayingCardUI]:
	if current_cards_by_suit.has(suit):
		return current_cards_by_suit[suit]
	
	return []

#endregion

func add_cards(new_cards: Array[PlayingCardUI], allow_duplicates: bool = false) -> void:
	for card: PlayingCardUI in new_cards:
		add_card(card, allow_duplicates)
	
	added_cards.emit(new_cards)


func add_card(playing_card: PlayingCardUI, allow_duplicates: bool = false) -> void:
	if allow_duplicates:
		current_cards.append(playing_card)
		current_cards_by_suit[playing_card.card.suit].append(playing_card)
	else:
		if not current_cards.has(playing_card):
			current_cards.append(playing_card)
			
		if not current_cards_by_suit[playing_card.card.suit].has(playing_card):
			current_cards_by_suit[playing_card.card.suit].append(playing_card)
	
	added_card.emit(playing_card)
	
	
func remove_card(playing_card: PlayingCardUI):
	current_cards.erase(playing_card)
	
	if current_cards_by_suit.has(playing_card.card.suit):
		current_cards_by_suit[playing_card.card.suit].erase(playing_card)
		removed_card.emit(playing_card)
	
	if is_empty():
		emptied_deck.emit()
	
	add_to_discard_pile(playing_card)
	

func add_jokers(amount: int, selected_card: PlayingCardUI = null) -> Deck:
	if amount > 0 and jokers.size() > 0:
		var new_jokers: Array[PlayingCardUI] = []
		var joker: PlayingCardUI = selected_card if selected_card != null and selected_card.card.is_joker() else jokers.pick_random()
		
		new_jokers.assign(ArrayHelper.repeat(joker, amount))
		
		add_cards(new_jokers)
		
	return self
	

#region Discard pile
func add_to_discard_pile(playing_card: PlayingCardUI) -> void:
	if not discard_pile.has(playing_card):
		discard_pile.append(playing_card)
		added_to_discard_pile.emit(playing_card)


func extract_from_discard_pile(playing_card: PlayingCardUI) -> PlayingCardUI:
	if discard_pile.has(playing_card):
		var selected_card: PlayingCardUI = discard_pile[discard_pile.find(playing_card)]
		discard_pile.erase(playing_card)
		
		return selected_card
	
	return null


func recover_from_discard_pile(playing_card: PlayingCardUI) -> PlayingCardUI:
	var card_to_recover: PlayingCardUI = extract_from_discard_pile(playing_card)
	
	if card_to_recover != null:
		add_card(card_to_recover)
		recovered_card_from_discard_pile.emit(playing_card)
	return null
#endregion

#region Information
func has_aces() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_ace())
	
	
func has_jokers() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_joker())
	

func has_only_jokers() -> bool:
	return current_cards.all(func(playing_card: PlayingCardUI): return playing_card.card.is_joker())
	
	
func has_figures() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_figure())
	

func has_jacks() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_jack())
	
	
func has_queens() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_queen())
	

func has_knights() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_knight())
	

func has_kings() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_king())
	
	
func has_number_cards() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_number())
	
	
func has_clubs() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_club())
	
	
func has_hearts() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_heart())


func has_diamonds() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_diamond())


func has_spades() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_spade())


func has_cups() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_cup())


func has_golds() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_gold())


func has_swords() -> bool:
	return current_cards.any(func(playing_card: PlayingCardUI): return playing_card.card.is_sword())


func is_empty() -> bool:
	return (has_only_jokers() and not jokers_count_for_empty_deck) or current_cards.is_empty()


func deck_size() -> int:
	return current_cards.size()
#endregion


func change_back_texture(idx: int) -> Deck:
	var back_index: int = backs.find(idx)
	
	if back_index != -1:
		current_back_texture = backs[back_index]
		
		for playing_card: PlayingCardUI in current_cards:
			playing_card.card.back_texture = current_back_texture

	
	return self


func clear_deck() -> void:
	backs.clear()
	jokers.clear()
	discard_pile.clear()
	cards.clear()
	current_cards.clear()
	
	current_cards_by_suit = {
		PlayingCard.Suits.Joker: [],
		PlayingCard.Suits.Heart: [],
		PlayingCard.Suits.Diamond: [],
		PlayingCard.Suits.Spade: [],
		PlayingCard.Suits.Club: [],
		PlayingCard.Suits.Gold: [],
		PlayingCard.Suits.Cup: [],
		PlayingCard.Suits.Sword: [],
	}
	cards_by_suit = {
		PlayingCard.Suits.Joker: [],
		PlayingCard.Suits.Heart: [],
		PlayingCard.Suits.Diamond: [],
		PlayingCard.Suits.Spade: [],
		PlayingCard.Suits.Club: [],
		PlayingCard.Suits.Gold: [],
		PlayingCard.Suits.Cup: [],
		PlayingCard.Suits.Sword: [],
	}
	
	cleared_deck.emit()

#region Private
@warning_ignore("integer_division")
func _calculate_visual_pile_counter() -> int:
	return ceili(cards.size() / maxi(1, visual_pile_cards_amount))

#endregion

#region Signal callbacks
func on_added_card(_card: PlayingCardUI) -> void:
	visual_pile_counter += 1
	

func on_removed_card(_card: PlayingCardUI) -> void:
	visual_pile_counter -= 1
	
	if visual_pile_counter == 0 and get_child_count() > 0:
		NodeTraversal.get_last_child(self).queue_free()
		@warning_ignore("integer_division")
		visual_pile_counter = _calculate_visual_pile_counter()

#endregion
